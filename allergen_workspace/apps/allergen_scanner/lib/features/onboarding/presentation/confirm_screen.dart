import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/gradient_button.dart';
import '../../../shared/brand/sano_mascot.dart';
import '../../../shared/brand/verdict_pill.dart';
import '../../profiles/domain/allergen_choice.dart';
import '../../profiles/presentation/allergen_grid.dart';
import '../../profiles/presentation/profiles_providers.dart';
import 'onboarding_providers.dart';
import 'onboarding_widgets.dart';

class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({super.key});

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  late final List<AllergenChoice> _understood = AllergenChoice.selectedIn(ref.read(onboardingDraftProvider).allergenIds);
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final draft = ref.watch(onboardingDraftProvider);
    final selectedCount = AllergenChoice.selectedIn(draft.allergenIds).length;
    final extra = [
      for (final choice in AllergenChoice.selectedIn(draft.allergenIds))
        if (!_understood.contains(choice)) choice,
    ];
    final visible = [..._understood, ...extra];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: OnboardingTopBar(step: 1)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  Text(l10n.confirmTitle, style: textTheme.headlineLarge),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SanoMascot(mood: SanoMood.happy, size: 64, crowned: ref.watch(isProProvider)),
                      const SizedBox(width: 12),
                      Expanded(child: SpeechBubble(text: l10n.confirmUnderstood(_understood.length))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (draft.transcript.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: SanoColors.card,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: SanoShadows.soft,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(LucideIcons.quote, color: SanoColors.card, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.confirmYouSaid, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('“${draft.transcript}.”', style: const TextStyle(fontSize: 18, height: 1.35)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  AllergenGrid(
                    selected: draft.allergenIds,
                    choices: visible,
                    searchable: false,
                    onChanged: ref.read(onboardingDraftProvider.notifier).setAllergens,
                  ),
                  const SizedBox(height: 18),
                  DashedActionButton(
                    label: l10n.confirmAddAnother,
                    onPressed: () => context.push(AppRoutes.onboardingManual),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SanoColors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: SanoColors.line),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.info, size: 22),
                        const SizedBox(width: 12),
                        Expanded(child: Text(l10n.confirmReviewNote, style: textTheme.bodyMedium)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: GradientButton(
                label: l10n.confirmSave,
                onPressed: selectedCount == 0 || _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await saveOnboardingProfile(context, ref);
                        if (mounted) setState(() => _saving = false);
                      },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => context.pop(), child: Text(l10n.confirmSpeakAgain)),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.onboardingManual),
                    child: Text(l10n.confirmFixManually),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
