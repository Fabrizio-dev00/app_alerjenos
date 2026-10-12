import 'package:core_i18n/core_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences_provider.dart';

final localeControllerProvider = NotifierProvider<LocaleController, AppLanguage?>(
  LocaleController.new,
);

class LocaleController extends Notifier<AppLanguage?> {
  static const _key = 'interface_language';

  @override
  AppLanguage? build() {
    final code = ref.read(sharedPreferencesProvider).getString(_key);
    return code == null ? null : AppLanguage.fromCode(code);
  }

  Future<void> select(AppLanguage? language) async {
    final preferences = ref.read(sharedPreferencesProvider);
    if (language == null) {
      await preferences.remove(_key);
    } else {
      await preferences.setString(_key, language.code);
    }
    state = language;
  }
}
