import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/history/presentation/history_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/paywall/presentation/paywall_screen.dart';
import '../features/profiles/presentation/profile_editor_screen.dart';
import '../features/profiles/presentation/profiles_providers.dart';
import '../features/profiles/presentation/profiles_screen.dart';
import '../features/scan/presentation/camera_screen.dart';
import '../features/scan/presentation/ocr_screen.dart';
import '../features/scan/presentation/preview_screen.dart';
import '../features/scan/presentation/scan_screen.dart';
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
      final onOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!done && !onOnboarding) return AppRoutes.onboarding;
      if (done && onOnboarding) return AppRoutes.scan;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.onboarding, builder: (context, state) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.scan, builder: (context, state) => const ScanScreen()),
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
                GoRoute(
                  path: 'profiles',
                  builder: (context, state) => const ProfilesScreen(),
                  routes: [
                    GoRoute(path: 'new', builder: (context, state) => const ProfileEditorScreen()),
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
        path: AppRoutes.camera,
        pageBuilder: (context, state) => const MaterialPage(fullscreenDialog: true, child: CameraScreen()),
      ),
      GoRoute(
        path: AppRoutes.preview,
        builder: (context, state) => PreviewScreen(imagePath: state.extra as String?),
      ),
      GoRoute(
        path: AppRoutes.ocr,
        builder: (context, state) => OcrScreen(imagePath: state.extra as String?),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        pageBuilder: (context, state) => const MaterialPage(fullscreenDialog: true, child: PaywallScreen()),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
