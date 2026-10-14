import 'dart:io';

import 'package:allergen_scanner/core/allergens/allergen_dictionary.dart';
import 'package:allergen_scanner/features/onboarding/domain/allergen_phrase_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AllergenPhraseParser parser;

  setUpAll(() {
    parser = AllergenPhraseParser(AllergenDictionary.parse(File('assets/allergens.json').readAsStringSync()));
  });

  test('entiende una frase natural en español', () {
    expect(parser.parse('Soy alérgico a la leche, al huevo y al gluten'), {'milk', 'eggs', 'gluten'});
  });

  test('"soy" como verbo no es soja, pero la soja sí', () {
    expect(parser.parse('Yo soy celíaca'), {'gluten'});
    expect(parser.parse('soy alérgica a la soja'), {'soy'});
    expect(parser.parse("I'm allergic to soy and peanuts"), {'soy', 'peanuts'});
  });

  test('sinónimos regionales del maní', () {
    expect(parser.parse('cacahuate'), {'peanuts'});
    expect(parser.parse('cacahuete'), {'peanuts'});
    expect(parser.parse('maní'), {'peanuts'});
  });

  test('mariscos marca crustáceos y moluscos', () {
    expect(parser.parse('no puedo comer mariscos'), {'crustaceans', 'molluscs'});
  });

  test('leche no implica lactosa, pero intolerancia a la lactosa sí', () {
    expect(parser.parse('leche'), {'milk'});
    expect(parser.parse('soy intolerante a la lactosa'), {'lactose'});
  });

  test('tolera errores de dictado en palabras largas', () {
    expect(parser.parse('almendras y avellanas'), {'tree_nuts'});
    expect(parser.parse('ajonjolí y mostasa'), {'sesame', 'mustard'});
  });

  test('una frase sin alérgenos no inventa nada', () {
    expect(parser.parse('hola, quiero empezar'), isEmpty);
    expect(parser.parse('nuevo perfil para mi hija'), isEmpty);
  });
}
