import 'dart:ui';

enum AppLanguage {
  spanish('es', 'Español'),
  english('en', 'English'),
  french('fr', 'Français'),
  german('de', 'Deutsch'),
  italian('it', 'Italiano'),
  portuguese('pt', 'Português');

  const AppLanguage(this.code, this.nativeName);

  final String code;
  final String nativeName;

  Locale get locale => Locale(code);

  static const List<AppLanguage> interfaceLanguages = [spanish, english];

  static AppLanguage? fromCode(String code) {
    for (final language in values) {
      if (language.code == code.toLowerCase()) return language;
    }
    return null;
  }
}
