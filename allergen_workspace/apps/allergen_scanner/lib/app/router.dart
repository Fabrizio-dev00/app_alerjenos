import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/history/presentation/history_screen.dart';
import '../features/paywall/presentation/paywall_screen.dart';
import '../features/profiles/presentation/profiles_screen.dart';
import '../features/scan/presentation/camera_screen.dart';
import '../features/scan/presentation/ocr_screen.dart';
import '../features/scan/presentation/preview_screen.dart';
import '../features/scan/presentation/scan_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'home_shell.dart';
import 'routes.dart';

export 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.scan,
    routes: [
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
            GoRoute(path: AppRoutes.profiles, builder: (context, state) => const ProfilesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.camera,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: CameraScreen()),
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
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: PaywallScreen()),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
