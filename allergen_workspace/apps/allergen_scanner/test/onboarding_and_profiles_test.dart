import 'package:allergen_scanner/features/profiles/domain/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('el onboarding crea el perfil Yo con los alérgenos elegidos', (tester) async {
    final repository = InMemoryProfileRepository();
    final preferences = await pumpApp(tester, onboarded: false, profiles: repository);

    expect(find.text('Lee la etiqueta. Cuida lo que comes.'), findsOneWidget);
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    expect(find.text('¿Qué alérgenos evitas?'), findsOneWidget);
    expect(find.text('Paso 2 de 3'), findsOneWidget);
    await tester.tap(find.text('Leche'));
    await tester.ensureVisible(find.text('Mariscos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mariscos'));
    await tester.pumpAndSettle();
    expect(find.text('2 elegidos.'), findsOneWidget);

    await tester.tap(find.text('Guardar perfil'));
    await tester.pumpAndSettle();
    expect(find.textContaining('no significa seguro'), findsOneWidget);

    await tester.tap(find.text('Entendido, empezar'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil: Yo'), findsOneWidget);
    expect(repository.profiles.single.allergenIds, {'milk', 'crustaceans', 'molluscs'});
    expect(preferences.getBool('onboarding_done'), isTrue);
    expect(preferences.getInt('active_profile_id'), repository.profiles.single.id);
  });

  testWidgets('el buscador filtra la grilla sin importar tildes', (tester) async {
    await pumpApp(tester, onboarded: false);
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ajonjoli');
    await tester.pumpAndSettle();

    expect(find.text('Ajonjolí'), findsOneWidget);
    expect(find.text('Leche'), findsNothing);
  });

  testWidgets('no deja guardar el perfil del onboarding sin alérgenos', (tester) async {
    final repository = InMemoryProfileRepository();
    await pumpApp(tester, onboarded: false, profiles: repository);
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar perfil'));
    await tester.pumpAndSettle();

    expect(find.text('¿Qué alérgenos evitas?'), findsOneWidget);
    expect(repository.profiles, isEmpty);
  });

  testWidgets('editar el perfil activo desde ajustes guarda los cambios', (tester) async {
    final repository = InMemoryProfileRepository([defaultTestProfile]);
    await pumpApp(tester, profiles: repository);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil activo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Huevo'));
    await tester.scrollUntilVisible(find.text('Guardar perfil'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Guardar perfil'));
    await tester.pumpAndSettle();

    expect(repository.profiles.single.allergenIds, {'milk', 'gluten'});
  });

  testWidgets('en la versión gratis un segundo perfil lleva al paywall', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil activo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('hasta 6 perfiles'), findsOneWidget);
    await tester.tap(find.text('Agregar perfil'));
    await tester.pumpAndSettle();

    expect(find.text('SanoScan Pro'), findsWidgets);
  });

  testWidgets('el perfil activo cae al primero si el guardado ya no existe', (tester) async {
    final repository = InMemoryProfileRepository([
      const Profile(id: 7, name: 'Sofía', allergenIds: {'peanuts'}),
    ]);
    await pumpApp(tester, profiles: repository);

    expect(find.text('Perfil: Sofía'), findsOneWidget);
  });
}
