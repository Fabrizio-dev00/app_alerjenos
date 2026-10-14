import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/gradient_button.dart';
import '../../profiles/domain/allergen_choice.dart';
import '../../profiles/presentation/allergen_grid.dart';
import 'onboarding_providers.dart';
import 'onboarding_widgets.dart';

class ManualScreen extends ConsumerStatefulWidget {
  const ManualScreen({super.key});

  @override
  ConsumerState<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends ConsumerState<ManualScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final draft = ref.watch(onboardingDraftProvider);
    final count = AllergenChoice.selectedIn(draft.allergenIds).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: OnboardingTopBar(step: 1)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Text(l10n.onboardingStep(2, 3), style: textTheme.titleSmall),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
              child: Text(l10n.allergensQuestion, style: textTheme.headlineLarge),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  AllergenGrid(
                    selected: draft.allergenIds,
                    onChanged: ref.read(onboardingDraftProvider.notifier).setAllergens,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.lock, color: SanoColors.muted, size: 20),
                      const SizedBox(width: 10),
                      Text(l10n.allergensSelected(count), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.profileStoredLocally, style: textTheme.bodySmall)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GradientButton(
                    label: l10n.saveProfile,
                    trailingArrow: true,
                    onPressed: count == 0 || _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            await saveOnboardingProfile(context, ref);
                            if (mounted) setState(() => _saving = false);
                          },
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
