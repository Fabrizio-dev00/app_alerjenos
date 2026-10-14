import 'package:allergen_scanner/features/scan/domain/camera_permission_repository.dart';
import 'package:allergen_scanner/features/profiles/domain/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('arranca en el escáner con el perfil activo y el contador gratis', (tester) async {
    await pumpApp(tester);

    expect(find.text('Perfil: Yo'), findsOneWidget);
    expect(find.textContaining('Te quedan 5 de 5 escaneos hoy'), findsOneWidget);
    expect(find.text('Acerca la etiqueta y toca'), findsOneWidget);
  });

  testWidgets('en Pro no se muestra el contador', (tester) async {
    await pumpApp(tester, pro: true);

    expect(find.textContaining('escaneos hoy'), findsNothing);
  });

  testWidgets('la barra flotante tiene 3 pestañas y navega', (tester) async {
    await pumpApp(tester);

    expect(find.text('Escanear'), findsOneWidget);
    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay escaneos'), findsOneWidget);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil activo'), findsOneWidget);
    expect(find.text('Leche, Huevo y Gluten'), findsOneWidget);
  });

  testWidgets('con la cámara negada muestra la tarjeta de permiso', (tester) async {
    final permissions = FakePermissions(CameraPermission.denied);
    await pumpApp(tester, permissions: permissions);

    expect(find.text('Necesitamos tu cámara'), findsOneWidget);
    expect(find.text('Dar permiso'), findsOneWidget);
    expect(find.text('Elegir de la galería'), findsOneWidget);
  });

  testWidgets('con la cámara bloqueada "Dar permiso" abre los ajustes del teléfono', (tester) async {
    final permissions = FakePermissions(CameraPermission.permanentlyDenied);
    await pumpApp(tester, permissions: permissions);

    await tester.tap(find.text('Dar permiso'));
    await tester.pump();

    expect(permissions.settingsOpened, 1);
    expect(find.text('Necesitamos tu cámara'), findsOneWidget);
  });

  testWidgets('al llegar al límite diario pide volver mañana o pasar a Pro', (tester) async {
    await pumpApp(tester, preferences: {'quota_day': '2026-10-13', 'quota_count': 5});

    expect(find.text('Llegaste a 5 escaneos hoy'), findsOneWidget);
    expect(find.text('Ver SanoScan Pro'), findsOneWidget);
  });

  testWidgets('un perfil sin alérgenos no puede escanear', (tester) async {
    await pumpApp(
      tester,
      profiles: InMemoryProfileRepository([const Profile(id: 1, name: 'Yo', allergenIds: {})]),
    );

    expect(find.text('Elige tus alérgenos'), findsOneWidget);
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

  testWidgets('los interruptores de ajustes se guardan', (tester) async {
    final preferences = await pumpApp(tester);
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Vibración al escanear'), 200);
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    expect(preferences.getBool('vibrate_on_scan'), isTrue);
  });
}
