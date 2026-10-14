import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences_provider.dart';

class AppSettings {
  const AppSettings({this.saveHistory = true, this.vibrate = false});

  final bool saveHistory;
  final bool vibrate;
}

final appSettingsProvider = NotifierProvider<AppSettingsController, AppSettings>(AppSettingsController.new);

class AppSettingsController extends Notifier<AppSettings> {
  static const _historyKey = 'save_history';
  static const _vibrateKey = 'vibrate_on_scan';

  @override
  AppSettings build() {
    final preferences = ref.read(sharedPreferencesProvider);
    return AppSettings(
      saveHistory: preferences.getBool(_historyKey) ?? true,
      vibrate: preferences.getBool(_vibrateKey) ?? false,
    );
  }

  Future<void> setSaveHistory(bool value) async {
    await ref.read(sharedPreferencesProvider).setBool(_historyKey, value);
    state = AppSettings(saveHistory: value, vibrate: state.vibrate);
  }

  Future<void> setVibrate(bool value) async {
    await ref.read(sharedPreferencesProvider).setBool(_vibrateKey, value);
    state = AppSettings(saveHistory: state.saveHistory, vibrate: value);
  }
}
