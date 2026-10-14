import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/telemetry/telemetry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../profiles/presentation/profiles_providers.dart';
import 'onboarding_providers.dart';

class StepDots extends StatelessWidget {
  const StepDots({required this.step, this.total = 3, this.dark = false, super.key});

  final int step;
  final int total;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: SanoMotion.reduced(context) ? Duration.zero : const Duration(milliseconds: 220),
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
            width: i == step ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == step ? SanoColors.coffee : SanoColors.coffee.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({required this.step, this.trailing, super.key});

  final int step;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.welcome),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(LucideIcons.chevronLeft, size: 28),
              ),
            ),
          ),
          Expanded(
            child: Center(child: StepDots(step: step)),
          ),
          SizedBox(
            width: 120,
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    );
  }
}

class SpeechBubble extends StatelessWidget {
  const SpeechBubble({required this.text, this.author, super.key});

  final String text;
  final String? author;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
      decoration: BoxDecoration(
        color: SanoColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: SanoShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (author != null) ...[
            Text(
              author!,
              style: const TextStyle(color: SanoColors.accent, fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 4),
          ],
          Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35)),
        ],
      ),
    );
  }
}

Future<void> saveOnboardingProfile(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final draft = ref.read(onboardingDraftProvider);
  final done = ref.read(onboardingDoneProvider);
  if (!done) {
    ref.read(telemetryProvider).log(TelemetryEvent.onboardingCompleted, {
      'method': draft.transcript.isEmpty ? 'manual' : 'voice_or_text',
    });
    await ref
        .read(onboardingDoneProvider.notifier)
        .complete(profileName: l10n.defaultProfileName, allergenIds: draft.allergenIds);
    ref.read(onboardingDraftProvider.notifier).reset();
    if (context.mounted) context.go(AppRoutes.scan);
    return;
  }
  final count = ref.read(profilesProvider).value?.length ?? 0;
  final profile = await ref
      .read(profileRepositoryProvider)
      .create(name: l10n.profileDefaultName(count + 1), allergenIds: draft.allergenIds);
  await ref.read(activeProfileIdProvider.notifier).select(profile.id);
  ref.read(onboardingDraftProvider.notifier).reset();
  if (context.mounted) context.go(AppRoutes.profileEditor(profile.id));
}
