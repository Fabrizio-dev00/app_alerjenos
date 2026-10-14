import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/preferences_provider.dart';
import 'core/telemetry/telemetry.dart';
import 'features/settings/presentation/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final telemetry = await FirebaseTelemetry.start(
    enabled: preferences.getBool(AppSettingsController.diagnosticsKey) ?? true,
  );
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        telemetryProvider.overrideWithValue(telemetry),
      ],
      child: const AllergenScannerApp(),
    ),
  );
}
