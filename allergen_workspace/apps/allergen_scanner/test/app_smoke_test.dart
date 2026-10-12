import 'package:allergen_scanner/app/app.dart';
import 'package:allergen_scanner/core/preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> pumpApp(WidgetTester tester, Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const AllergenScannerApp(),
    ),
  );
  await tester.pumpAndSettle();
  return preferences;
}

void main() {
  testWidgets('arranca en escaneo con el aviso de seguridad en español', (tester) async {
    await pumpApp(tester, {'interface_language': 'es'});

    expect(find.text('Revisa una etiqueta'), findsOneWidget);
    expect(find.textContaining('no significa seguro'), findsOneWidget);
  });

  testWidgets('respeta el inglés guardado y navega a ajustes', (tester) async {
    await pumpApp(tester, {'interface_language': 'en'});

    expect(find.text('Check a label'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('App language'), findsOneWidget);
  });

  testWidgets('cambiar el idioma en ajustes actualiza la interfaz y lo guarda', (tester) async {
    final preferences = await pumpApp(tester, {'interface_language': 'en'});

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('Idioma de la app'), findsOneWidget);
    expect(preferences.getString('interface_language'), 'es');
  });
}
