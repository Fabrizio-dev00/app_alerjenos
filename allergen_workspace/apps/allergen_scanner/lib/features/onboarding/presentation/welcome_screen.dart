import 'package:core_i18n/core_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/gradient_button.dart';
import '../../../shared/brand/sano_mascot.dart';
import '../../settings/presentation/locale_controller.dart';
import 'onboarding_widgets.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final current = Localizations.localeOf(context).languageCode;
    final next = current == AppLanguage.spanish.code ? AppLanguage.english : AppLanguage.spanish;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ClipPath(
                  clipper: _WaveClipper(),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(gradient: SanoColors.brandGradient),
                    child: CustomPaint(
                      painter: _OrganicLinesPainter(),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 56),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: SanoColors.paper),
                                    child: const Icon(LucideIcons.searchCheck, color: SanoColors.orange),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      l10n.appTitle,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.headlineSmall?.copyWith(fontSize: 28),
                                    ),
                                  ),
                                  Material(
                                    color: SanoColors.paper,
                                    shape: const StadiumBorder(),
                                    child: InkWell(
                                      customBorder: const StadiumBorder(),
                                      onTap: () => ref.read(localeControllerProvider.notifier).select(next),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                        child: Row(
                                          children: [
                                            const Icon(LucideIcons.globe, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              current.toUpperCase(),
                                              style: const TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const SanoMascot(mood: SanoMood.idle, size: 140, sway: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.tagline, style: textTheme.headlineLarge?.copyWith(fontSize: 40, height: 1.1)),
                      const SizedBox(height: 14),
                      Text(l10n.onboardingIntro, style: textTheme.bodyLarge?.copyWith(color: SanoColors.muted)),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: _Stat(value: '6', label: l10n.statLanguages),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Stat(value: '0', label: l10n.statAccounts),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Stat(value: '100%', label: l10n.statOnDevice),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                      const StepDots(step: 0),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.onboardingNoSignup,
                          textAlign: TextAlign.end,
                          style: textTheme.bodyMedium?.copyWith(color: SanoColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    label: l10n.onboardingStart,
                    trailingArrow: true,
                    onPressed: () => context.push(AppRoutes.onboardingVoice),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        boxShadow: SanoShadows.soft,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: SanoColors.accent),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 30)
      ..quadraticBezierTo(size.width * 0.3, size.height - 70, size.width * 0.6, size.height - 34)
      ..quadraticBezierTo(size.width * 0.85, size.height - 8, size.width, size.height - 60)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}

class _OrganicLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SanoColors.cream.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final top = Path()
      ..moveTo(0, size.height * 0.12)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.02, size.width * 0.7, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.15, size.width, size.height * 0.05);
    final bottom = Path()
      ..moveTo(0, size.height * 0.84)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.78, size.width * 0.5, size.height * 0.86)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.92, size.width, size.height * 0.74);
    canvas
      ..drawPath(top, paint)
      ..drawPath(bottom, paint);
  }

  @override
  bool shouldRepaint(_OrganicLinesPainter oldDelegate) => false;
}
