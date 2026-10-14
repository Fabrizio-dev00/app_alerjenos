import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences_provider.dart';
import '../../../core/telemetry/telemetry.dart';

class AppSettings {
  const AppSettings({this.saveHistory = true, this.vibrate = false, this.shareDiagnostics = true});

  final bool saveHistory;
  final bool vibrate;
  final bool shareDiagnostics;

  AppSettings copyWith({bool? saveHistory, bool? vibrate, bool? shareDiagnostics}) => AppSettings(
        saveHistory: saveHistory ?? this.saveHistory,
        vibrate: vibrate ?? this.vibrate,
        shareDiagnostics: shareDiagnostics ?? this.shareDiagnostics,
      );
}

final appSettingsProvider = NotifierProvider<AppSettingsController, AppSettings>(AppSettingsController.new);

class AppSettingsController extends Notifier<AppSettings> {
  static const _historyKey = 'save_history';
  static const _vibrateKey = 'vibrate_on_scan';
  static const diagnosticsKey = 'share_diagnostics';

  @override
  AppSettings build() {
    final preferences = ref.read(sharedPreferencesProvider);
    return AppSettings(
      saveHistory: preferences.getBool(_historyKey) ?? true,
      vibrate: preferences.getBool(_vibrateKey) ?? false,
      shareDiagnostics: preferences.getBool(diagnosticsKey) ?? true,
    );
  }

  Future<void> setSaveHistory(bool value) async {
    await ref.read(sharedPreferencesProvider).setBool(_historyKey, value);
    state = state.copyWith(saveHistory: value);
  }

  Future<void> setVibrate(bool value) async {
    await ref.read(sharedPreferencesProvider).setBool(_vibrateKey, value);
    state = state.copyWith(vibrate: value);
  }

  Future<void> setShareDiagnostics(bool value) async {
    await ref.read(sharedPreferencesProvider).setBool(diagnosticsKey, value);
    await ref.read(telemetryProvider).setEnabled(value);
    state = state.copyWith(shareDiagnostics: value);
  }
}
