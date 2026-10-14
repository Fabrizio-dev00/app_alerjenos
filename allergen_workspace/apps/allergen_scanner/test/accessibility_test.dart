import 'package:allergen_scanner/features/scan/domain/scan_report.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  for (final scale in [1.3, 1.6]) {
    testWidgets('con letra al ${(scale * 100).round()} % las pantallas principales no se desbordan', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, textScale: scale);
      expect(tester.takeException(), isNull);

      for (final tab in ['Historial', 'Ajustes', 'Escanear']) {
        await tester.tap(find.bySemanticsLabel(tab));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: tab);
      }
      handle.dispose();
    });

    testWidgets('el onboarding se lee con letra al ${(scale * 100).round()} %', (tester) async {
      await pumpApp(tester, onboarded: false, textScale: scale);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Elegir a mano'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('los botones principales tienen área táctil de al menos 48 px', (tester) async {
    await pumpApp(tester, onboarded: false);

    expect(tester.getSize(find.text('Comenzar').hitTestable()).height, lessThanOrEqualTo(56));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('los textos del escáner y ajustes tienen buen contraste', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));
  });

  testWidgets('los veredictos del historial se anuncian con su texto para lectores de pantalla', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(
      tester,
      history: InMemoryHistoryRepository([
        ScanReport(
          id: 1,
          createdAt: DateTime(2026, 10, 13, 9),
          imagePath: '/x.jpg',
          profileName: 'Yo',
          verdict: ScanVerdict.mayContain,
          hits: const [],
          targetLanguage: 'es',
          originalSection: 'Ingredientes: arroz',
          ingredientCount: 1,
          imageWidth: 10,
          imageHeight: 10,
          productName: 'Barrita de cereal',
        ),
      ]),
    );
    await tester.tap(find.text('Historial').last);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Trazas'), findsWidgets);
    expect(find.text('Barrita de cereal'), findsOneWidget);
    handle.dispose();
  });
}
