import 'package:allergen_scanner/features/scan/domain/ingredient_splitter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('separa por comas sin romper los paréntesis', () {
    expect(
      IngredientSplitter.split(
        'INGREDIENTES: Harina de trigo fortificada (hierro, niacina, tiamina), azúcar, grasa vegetal.',
      ),
      ['Harina de trigo fortificada (hierro, niacina, tiamina)', 'azúcar', 'grasa vegetal'],
    );
  });

  test('une las líneas cortadas por el OCR', () {
    expect(
      IngredientSplitter.split('Ingredients: wheat\nflour, milk\npowder; salt'),
      ['wheat flour', 'milk powder', 'salt'],
    );
  });

  test('separa la frase de trazas que viene después de un punto', () {
    expect(
      IngredientSplitter.split('Zutaten: Zucker, Kakao. Kann Spuren von Nüssen enthalten.'),
      ['Zucker', 'Kakao', 'Kann Spuren von Nüssen enthalten'],
    );
  });

  test('tolera paréntesis sin cerrar', () {
    expect(IngredientSplitter.split('azúcar, leche (entera, sal'), ['azúcar', 'leche (entera, sal']);
  });
}
