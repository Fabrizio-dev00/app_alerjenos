import 'dart:io';

import 'package:allergen_scanner/core/allergens/allergen_dictionary.dart';
import 'package:allergen_scanner/features/profiles/domain/allergen_choice.dart';
import 'package:allergen_scanner/features/profiles/domain/profile.dart';
import 'package:allergen_scanner/features/scan/domain/allergen_matcher.dart';
import 'package:allergen_scanner/features/scan/domain/ingredient_section.dart';
import 'package:allergen_scanner/features/scan/domain/label_analysis.dart';
import 'package:allergen_scanner/features/scan/domain/scan_report.dart';
import 'package:allergen_scanner/features/scan/domain/scan_report_builder.dart';
import 'package:allergen_scanner/features/scan/domain/token_stream.dart';
import 'package:core_i18n/core_i18n.dart';
import 'package:core_ocr/core_ocr.dart';
import 'package:flutter_test/flutter_test.dart';


OcrResult _ocr(List<String> blocks) => OcrResult(
      text: blocks.join('\n'),
      blocks: [
        for (final (i, text) in blocks.indexed)
          OcrBlock(
            text: text,
            box: OcrBox(left: 0, top: i * 30.0, width: 300, height: 24),
            lines: [OcrLine(text: text, box: OcrBox(left: 0, top: i * 30.0, width: 300, height: 24))],
          ),
      ],
      imageWidth: 400,
      imageHeight: 400,
    );

void main() {
  late AllergenMatcher matcher;
  final now = DateTime(2026, 10, 13, 9, 40);
  const me = Profile(id: 1, name: 'Yo', allergenIds: {'milk', 'eggs', 'gluten', 'crustaceans', 'molluscs'});

  setUpAll(() {
    matcher = AllergenMatcher(AllergenDictionary.parse(File('assets/allergens.json').readAsStringSync()));
  });

  ScanReport build(List<String> blocks, {Profile profile = me, List<String>? translated, AppLanguage? from}) {
    final ocr = _ocr(blocks);
    final analysis = LabelAnalysis(
      ocr: ocr,
      target: AppLanguage.spanish,
      outcome: translated == null ? TranslationOutcome.notNeeded : TranslationOutcome.translated,
      detectedLanguage: from ?? AppLanguage.spanish,
      detectedCode: (from ?? AppLanguage.spanish).code,
      translatedBlocks: translated,
      section: IngredientSectionLocator.locate(ocr),
    );
    final findings = matcher.match([
      TokenStream.fromOcr(ocr),
      if (translated != null) TokenStream.fromTranslatedBlocks(translated),
    ]);
    return ScanReportBuilder.build(analysis: analysis, findings: findings, profile: profile, imagePath: '/x.jpg', now: now);
  }

  test('Contiene con la evidencia original y traducida de cada alérgeno', () {
    final report = build(
      ['Ingrédients : farine de blé, sucre, beurre, lait écrémé en poudre, œufs.'],
      translated: ['Ingredientes: harina de trigo, azúcar, mantequilla, leche desnatada en polvo, huevos.'],
      from: AppLanguage.french,
    );

    expect(report.verdict, ScanVerdict.contains);
    expect(report.containsHits.map((h) => h.choice), [AllergenChoice.milk, AllergenChoice.eggs, AllergenChoice.gluten]);
    final gluten = report.hits.singleWhere((h) => h.choice == AllergenChoice.gluten);
    expect(gluten.original, contains('farine'));
    expect(gluten.translated, contains('harina'));
    expect(report.wasTranslated, isTrue);
    expect(report.sourceLanguage, 'fr');
  });

  test('solo trazas da Puede contener trazas', () {
    final report = build(['Ingredientes: harina de arroz, azúcar, cacao. Puede contener trazas de leche.']);

    expect(report.verdict, ScanVerdict.mayContain);
    expect(report.traceHits.single.choice, AllergenChoice.milk);
  });

  test('mariscos del perfil se agrupan en una sola fila', () {
    final report = build(['Ingredientes: arroz, sal. Puede contener mariscos.']);

    expect(report.traceHits.single.choice, AllergenChoice.shellfish);
  });

  test('los alérgenos fuera del perfil no cuentan', () {
    final report = build(
      ['Ingredientes: arroz, maní, sal'],
      profile: const Profile(id: 1, name: 'Yo', allergenIds: {'milk'}),
    );

    expect(report.verdict, ScanVerdict.notDetected);
    expect(report.hits, isEmpty);
  });

  test('No detectado exige una lectura buena; si no, es ilegible', () {
    expect(build(['Ingredientes: harina de arroz, azúcar, sal marina']).verdict, ScanVerdict.notDetected);
    expect(build(['Galletas con chocolate']).verdict, ScanVerdict.unreadable);
    expect(build(['Ingredientes:']).verdict, ScanVerdict.unreadable);
  });

  test('una lectura mala no tapa un alérgeno encontrado', () {
    expect(build(['Galletas con leche']).verdict, ScanVerdict.contains);
  });

  test('E322 sin origen queda como posible soja', () {
    final report = build(
      ['Ingredientes: azúcar, cacao, emulsionante (E322).'],
      profile: const Profile(id: 1, name: 'Yo', allergenIds: {'soy'}),
    );

    expect(report.verdict, ScanVerdict.mayContain);
    expect(report.traceHits.single.possible, isTrue);
  });

  test('cuenta ingredientes y sugiere el nombre del producto', () {
    final report = build(['GALLETAS DOÑA PEPA', 'Ingredientes: harina de arroz, azúcar, sal, cacao']);

    expect(report.ingredientCount, 4);
    expect(report.suggestedName, 'GALLETAS DOÑA PEPA');
  });

  test('el reporte se guarda y se recupera en JSON sin perder datos', () {
    final report = build(['Ingredientes: harina de trigo, leche'], translated: ['Ingredientes: harina de trigo, leche']);
    final restored = ScanReport.fromJson(report.toJson(), id: 9, productName: 'Galletas');

    expect(restored.id, 9);
    expect(restored.productName, 'Galletas');
    expect(restored.verdict, report.verdict);
    expect(restored.hits.map((h) => h.choice), report.hits.map((h) => h.choice));
    expect(restored.createdAt, now);
    expect(restored.highlights.length, report.highlights.length);
  });

  test('el resaltado usa las cajas del texto original', () {
    final report = build(['Ingredientes: leche']);

    expect(report.highlights, isNotEmpty);
    expect(report.highlights.first.level, MatchLevel.contains);
  });
}
