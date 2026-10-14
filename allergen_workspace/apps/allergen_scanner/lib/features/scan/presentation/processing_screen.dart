import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/sano_mascot.dart';
import '../../../shared/language_names.dart';
import '../../../shared/state_card.dart';
import '../../profiles/presentation/profiles_providers.dart';
import '../../settings/presentation/app_settings.dart';
import '../domain/label_analysis.dart';
import '../domain/scan_report.dart';
import 'ocr_providers.dart';
import 'scan_session.dart';
import 'scanner_screen.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({required this.imagePath, super.key});

  final String imagePath;

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (SanoMotion.reduced(context)) {
      _sweep.stop();
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(scanSessionProvider(widget.imagePath));

    ref.listen(scanSessionProvider(widget.imagePath), (previous, next) {
      final report = next.report;
      if (next.stage != ScanStage.done || report == null || report.verdict == ScanVerdict.unreadable) return;
      if (ref.read(appSettingsProvider).vibrate) HapticFeedback.mediumImpact();
      context.pushReplacement(AppRoutes.result, extra: report);
    });

    final failed = session.stage == ScanStage.failed ||
        (session.stage == ScanStage.done && session.report?.verdict == ScanVerdict.unreadable);

    return Scaffold(
      backgroundColor: SanoColors.coffee,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: SanoColors.darkBackground),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(LucideIcons.x, color: SanoColors.card, size: 28),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 8, 40, 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(widget.imagePath), fit: BoxFit.cover, cacheWidth: 900,
                            errorBuilder: (context, error, stack) => const SizedBox.shrink()),
                        if (!failed)
                          AnimatedBuilder(
                            animation: _sweep,
                            builder: (context, child) => FractionallySizedBox(
                              alignment: Alignment.topCenter,
                              heightFactor: _sweep.value.clamp(0.05, 1),
                              child: child,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, SanoColors.amber.withValues(alpha: 0.45)],
                                ),
                                border: const Border(bottom: BorderSide(color: SanoColors.tangerine, width: 4)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: SanoColors.paper,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.paddingOf(context).bottom),
                child: failed ? _Failed(l10n: l10n) : _Steps(session: session),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return StateCard(
      mood: SanoMood.confused,
      title: l10n.unreadableTitle,
      body: l10n.unreadableBody,
      primaryLabel: l10n.tryAgain,
      onPrimary: () => context.pop(),
      secondaryLabel: l10n.scanFromGallery,
      onSecondary: () => context.pop(ProcessingExit.gallery),
    );
  }
}

class _Steps extends ConsumerWidget {
  const _Steps({required this.session});

  final ScanSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final analysis = session.analysis;
    final stage = session.stage.index;
    final target = languageName(l10n, ref.read(scanTargetLanguageProvider).code);

    final readText = analysis == null
        ? l10n.stepReading
        : analysis.detectedLanguage == null && analysis.detectedCode == null
            ? l10n.stepRead
            : l10n.stepReadLanguage(languageName(l10n, analysis.detectedLanguage?.code ?? analysis.detectedCode));
    final translateText = switch (analysis?.outcome) {
      TranslationOutcome.translated => l10n.stepTranslated(target),
      TranslationOutcome.notNeeded => l10n.stepAlreadyIn(target),
      TranslationOutcome.modelMissing => l10n.stepModelMissing(languageName(l10n, analysis?.detectedLanguage?.code)),
      null => l10n.stepTranslating(target),
      _ => l10n.stepOriginalOnly,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(color: SanoColors.coffee.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SanoMascot(mood: SanoMood.thinking, size: 72, sway: true, crowned: ref.watch(isProProvider)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(liveRegion: true, child: Text(l10n.ocrReading, style: textTheme.headlineMedium)),
                  Text(l10n.photoStaysOnPhone, style: textTheme.bodyMedium?.copyWith(color: SanoColors.muted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Step(done: stage > ScanStage.reading.index, label: readText),
        _Step(done: stage > ScanStage.translating.index, label: translateText),
        _Step(done: stage > ScanStage.matching.index, label: l10n.stepMatching),
        const SizedBox(height: 16),
        const _Skeleton(),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    final reduced = SanoMotion.reduced(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: reduced ? Duration.zero : const Duration(milliseconds: 360),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: done ? SanoColors.brandGradient : null,
              border: done ? null : Border.all(color: SanoColors.line, width: 2),
            ),
            child: AnimatedOpacity(
              opacity: done ? 1 : 0,
              duration: reduced ? Duration.zero : const Duration(milliseconds: 360),
              child: const Icon(LucideIcons.check, color: SanoColors.coffee, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _Skeleton extends StatefulWidget {
  const _Skeleton();

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!SanoMotion.reduced(context) && !_shimmer.isAnimating) _shimmer.repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SanoColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SanoColors.line),
      ),
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final width in [0.9, 0.7, 0.75])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: FractionallySizedBox(
                  widthFactor: width,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      gradient: LinearGradient(
                        begin: Alignment(-1 + _shimmer.value * 3, 0),
                        end: Alignment(_shimmer.value * 3, 0),
                        colors: const [Color(0xFFEADFCB), SanoColors.tracesBg, Color(0xFFEADFCB)],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
