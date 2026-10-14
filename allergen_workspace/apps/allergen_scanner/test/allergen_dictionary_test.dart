import 'dart:io';

import 'package:allergen_scanner/core/allergens/allergen_dictionary.dart';
import 'package:allergen_scanner/core/text/fuzzy_matcher.dart';
import 'package:allergen_scanner/core/text/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AllergenDictionary dictionary;

  setUpAll(() {
    dictionary = AllergenDictionary.parse(File('assets/allergens.json').readAsStringSync());
  });

  const expectedIds = [
    'gluten',
    'crustaceans',
    'eggs',
    'fish',
    'peanuts',
    'soy',
    'milk',
    'lactose',
    'tree_nuts',
    'celery',
    'mustard',
    'sesame',
    'sulphites',
    'lupin',
    'molluscs',
  ];

  test('cubre los 14 alérgenos de la UE más lactosa', () {
    expect(dictionary.allergens.map((a) => a.id), expectedIds);
  });

  test('cada alérgeno tiene nombre en es/en y términos en los 6 idiomas', () {
    for (final allergen in dictionary.allergens) {
      expect(allergen.names.keys, containsAll(['es', 'en']), reason: allergen.id);
      for (final language in dictionary.languages) {
        expect(allergen.terms[language], isNotEmpty, reason: '${allergen.id}/$language');
      }
    }
  });

  test('hay frases de trazas en los 6 idiomas', () {
    for (final language in dictionary.languages) {
      expect(dictionary.tracePhrases[language], isNotEmpty, reason: language);
    }
  });

  test('ningún término queda vacío ni repetido al normalizar', () {
    for (final allergen in dictionary.allergens) {
      for (final entry in allergen.terms.entries) {
        expect(entry.value, everyElement(isNotEmpty), reason: '${allergen.id}/${entry.key}');
        expect(entry.value.toSet().length, entry.value.length, reason: '${allergen.id}/${entry.key}');
      }
    }
  });

  test('los códigos E tienen formato válido', () {
    final pattern = RegExp(r'^E\d{3,4}[A-Z]?$');
    for (final allergen in dictionary.allergens) {
      for (final code in [...allergen.eCodes, ...allergen.possibleECodes]) {
        expect(pattern.hasMatch(code), isTrue, reason: '${allergen.id}: $code');
      }
    }
  });

  test('ninguna exclusión anula por completo un término del mismo alérgeno', () {
    for (final allergen in dictionary.allergens) {
      final terms = allergen.allTerms.toSet();
      for (final exclude in allergen.excludes) {
        expect(terms.contains(exclude), isFalse, reason: '${allergen.id}: $exclude');
      }
    }
  });

  test('ninguna palabra de parada es un término de alérgeno', () {
    final allTerms = dictionary.allergens.expand((a) => [...a.allTerms, ...a.allPossibleTerms]).toSet();
    for (final word in dictionary.fuzzyStopWords) {
      expect(allTerms.contains(word), isFalse, reason: word);
    }
  });

  test('las palabras de parada cubren las colisiones conocidas de la tolerancia', () {
    final collisions = {
      'nuevo': 'huevo',
      'marina': 'harina',
      'pulpa': 'pulpo',
      'otra': 'ostra',
      'frisch': 'fisch',
      'custard': 'mustard',
      'pesca': 'pesce',
      'latta': 'latte',
      'lactasa': 'lactosa',
    };
    for (final MapEntry(key: common, value: term) in collisions.entries) {
      expect(FuzzyMatcher.containsPhrase(common, term), isTrue, reason: 'la colisión $common/$term existe');
      expect(dictionary.fuzzyStopWords, contains(common));
    }
  });

  group('términos críticos que no pueden faltar', () {
    final critical = {
      'milk': ['caseinato', 'whey', 'lactosuero', 'suero de leche', 'mantequilla', 'molke', 'siero di latte', 'soro de leite'],
      'gluten': ['trigo', 'harina de trigo', 'wheat', 'cebada', 'malta', 'weizen', 'frumento', 'ble'],
      'soy': ['lecitina de soja', 'soy lecithin', 'soja', 'soya'],
      'eggs': ['huevo', 'ovoalbumina', 'egg', 'oeuf'],
      'peanuts': ['mani', 'cacahuete', 'peanut', 'amendoim'],
      'tree_nuts': ['almendra', 'avellana', 'hazelnut', 'nocciola', 'castanha de caju'],
      'sesame': ['ajonjoli', 'sesamo', 'tahini'],
      'molluscs': ['choros', 'conchas de abanico', 'calamar'],
      'lupin': ['chocho', 'tarwi', 'altramuz'],
    };
    for (final MapEntry(key: id, value: terms) in critical.entries) {
      test(id, () {
        final allergen = dictionary.byId(id)!;
        for (final term in terms) {
          expect(allergen.allTerms, contains(TextNormalizer.normalize(term)), reason: term);
        }
      });
    }
  });

  test('E322 queda como posible soja y la lecitina de girasol se excluye', () {
    final soy = dictionary.byId('soy')!;
    expect(soy.possibleECodes, contains('E322'));
    expect(soy.allPossibleTerms, contains('lecitina'));
    expect(soy.excludes, contains('lecitina de girasol'));
  });
}
