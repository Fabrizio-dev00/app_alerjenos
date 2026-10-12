import 'dart:async';

import 'package:allergen_scanner/features/scan/presentation/ocr_overlay.dart';
import 'package:allergen_scanner/features/scan/presentation/ocr_providers.dart';
import 'package:allergen_scanner/features/scan/presentation/ocr_screen.dart';
import 'package:allergen_scanner/l10n/generated/app_localizations.dart';
import 'package:core_ocr/core_ocr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRecognizer extends Mock implements TextRecognizerService {}

const _path = '/tmp/label.jpg';

const _result = OcrResult(
  text: 'Ingredientes: harina de trigo, leche\nPuede contener nueces',
  blocks: [
    OcrBlock(
      text: 'Ingredientes: harina de trigo, leche',
      box: OcrBox(left: 0, top: 0, width: 400, height: 200),
    ),
    OcrBlock(
      text: 'Puede contener nueces',
      box: OcrBox(left: 0, top: 300, width: 400, height: 100),
    ),
  ],
  imageWidth: 400,
  imageHeight: 400,
);

void main() {
  late _MockRecognizer recognizer;

  Future<void> pumpOcr(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [textRecognizerProvider.overrideWithValue(recognizer)],
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OcrScreen(imagePath: _path),
        ),
      ),
    );
  }

  setUp(() => recognizer = _MockRecognizer());

  testWidgets('muestra la carga mientras lee y luego los bloques', (tester) async {
    final completer = Completer<OcrResult>();
    when(() => recognizer.recognize(_path)).thenAnswer((_) => completer.future);

    await pumpOcr(tester);
    await tester.pump();
    expect(find.text('Leyendo la etiqueta…'), findsOneWidget);

    completer.complete(_result);
    await tester.pumpAndSettle();

    expect(find.text('2 bloques de texto detectados'), findsOneWidget);
    expect(find.byType(OcrOverlay), findsOneWidget);
    expect(find.textContaining('Toca un recuadro'), findsOneWidget);
  });

  testWidgets('tocar un recuadro muestra su texto', (tester) async {
    when(() => recognizer.recognize(_path)).thenAnswer((_) async => _result);
    await pumpOcr(tester);
    await tester.pumpAndSettle();

    final overlay = tester.getRect(find.byType(OcrOverlay));
    await tester.tapAt(Offset(overlay.center.dx, overlay.bottom - overlay.height * 0.15));
    await tester.pumpAndSettle();

    expect(find.text('Puede contener nueces'), findsOneWidget);
  });

  testWidgets('sin texto sugiere mejorar la foto', (tester) async {
    when(() => recognizer.recognize(_path)).thenAnswer(
      (_) async => const OcrResult(text: '', blocks: [], imageWidth: 10, imageHeight: 10),
    );
    await pumpOcr(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('No encontramos texto'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('un fallo permite reintentar', (tester) async {
    var calls = 0;
    when(() => recognizer.recognize(_path)).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const OcrException('fallo');
      return _result;
    });
    await pumpOcr(tester);
    await tester.pumpAndSettle();

    expect(find.text('No pudimos leer la imagen. Inténtalo de nuevo.'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('2 bloques de texto detectados'), findsOneWidget);
  });
}
