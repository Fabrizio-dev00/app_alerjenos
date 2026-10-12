import 'package:allergen_scanner/features/scan/domain/label_analysis.dart';
import 'package:core_i18n/core_i18n.dart';
import 'package:core_ocr/core_ocr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDetector extends Mock implements LanguageDetector {}

class _MockTranslator extends Mock implements TranslationService {}

const _box = OcrBox(left: 0, top: 0, width: 10, height: 10);

const _englishLabel = OcrResult(
  text: 'Ingredients: wheat flour, milk\nMay contain nuts',
  blocks: [
    OcrBlock(text: 'Ingredients: wheat flour, milk', box: _box),
    OcrBlock(text: 'May contain nuts', box: _box),
  ],
  imageWidth: 100,
  imageHeight: 100,
);

void main() {
  late _MockDetector detector;
  late _MockTranslator translator;
  late AnalyzeLabel analyze;

  setUpAll(() => registerFallbackValue(AppLanguage.spanish));

  setUp(() {
    detector = _MockDetector();
    translator = _MockTranslator();
    analyze = AnalyzeLabel(detector: detector, translator: translator);
  });

  void stubTranslation(Future<List<String>> Function() answer) {
    when(() => translator.translate(any(), from: any(named: 'from'), to: any(named: 'to')))
        .thenAnswer((_) => answer());
  }

  test('traduce bloque por bloque cuando el idioma es distinto al del usuario', () async {
    when(() => detector.detect(any())).thenAnswer((_) async => 'en');
    stubTranslation(() async => ['Ingredientes: harina de trigo, leche', 'Puede contener nueces']);

    final result = await analyze(_englishLabel, target: AppLanguage.spanish);

    expect(result.outcome, TranslationOutcome.translated);
    expect(result.detectedLanguage, AppLanguage.english);
    expect(result.translatedBlock(1), 'Puede contener nueces');
    expect(result.translatedText, 'Ingredientes: harina de trigo, leche\nPuede contener nueces');
    expect(result.ocr.text, _englishLabel.text);
    verify(() => translator.translate(
          ['Ingredients: wheat flour, milk', 'May contain nuts'],
          from: AppLanguage.english,
          to: AppLanguage.spanish,
        )).called(1);
  });

  test('no traduce si la etiqueta ya está en el idioma del usuario', () async {
    when(() => detector.detect(any())).thenAnswer((_) async => 'en');

    final result = await analyze(_englishLabel, target: AppLanguage.english);

    expect(result.outcome, TranslationOutcome.notNeeded);
    expect(result.translatedText, isNull);
    verifyNever(() => translator.translate(any(), from: any(named: 'from'), to: any(named: 'to')));
  });

  test('avisa qué modelos faltan sin perder el texto original', () async {
    when(() => detector.detect(any())).thenAnswer((_) async => 'de');
    stubTranslation(() async => throw const TranslationModelMissing([AppLanguage.german]));

    final result = await analyze(_englishLabel, target: AppLanguage.spanish);

    expect(result.outcome, TranslationOutcome.modelMissing);
    expect(result.missingModels, [AppLanguage.german]);
    expect(result.ocr.text, isNotEmpty);
  });

  test('un idioma fuera de los 6 soportados queda como no soportado', () async {
    when(() => detector.detect(any())).thenAnswer((_) async => 'nl');

    final result = await analyze(_englishLabel, target: AppLanguage.spanish);

    expect(result.outcome, TranslationOutcome.unsupportedLanguage);
    expect(result.detectedCode, 'nl');
  });

  test('acepta códigos con región como pt-BR', () async {
    when(() => detector.detect(any())).thenAnswer((_) async => 'pt-br');
    stubTranslation(() async => ['a', 'b']);

    final result = await analyze(_englishLabel, target: AppLanguage.spanish);

    expect(result.detectedLanguage, AppLanguage.portuguese);
  });

  test('sin idioma identificable no intenta traducir', () async {
    when(() => detector.detect(any())).thenAnswer((_) async => null);

    final result = await analyze(_englishLabel, target: AppLanguage.spanish);

    expect(result.outcome, TranslationOutcome.undetermined);
  });

  test('un fallo del detector o del traductor no rompe el análisis', () async {
    when(() => detector.detect(any())).thenThrow(Exception('ml kit'));
    expect((await analyze(_englishLabel, target: AppLanguage.spanish)).outcome,
        TranslationOutcome.undetermined);

    when(() => detector.detect(any())).thenAnswer((_) async => 'en');
    stubTranslation(() async => throw Exception('translator'));
    expect((await analyze(_englishLabel, target: AppLanguage.spanish)).outcome,
        TranslationOutcome.failed);
  });

  test('una lectura vacía no llama al detector', () async {
    const empty = OcrResult(text: '', blocks: [], imageWidth: 1, imageHeight: 1);

    final result = await analyze(empty, target: AppLanguage.spanish);

    expect(result.outcome, TranslationOutcome.undetermined);
    verifyNever(() => detector.detect(any()));
  });
}
