import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/sano_mascot.dart';
import '../../profiles/presentation/profiles_providers.dart';
import '../data/speech_service.dart';
import 'onboarding_providers.dart';
import 'onboarding_widgets.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> with SingleTickerProviderStateMixin {
  final _text = TextEditingController();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  String _transcript = '';
  bool _listening = false;
  String? _problem;

  @override
  void dispose() {
    _pulse.dispose();
    _text.dispose();
    if (_listening) ref.read(speechServiceProvider).cancel();
    super.dispose();
  }

  void _setListening(bool value) {
    setState(() => _listening = value);
    if (value && !SanoMotion.reduced(context)) {
      _pulse.repeat();
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  String _failureMessage(SpeechFailure failure) {
    final l10n = AppLocalizations.of(context);
    return switch (failure) {
      SpeechFailure.offlineUnsupported => l10n.voiceOfflineUnsupported,
      SpeechFailure.denied => l10n.voiceDenied,
      SpeechFailure.noMatch => l10n.voiceNoMatch,
      SpeechFailure.unavailable || SpeechFailure.other => l10n.voiceUnavailable,
    };
  }

  Future<void> _toggleMic() async {
    final speech = ref.read(speechServiceProvider);
    if (_listening) {
      await speech.stop();
      _setListening(false);
      await _submit(_transcript);
      return;
    }
    setState(() {
      _problem = null;
      _transcript = '';
    });
    final ready = await speech.initialize(
      onFailure: (failure) {
        if (!mounted) return;
        _setListening(false);
        setState(() => _problem = _failureMessage(failure));
      },
    );
    if (!ready || !mounted) return;
    _setListening(true);
    await speech.listen(
      localeId: Localizations.localeOf(context).languageCode,
      onWords: (words, isFinal) {
        if (!mounted) return;
        setState(() => _transcript = words);
      },
    );
  }

  Future<void> _submit(String phrase) async {
    final text = phrase.trim();
    if (text.isEmpty) return;
    final parser = await ref.read(allergenPhraseParserProvider.future);
    final allergens = parser.parse(text);
    if (!mounted) return;
    if (allergens.isEmpty) {
      setState(() => _problem = AppLocalizations.of(context).voiceNothingFound);
      return;
    }
    ref.read(onboardingDraftProvider.notifier).setTranscript(text, allergens);
    _text.clear();
    context.push(AppRoutes.onboardingConfirm);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crowned = ref.watch(isProProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: OnboardingTopBar(
                step: 1,
                trailing: TextButton(
                  onPressed: () => context.push(AppRoutes.onboardingManual),
                  child: Text(l10n.voiceChooseManually),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  Center(
                    child: SizedBox(
                      width: 240,
                      height: 240,
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, child) =>
                            CustomPaint(painter: _RingsPainter(_listening ? _pulse.value : null), child: child),
                        child: Center(
                          child: SanoMascot(
                            mood: _listening ? SanoMood.listening : SanoMood.idle,
                            size: 130,
                            crowned: crowned,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SpeechBubble(author: l10n.sanoName, text: l10n.voicePrompt),
                  if (_transcript.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                        decoration: BoxDecoration(
                          gradient: SanoColors.brandGradient,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(8),
                          ),
                          boxShadow: SanoShadows.brand,
                        ),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(_transcript, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_listening) ...[Center(child: _SoundWave(animation: _pulse)), const SizedBox(height: 12)],
                  Text(
                    _problem ?? (_listening ? l10n.voiceListening : l10n.voiceTapToSpeak),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _problem != null ? SanoColors.contains : SanoColors.muted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.lock, size: 20, color: SanoColors.muted),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l10n.voicePrivacy, style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _submit,
                      decoration: InputDecoration(
                        hintText: l10n.voiceTypeHint,
                        prefixIcon: const Icon(LucideIcons.keyboard, color: SanoColors.muted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  _MicButton(listening: _listening, pulse: _pulse, onPressed: _toggleMic, label: l10n.voiceMicLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.listening, required this.pulse, required this.onPressed, required this.label});

  final bool listening;
  final Animation<double> pulse;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      toggled: listening,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) =>
            Transform.scale(scale: listening ? 1 + math.sin(pulse.value * math.pi * 2) * 0.05 : 1, child: child),
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SanoColors.brandGradient,
              boxShadow: SanoShadows.brand,
            ),
            child: InkWell(
              onTap: onPressed,
              child: Icon(listening ? LucideIcons.square : LucideIcons.mic, color: SanoColors.coffee, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundWave extends StatelessWidget {
  const _SoundWave({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 9; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 18 + 22 * (0.5 + 0.5 * math.sin(animation.value * math.pi * 2 + i * 0.7)),
              decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(4)),
            ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter(this.progress);

  final double? progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final value = progress;
    if (value == null) {
      canvas.drawCircle(center, maxRadius * 0.62, paint..color = SanoColors.tangerine.withValues(alpha: 0.6));
      return;
    }
    for (var i = 0; i < 3; i++) {
      final t = (value + i / 3) % 1;
      canvas.drawCircle(
        center,
        maxRadius * (0.55 + 0.45 * t),
        paint..color = SanoColors.tangerine.withValues(alpha: (1 - t) * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) => oldDelegate.progress != progress;
}
