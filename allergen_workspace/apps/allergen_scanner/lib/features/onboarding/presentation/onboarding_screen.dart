import 'package:core_i18n/core_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/gradient_button.dart';
import '../../../shared/brand/sano_mascot.dart';
import '../../profiles/domain/allergen_choice.dart';
import '../../profiles/presentation/allergen_grid.dart';
import '../../profiles/presentation/profiles_providers.dart';
import '../../settings/presentation/locale_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 3;

  final _pages = PageController();
  int _step = 0;
  Set<String> _allergens = {};
  bool _saving = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pages.animateToPage(step, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    await ref.read(onboardingDoneProvider.notifier).complete(
          profileName: AppLocalizations.of(context).defaultProfileName,
          allergenIds: _allergens,
        );
    if (mounted) context.go(AppRoutes.scan);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goTo(_step - 1);
      },
      child: Scaffold(
        body: PageView(
          controller: _pages,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _WelcomeStep(step: 0, total: _steps, onNext: () => _goTo(1)),
            _AllergensStep(
              step: 1,
              total: _steps,
              selected: _allergens,
              onChanged: (value) => setState(() => _allergens = value),
              onNext: () => _goTo(2),
            ),
            _ReadyStep(step: 2, total: _steps, saving: _saving, onFinish: _finish),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            width: i == step ? 32 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: i == step ? SanoColors.coffee : SanoColors.line,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
      ],
    );
  }
}

class _WelcomeStep extends ConsumerWidget {
  const _WelcomeStep({required this.step, required this.total, required this.onNext});

  final int step;
  final int total;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final current = Localizations.localeOf(context).languageCode;
    final next = current == AppLanguage.spanish.code ? AppLanguage.english : AppLanguage.spanish;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: SanoColors.brandGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(l10n.appTitle, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      ActionChip(
                        avatar: const Icon(Icons.language, size: 18, color: SanoColors.coffee),
                        label: Text(current.toUpperCase()),
                        backgroundColor: SanoColors.cream,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                        onPressed: () => ref.read(localeControllerProvider.notifier).select(next),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SanoMascot(mood: SanoMood.waving, size: 150),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            children: [
              Text(l10n.tagline, style: textTheme.headlineLarge),
              const SizedBox(height: 14),
              Text(l10n.onboardingIntro, style: textTheme.bodyLarge?.copyWith(color: SanoColors.muted)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _Stat(value: '6', label: l10n.statLanguages)),
                  const SizedBox(width: 12),
                  Expanded(child: _Stat(value: '0', label: l10n.statAccounts)),
                  const SizedBox(width: 12),
                  Expanded(child: _Stat(value: '100%', label: l10n.statOnDevice)),
                ],
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _StepDots(step: step, total: total),
                    const Spacer(),
                    Text(l10n.onboardingNoSignup, style: textTheme.bodyMedium?.copyWith(color: SanoColors.muted)),
                  ],
                ),
                const SizedBox(height: 16),
                GradientButton(label: l10n.onboardingStart, trailingArrow: true, onPressed: onNext),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: SanoColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: SanoColors.coffee.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: SanoColors.traces)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.step,
    required this.total,
    required this.title,
    required this.body,
    required this.footer,
  });

  final int step;
  final int total;
  final String title;
  final Widget body;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Text(l10n.onboardingStep(step + 1, total), style: textTheme.titleSmall),
                const Spacer(),
                _StepDots(step: step, total: total),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text(title, style: textTheme.headlineLarge),
          ),
          Expanded(child: body),
          Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), child: footer),
        ],
      ),
    );
  }
}

class _AllergensStep extends StatelessWidget {
  const _AllergensStep({
    required this.step,
    required this.total,
    required this.selected,
    required this.onChanged,
    required this.onNext,
  });

  final int step;
  final int total;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = AllergenChoice.selectedIn(selected).length;

    return _StepScaffold(
      step: step,
      total: total,
      title: l10n.allergensQuestion,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        children: [AllergenGrid(selected: selected, onChanged: onChanged)],
      ),
      footer: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline, color: SanoColors.muted, size: 20),
              const SizedBox(width: 10),
              Text(l10n.allergensSelected(count), style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.profileStoredLocally, style: const TextStyle(color: SanoColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GradientButton(label: l10n.saveProfile, trailingArrow: true, onPressed: count == 0 ? null : onNext),
        ],
      ),
    );
  }
}

class _ReadyStep extends StatelessWidget {
  const _ReadyStep({required this.step, required this.total, required this.saving, required this.onFinish});

  final int step;
  final int total;
  final bool saving;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return _StepScaffold(
      step: step,
      total: total,
      title: l10n.onboardingReadyTitle,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const Center(child: SanoMascot(mood: SanoMood.neutral, size: 110)),
          const SizedBox(height: 20),
          Text(l10n.onboardingReadyBody, style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: SanoColors.coffee, borderRadius: BorderRadius.circular(24)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: SanoColors.card),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.onboardingReadyRule,
                    style: const TextStyle(color: SanoColors.card, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.download_outlined, color: SanoColors.orange),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.onboardingLanguagesHint, style: textTheme.bodyMedium)),
            ],
          ),
        ],
      ),
      footer: GradientButton(label: l10n.onboardingAccept, onPressed: saving ? null : onFinish),
    );
  }
}
