import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/history/presentation/history_screen.dart';
import '../features/onboarding/presentation/confirm_screen.dart';
import '../features/onboarding/presentation/manual_screen.dart';
import '../features/onboarding/presentation/voice_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/paywall/presentation/paywall_screen.dart';
import '../features/profiles/presentation/profile_editor_screen.dart';
import '../features/profiles/presentation/profiles_providers.dart';
import '../features/profiles/presentation/profiles_screen.dart';
import '../features/scan/domain/scan_report.dart';
import '../features/scan/presentation/processing_screen.dart';
import '../features/scan/presentation/result_screen.dart';
import '../features/scan/presentation/scanner_screen.dart';
import '../features/settings/presentation/privacy_screen.dart';
import '../features/settings/presentation/scan_languages_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'home_shell.dart';
import 'routes.dart';

export 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.scan,
    redirect: (context, state) {
      final done = ref.read(onboardingDoneProvider);
      final location = state.matchedLocation;
      final inOnboarding = location == AppRoutes.welcome || location.startsWith('/onboarding');
      if (!done && !inOnboarding) return AppRoutes.welcome;
      if (done && location == AppRoutes.welcome) return AppRoutes.scan;
      if (location == AppRoutes.result && state.extra is! ScanReport) return AppRoutes.history;
      if (location == AppRoutes.processing && state.extra is! String) return AppRoutes.scan;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.welcome, builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: AppRoutes.onboardingVoice, builder: (context, state) => const VoiceScreen()),
      GoRoute(path: AppRoutes.onboardingConfirm, builder: (context, state) => const ConfirmScreen()),
      GoRoute(path: AppRoutes.onboardingManual, builder: (context, state) => const ManualScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.scan, builder: (context, state) => const ScannerScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.history, builder: (context, state) => const HistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(path: 'languages', builder: (context, state) => const ScanLanguagesScreen()),
                GoRoute(path: 'privacy', builder: (context, state) => const PrivacyScreen()),
                GoRoute(
                  path: 'profiles',
                  builder: (context, state) => const ProfilesScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) =>
                          ProfileEditorScreen(profileId: int.tryParse(state.pathParameters['id'] ?? '')),
                    ),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.processing,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: ProcessingScreen(imagePath: state.extra! as String),
        ),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) => ResultScreen(report: state.extra! as ScanReport),
      ),
      GoRoute(
        path: AppRoutes.pro,
        pageBuilder: (context, state) => const MaterialPage(fullscreenDialog: true, child: PaywallScreen()),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
