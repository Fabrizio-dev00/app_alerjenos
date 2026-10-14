import 'package:allergen_scanner/features/scan/domain/label_image_repository.dart';
import 'package:allergen_scanner/features/scan/presentation/ocr_providers.dart';
import 'package:allergen_scanner/features/scan/presentation/scan_controller.dart';
import 'package:core_i18n/core_i18n.dart';
import 'package:core_ocr/core_ocr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

class _Gallery implements LabelImageRepository {
  @override
  Future<String?> pickFromGallery() async => '/tmp/label.jpg';

  @override
  Future<String?> crop(String imagePath, {required String title}) async => imagePath;
}

class _Recognizer implements TextRecognizerService {
  _Recognizer(this.text);

  final String text;

  @override
  Future<OcrResult> recognize(String imagePath) async => OcrResult(
        text: text,
        blocks: [
          for (final (i, line) in text.split('\n').indexed)
            OcrBlock(
              text: line,
              box: OcrBox(left: 0, top: i * 30.0, width: 300, height: 24),
              lines: [OcrLine(text: line, box: OcrBox(left: 0, top: i * 30.0, width: 300, height: 24))],
            ),
        ],
        imageWidth: 400,
        imageHeight: 400,
      );

  @override
  Future<void> close() async {}
}

class _Detector implements LanguageDetector {
  @override
  Future<String?> detect(String text) async => 'es';

  @override
  Future<void> close() async {}
}

Future<InMemoryHistoryRepository> _scan(WidgetTester tester, String label, {Map<String, Object> preferences = const {}}) async {
  final history = InMemoryHistoryRepository();
  await pumpApp(
    tester,
    history: history,
    preferences: preferences,
    overrides: [
      labelImageRepositoryProvider.overrideWithValue(_Gallery()),
      textRecognizerProvider.overrideWithValue(_Recognizer(label)),
      languageDetectorProvider.overrideWithValue(_Detector()),
    ],
  );
  await tester.tap(find.byTooltip('Elegir de la galería'));
  await tester.pumpAndSettle();
  return history;
}

void main() {
  testWidgets('una etiqueta con leche termina en Contiene, se guarda y descuenta un escaneo', (tester) async {
    final history = await _scan(tester, 'Ingredientes: harina de arroz, leche en polvo, azúcar');

    expect(find.text('Contiene'), findsOneWidget);
    expect(find.text('Leche'), findsOneWidget);
    expect(find.textContaining('1 alérgeno de tu perfil Yo'), findsOneWidget);
    expect(find.textContaining('no significa seguro'), findsOneWidget);
    expect(history.reports.single.verdict.name, 'contains');

    await tester.tap(find.text('Escanear otra'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Te quedan 4 de 5'), findsOneWidget);
  });

  testWidgets('solo trazas muestra el resultado ámbar con la fila de trazas', (tester) async {
    await _scan(tester, 'Ingredientes: harina de arroz, azúcar, cacao. Puede contener trazas de huevo.');

    expect(find.text('Puede contener trazas'), findsOneWidget);
    expect(find.text('Huevo (trazas)'), findsOneWidget);
    expect(find.textContaining('no significa seguro'), findsOneWidget);
  });

  testWidgets('No detectado muestra lo que revisamos y nunca dice seguro', (tester) async {
    await _scan(tester, 'Ingredientes: harina de arroz, azúcar, manteca de cacao, sal marina');

    expect(find.text('No detectado'), findsOneWidget);
    expect(find.text('Lo que revisamos'), findsOneWidget);
    expect(find.textContaining('Leímos 4 ingredientes en español'), findsOneWidget);
    final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data ?? '').join(' ').toLowerCase();
    expect(texts.replaceAll('no significa seguro', ''), isNot(contains('seguro')));
  });

  testWidgets('una lectura sin lista de ingredientes no da No detectado ni gasta escaneos', (tester) async {
    final history = await _scan(tester, 'Galletas con cobertura sabor a chocolate');

    expect(find.text('No pudimos leer la etiqueta'), findsOneWidget);
    expect(find.text('No detectado'), findsNothing);
    expect(history.reports, isEmpty);

    await tester.tap(find.text('Intentar de nuevo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Te quedan 5 de 5'), findsOneWidget);
  });

  testWidgets('guardar pide un nombre y lo muestra en el historial', (tester) async {
    final history = await _scan(tester, 'GALLETAS DE MANTEQUILLA\nIngredientes: harina de trigo, mantequilla');

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('GALLETAS DE MANTEQUILLA'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'Galletas de mantequilla');
    await tester.tap(find.text('Guardar').last);
    await tester.pumpAndSettle();

    expect(history.reports.single.productName, 'Galletas de mantequilla');

    await tester.tap(find.text('Escanear otra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();
    expect(find.text('HOY'), findsOneWidget);
    expect(find.text('Galletas de mantequilla'), findsOneWidget);
  });

  testWidgets('sin guardar historial automático no se guarda hasta tocar Guardar', (tester) async {
    final history = await _scan(tester, 'Ingredientes: leche, azúcar, sal', preferences: {'save_history': false});

    expect(find.text('Contiene'), findsOneWidget);
    expect(history.reports, isEmpty);
  });
}
