import 'package:core_i18n/core_i18n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromCode encuentra el idioma sin importar mayúsculas', () {
    expect(AppLanguage.fromCode('ES'), AppLanguage.spanish);
    expect(AppLanguage.fromCode('de'), AppLanguage.german);
  });

  test('fromCode devuelve null para un idioma no soportado', () {
    expect(AppLanguage.fromCode('ja'), isNull);
  });

  test('la interfaz arranca en español e inglés', () {
    expect(AppLanguage.interfaceLanguages, [AppLanguage.spanish, AppLanguage.english]);
  });
}
