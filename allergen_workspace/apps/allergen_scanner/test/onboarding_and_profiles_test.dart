import 'package:allergen_scanner/features/onboarding/data/speech_service.dart';
import 'package:allergen_scanner/features/profiles/domain/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'helpers/pump_app.dart';

Future<void> _toVoice(WidgetTester tester) async {
  expect(find.text('Lee la etiqueta. Cuida lo que comes.'), findsOneWidget);
  await tester.tap(find.text('Comenzar'));
  await tester.pumpAndSettle();
  expect(find.textContaining('Hola, soy Sano'), findsOneWidget);
}

void main() {
  testWidgets('escribir los alérgenos lleva a confirmar y crea el perfil Yo', (tester) async {
    final repository = InMemoryProfileRepository();
    final preferences = await pumpApp(tester, onboarded: false, profiles: repository);
    await _toVoice(tester);

    await tester.enterText(find.byType(TextField), 'Soy alérgico a la leche, al huevo y al gluten');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('¿Es esto correcto?'), findsOneWidget);
    expect(find.textContaining('Entendí 3 alérgenos'), findsOneWidget);
    expect(find.text('Soja'), findsNothing, reason: '"Soy alérgico" no es soja');

    await tester.tap(find.text('Sí, guardar mi perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil: Yo'), findsOneWidget);
    expect(repository.profiles.single.allergenIds, {'milk', 'eggs', 'gluten'});
    expect(preferences.getBool('onboarding_done'), isTrue);
  });

  testWidgets('la voz se transcribe en vivo y al detener pasa a confirmar', (tester) async {
    await pumpApp(tester, onboarded: false, speech: FakeSpeech(words: 'tengo alergia a los mariscos'));
    await _toVoice(tester);

    await tester.tap(find.byIcon(LucideIcons.mic));
    await tester.pumpAndSettle();
    expect(find.text('tengo alergia a los mariscos'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.square));
    await tester.pumpAndSettle();

    expect(find.textContaining('Entendí 1 alérgeno'), findsOneWidget);
    expect(find.text('Mariscos'), findsOneWidget);
  });

  testWidgets('si la voz sin conexión no está disponible lo explica y deja escribir', (tester) async {
    await pumpApp(tester, onboarded: false, speech: FakeSpeech(failure: SpeechFailure.offlineUnsupported));
    await _toVoice(tester);

    await tester.tap(find.byIcon(LucideIcons.mic));
    await tester.pumpAndSettle();

    expect(find.textContaining('sin conexión para este idioma'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('si no reconoce ningún alérgeno se queda y lo dice', (tester) async {
    await pumpApp(tester, onboarded: false);
    await _toVoice(tester);

    await tester.enterText(find.byType(TextField), 'hola qué tal');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.textContaining('No reconocí ningún alérgeno'), findsOneWidget);
  });

  testWidgets('en confirmar se puede quitar un alérgeno tocándolo', (tester) async {
    final repository = InMemoryProfileRepository();
    await pumpApp(tester, onboarded: false, profiles: repository);
    await _toVoice(tester);
    await tester.enterText(find.byType(TextField), 'leche y maní');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Maní'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sí, guardar mi perfil'));
    await tester.pumpAndSettle();

    expect(repository.profiles.single.allergenIds, {'milk'});
  });

  testWidgets('elegir a mano con buscador y guardar', (tester) async {
    final repository = InMemoryProfileRepository();
    await pumpApp(tester, onboarded: false, profiles: repository);
    await _toVoice(tester);

    await tester.tap(find.text('Elegir a mano'));
    await tester.pumpAndSettle();
    expect(find.text('¿Qué alérgenos evitas?'), findsOneWidget);
    expect(find.text('Guardar perfil'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ajonjoli');
    await tester.pumpAndSettle();
    expect(find.text('Leche'), findsNothing);
    await tester.tap(find.text('Ajonjolí'));
    await tester.pumpAndSettle();
    expect(find.text('1 elegido.'), findsOneWidget);

    await tester.tap(find.text('Guardar perfil'));
    await tester.pumpAndSettle();

    expect(repository.profiles.single.allergenIds, {'sesame'});
  });

  testWidgets('editar el perfil activo desde ajustes guarda los cambios', (tester) async {
    final repository = InMemoryProfileRepository([defaultTestProfile]);
    await pumpApp(tester, profiles: repository);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil activo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Huevo'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guardar perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar perfil'));
    await tester.pumpAndSettle();

    expect(repository.profiles.single.allergenIds, {'milk', 'gluten'});
  });

  testWidgets('en Pro la lista de perfiles permite cambiar el activo', (tester) async {
    final repository = InMemoryProfileRepository([
      defaultTestProfile,
      const Profile(id: 2, name: 'Mateo', allergenIds: {'peanuts', 'tree_nuts'}),
    ]);
    final preferences = await pumpApp(tester, pro: true, profiles: repository);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Activo'), findsOneWidget);
    await tester.tap(find.text('Perfiles'));
    await tester.pumpAndSettle();

    expect(find.textContaining('2 de 6 perfiles'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Usar este perfil').last);
    await tester.pumpAndSettle();

    expect(preferences.getInt('active_profile_id'), 2);
  });

  testWidgets('en la versión gratis la pantalla Pro aparece al tocar el banner', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SanoScan Pro'));
    await tester.pumpAndSettle();

    expect(find.text('Desbloquear Pro por USD 3.99'), findsOneWidget);
    expect(find.text('Hasta 6'), findsOneWidget);
  });
}
