import 'dart:io';

import 'package:allergen_scanner/core/allergens/allergen_dictionary.dart';
import 'package:allergen_scanner/features/profiles/domain/allergen_choice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las 14 opciones cubren los 15 alérgenos del diccionario', () {
    final dictionary = AllergenDictionary.parse(File('assets/allergens.json').readAsStringSync());
    final covered = {for (final choice in AllergenChoice.values) ...choice.allergenIds};

    expect(AllergenChoice.values, hasLength(14));
    expect(covered, dictionary.allergens.map((a) => a.id).toSet());
  });

  test('Mariscos marca y desmarca crustáceos y moluscos juntos', () {
    final selected = AllergenChoice.shellfish.toggle({'milk'});

    expect(selected, {'milk', 'crustaceans', 'molluscs'});
    expect(AllergenChoice.shellfish.isSelectedIn(selected), isTrue);
    expect(AllergenChoice.shellfish.toggle(selected), {'milk'});
  });

  test('con solo uno de los dos mariscos la opción no aparece marcada y al tocarla completa ambos', () {
    expect(AllergenChoice.shellfish.isSelectedIn({'molluscs'}), isFalse);
    expect(AllergenChoice.shellfish.toggle({'molluscs'}), {'crustaceans', 'molluscs'});
  });

  test('selectedIn devuelve las opciones en el orden de la grilla', () {
    expect(
      AllergenChoice.selectedIn({'gluten', 'milk', 'crustaceans', 'molluscs'}),
      [AllergenChoice.milk, AllergenChoice.gluten, AllergenChoice.shellfish],
    );
  });
}
