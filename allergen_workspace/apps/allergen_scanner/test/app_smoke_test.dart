import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('arranca en escaneo con el perfil activo y el aviso de seguridad', (tester) async {
    await pumpApp(tester);

    expect(find.text('Revisa una etiqueta'), findsOneWidget);
    expect(find.text('Perfil: Yo'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('no significa seguro'), 200);
    expect(find.textContaining('no significa seguro'), findsOneWidget);
  });

  testWidgets('la navegación tiene 3 pestañas', (tester) async {
    await pumpApp(tester);

    final bar = find.byType(NavigationBar);
    expect(find.descendant(of: bar, matching: find.text('Escanear')), findsOneWidget);
    expect(find.descendant(of: bar, matching: find.text('Historial')), findsOneWidget);
    expect(find.descendant(of: bar, matching: find.text('Ajustes')), findsOneWidget);
    expect(find.descendant(of: bar, matching: find.text('Perfiles')), findsNothing);
  });

  testWidgets('respeta el inglés guardado y muestra el perfil activo en ajustes', (tester) async {
    await pumpApp(tester, language: 'en');

    expect(find.text('Check a label'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Active profile'), findsOneWidget);
    expect(find.text('Milk, Egg, Gluten'), findsOneWidget);
  });

  testWidgets('cambiar el idioma desde ajustes actualiza la interfaz y lo guarda', (tester) async {
    final preferences = await pumpApp(tester, language: 'en');

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('Idioma de la app'), findsOneWidget);
    expect(preferences.getString('interface_language'), 'es');
  });
}
