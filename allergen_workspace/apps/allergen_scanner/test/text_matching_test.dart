import 'package:allergen_scanner/core/text/fuzzy_matcher.dart';
import 'package:allergen_scanner/core/text/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextNormalizer', () {
    test('quita tildes, signos y mayúsculas en los 6 idiomas', () {
      expect(TextNormalizer.normalize('INGRÉDIENTS: Lait, Œufs!'), 'ingredients lait oeufs');
      expect(TextNormalizer.normalize('Weizenmehl, Süßmolkenpulver'), 'weizenmehl sussmolkenpulver');
      expect(TextNormalizer.normalize('Lecitina de soja (E322)'), 'lecitina de soja e322');
      expect(TextNormalizer.normalize('Açúcar, castanhas-do-pará'), 'acucar castanhas do para');
    });

    test('tokens de un texto vacío es una lista vacía', () {
      expect(TextNormalizer.tokens('  ,.; '), isEmpty);
    });
  });

  group('FuzzyMatcher', () {
    test('levenshtein cuenta ediciones y corta al superar el máximo', () {
      expect(FuzzyMatcher.levenshtein('harina', 'hartna'), 1);
      expect(FuzzyMatcher.levenshtein('mantequilla', 'mantequi11a'), 2);
      expect(FuzzyMatcher.levenshtein('leche', 'nueces', max: 1), 2);
    });

    test('tolera errores de OCR según el largo de la palabra', () {
      expect(FuzzyMatcher.containsPhrase('Hartna de trigo foriicada', 'harina'), isTrue);
      expect(FuzzyMatcher.containsPhrase('mantequi11a y sal', 'mantequilla'), isTrue);
      expect(FuzzyMatcher.containsPhrase('tiamlia, riboffavina', 'riboflavina'), isTrue);
    });

    test('las palabras cortas exigen coincidencia exacta para no inventar alérgenos', () {
      expect(FuzzyMatcher.containsPhrase('azúcar, sal', 'soja'), isFalse);
      expect(FuzzyMatcher.containsPhrase('soya texturizada', 'soja'), isFalse);
      expect(FuzzyMatcher.containsPhrase('lecitina de soja', 'soja'), isTrue);
    });

    test('encuentra frases de varias palabras', () {
      expect(FuzzyMatcher.containsPhrase('Puede contener trazas de nueces', 'puede contener'), isTrue);
      expect(FuzzyMatcher.containsPhrase('INGREDIENTS: wheat flour', 'wheat flour'), isTrue);
      expect(FuzzyMatcher.containsPhrase('wheat and flour', 'wheat flour'), isFalse);
    });
  });
}
