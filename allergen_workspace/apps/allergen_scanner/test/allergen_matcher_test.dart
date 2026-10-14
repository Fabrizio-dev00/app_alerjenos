import 'dart:io';

import 'package:allergen_scanner/core/allergens/allergen_dictionary.dart';
import 'package:allergen_scanner/features/scan/domain/allergen_matcher.dart';
import 'package:allergen_scanner/features/scan/domain/token_stream.dart';
import 'package:core_ocr/core_ocr.dart';
import 'package:flutter_test/flutter_test.dart';

const _box = OcrBox(left: 0, top: 0, width: 10, height: 10);

OcrResult _ocr(List<String> blocks) => OcrResult(
      text: blocks.join('\n'),
      blocks: [for (final text in blocks) OcrBlock(text: text, box: _box)],
      imageWidth: 100,
      imageHeight: 100,
    );

void main() {
  late AllergenMatcher matcher;

  setUpAll(() {
    matcher = AllergenMatcher(AllergenDictionary.parse(File('assets/allergens.json').readAsStringSync()));
  });

  Map<String, MatchLevel> levels(List<String> blocks, {List<String>? translated}) {
    final streams = [
      TokenStream.fromOcr(_ocr(blocks)),
      if (translated != null) TokenStream.fromTranslatedBlocks(translated),
    ];
    return {for (final finding in matcher.match(streams)) finding.allergen.id: finding.level};
  }

  group('detección directa', () {
    test('la etiqueta real de Doña Pepa con errores de OCR', () {
      final result = levels([
        'INGREDIENTES: Hartna de trigo foriicada (hiero, nlaci zinc, tiamlia, riboffavina y ácido folico), grageas',
        'azúcar, grasa vegetal, cacao, leche en polvo, lecitina de soya.',
      ]);

      expect(result['gluten'], MatchLevel.contains);
      expect(result['milk'], MatchLevel.contains);
      expect(result['lactose'], MatchLevel.contains);
      expect(result['soy'], MatchLevel.contains);
      expect(result.containsKey('molluscs'), isFalse, reason: '"en polvo" no es pulpo');
    });

    test('términos técnicos de leche en varios idiomas', () {
      expect(levels(['Ingredientes: caseinato de sodio'])['milk'], MatchLevel.contains);
      expect(levels(['Ingredients: sugar, whey powder'])['milk'], MatchLevel.contains);
      expect(levels(['Zutaten: Zucker, Süßmolkenpulver'])['milk'], MatchLevel.contains);
      expect(levels(['Ingredienti: zucchero, siero di latte'])['milk'], MatchLevel.contains);
      expect(levels(['Ingredientes: açúcar, soro de leite'])['milk'], MatchLevel.contains);
      expect(levels(['Ingrédients : sucre, lactosérum'])['milk'], MatchLevel.contains);
    });

    test('tolera errores de OCR en palabras largas', () {
      expect(levels(['mantequi11a, sal'])['milk'], MatchLevel.contains);
      expect(levels(['avellanns tostadas'])['tree_nuts'], MatchLevel.contains);
      expect(levels(['Weizenrnehl'])['gluten'], MatchLevel.contains);
    });

    test('nombres peruanos y latinoamericanos', () {
      expect(levels(['maní tostado'])['peanuts'], MatchLevel.contains);
      expect(levels(['choros a la chalaca'])['molluscs'], MatchLevel.contains);
      expect(levels(['harina de tarwi'])['lupin'], MatchLevel.contains);
      expect(levels(['ajonjolí'])['sesame'], MatchLevel.contains);
      expect(levels(['manjar blanco'])['milk'], MatchLevel.contains);
    });
  });

  group('códigos E e INS', () {
    test('E322 o INS 322 sin especificar es posible soja', () {
      for (final text in ['emulsionante (E322)', 'emulsificante INS 322', 'E-322', 'lecithin (e 322)']) {
        final found = matcher.match([TokenStream.fromOcr(_ocr([text]))]);
        final soy = found.where((f) => f.allergen.id == 'soy').single;
        expect(soy.level, MatchLevel.mayContain, reason: text);
        expect(soy.onlyPossible, isTrue, reason: text);
      }
    });

    test('sulfitos por código', () {
      expect(levels(['conservante: E220'])['sulphites'], MatchLevel.contains);
      expect(levels(['conservante (INS 223)'])['sulphites'], MatchLevel.contains);
    });

    test('lecitina de soja explícita es Contiene, no posible', () {
      final soy = matcher
          .match([TokenStream.fromOcr(_ocr(['lecitina de soja (E322)']))])
          .singleWhere((f) => f.allergen.id == 'soy');
      expect(soy.level, MatchLevel.contains);
    });

    test('lecitina de girasol no se marca como soja', () {
      expect(levels(['emulsionante: lecitina de girasol'])['soy'], isNull);
    });
  });

  group('trazas', () {
    test('lo que sigue a "puede contener" queda como trazas', () {
      final result = levels(['Ingredientes: harina de trigo, azúcar. Puede contener trazas de maní y nueces.']);

      expect(result['gluten'], MatchLevel.contains);
      expect(result['peanuts'], MatchLevel.mayContain);
      expect(result['tree_nuts'], MatchLevel.mayContain);
    });

    test('la frase de trazas puede venir en otro bloque y en otro idioma', () {
      expect(levels(['Ingredients: sugar, cocoa', 'May contain', 'milk and soy'])['milk'], MatchLevel.mayContain);
      expect(levels(['Kann Spuren von Erdnüssen enthalten'])['peanuts'], MatchLevel.mayContain);
      expect(levels(['Peut contenir des traces de lait'])['milk'], MatchLevel.mayContain);
    });

    test('si aparece en los ingredientes y en las trazas gana Contiene', () {
      final result = levels(['Ingredientes: leche entera. Puede contener leche y huevo.']);

      expect(result['milk'], MatchLevel.contains);
      expect(result['eggs'], MatchLevel.mayContain);
    });

    test('la ventana de trazas termina en el punto y no contamina lo que sigue', () {
      final result = levels(['Puede contener nueces. Ingredientes: leche']);

      expect(result['tree_nuts'], MatchLevel.mayContain);
      expect(result['milk'], MatchLevel.contains);
    });
  });

  group('sin falsos positivos conocidos', () {
    test('palabras comunes cercanas a alérgenos', () {
      final result = levels([
        '¡Nuevo! Sal marina, pulpa de fruta, otra receta, peso neto, gama premium, cacao en polvo, polvo de hornear',
      ]);

      expect(result['eggs'], isNull);
      expect(result['gluten'], isNull);
      expect(result['molluscs'], isNull);
    });

    test('ingredientes que suenan a alérgenos pero no lo son', () {
      final result = levels([
        'leche de coco, manteca de cacao, nuez moscada, trigo sarraceno, harina de arroz, lecitina de girasol',
      ]);

      expect(result['milk'], isNull);
      expect(result['lactose'], isNull);
      expect(result['tree_nuts'], isNull);
      expect(result['gluten'], isNull);
      expect(result['soy'], isNull);
    });

    test('"sin gluten" y "sin lactosa" no cuentan como alérgeno', () {
      final result = levels(['Producto sin gluten y sin lactosa']);

      expect(result['gluten'], isNull);
      expect(result['lactose'], isNull);
    });

    test('pero "sin gluten" no tapa el trigo real', () {
      expect(levels(['Sin gluten añadido. Ingredientes: harina de trigo'])['gluten'], MatchLevel.contains);
    });

    test('las palabras cortas exigen coincidencia exacta', () {
      final result = levels(['soda, sopa, eje, pez espada']);

      expect(result['soy'], isNull);
      expect(result['eggs'], isNull);
      expect(result['fish'], MatchLevel.contains);
    });
  });

  group('original y traducción', () {
    test('si la traducción pierde un término técnico, el original lo encuentra', () {
      final result = levels(
        ['Zutaten: Zucker, Süßmolkenpulver, Haselnüsse'],
        translated: ['Ingredientes: azúcar, polvo de suero dulce, avellanas'],
      );

      expect(result['milk'], MatchLevel.contains);
      expect(result['tree_nuts'], MatchLevel.contains);
    });

    test('si el original está en un idioma raro para el diccionario, la traducción ayuda', () {
      final found = matcher.match([
        TokenStream.fromOcr(_ocr(['Ingrediënten: tarwebloem, melk'])),
        TokenStream.fromTranslatedBlocks(['Ingredientes: harina de trigo, leche']),
      ]);
      final gluten = found.singleWhere((f) => f.allergen.id == 'gluten');

      expect(gluten.level, MatchLevel.contains);
      expect(gluten.evidence.first.source, TextSource.translated);
    });
  });

  test('la evidencia guarda bloque y cajas de las palabras para resaltarlas', () {
    const ocr = OcrResult(
      text: 'Ingredientes: leche',
      blocks: [
        OcrBlock(
          text: 'Ingredientes: leche',
          box: OcrBox(left: 0, top: 0, width: 200, height: 20),
          lines: [
            OcrLine(
              text: 'Ingredientes: leche',
              box: OcrBox(left: 0, top: 0, width: 200, height: 20),
              words: [
                OcrWord(text: 'Ingredientes:', box: OcrBox(left: 0, top: 0, width: 120, height: 20)),
                OcrWord(text: 'leche', box: OcrBox(left: 130, top: 0, width: 70, height: 20)),
              ],
            ),
          ],
        ),
      ],
      imageWidth: 200,
      imageHeight: 20,
    );

    final milk = matcher.match([TokenStream.fromOcr(ocr)]).singleWhere((f) => f.allergen.id == 'milk');

    expect(milk.evidence.single.blocks, {0});
    expect(milk.evidence.single.boxes, [const OcrBox(left: 130, top: 0, width: 70, height: 20)]);
  });
}
