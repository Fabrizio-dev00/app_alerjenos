import 'package:allergen_scanner/features/scan/domain/ingredient_section.dart';
import 'package:core_ocr/core_ocr.dart';
import 'package:flutter_test/flutter_test.dart';

OcrBlock _block(String text, double left, double top, double width, double height) => OcrBlock(
      text: text,
      box: OcrBox(left: left, top: top, width: width, height: height),
      lines: [OcrLine(text: text, box: OcrBox(left: left, top: top, width: width, height: 20))],
    );

OcrResult _ocr(List<OcrBlock> blocks) => OcrResult(
      text: blocks.map((b) => b.text).join('\n'),
      blocks: blocks,
      imageWidth: 1000,
      imageHeight: 2000,
    );

void main() {
  test('encuentra la lista con errores de OCR y sigue los bloques de abajo', () {
    final ocr = _ocr([
      _block('FIELD Doña Pepa', 100, 50, 300, 60),
      _block('INGREDlENTES: Hartna de trigo fortificada', 100, 400, 500, 60),
      _block('azúcar, grasa vegetal, cacao', 100, 470, 500, 40),
      _block('jarabe de glucosa, leche en polvo', 100, 520, 500, 40),
      _block('Información nutricional', 100, 580, 500, 40),
      _block('Grasa total 6 g', 100, 630, 500, 40),
    ]);

    final section = IngredientSectionLocator.locate(ocr);

    expect(section.found, isTrue);
    expect(section.blockIndices, [1, 2, 3]);
    expect(section.text, contains('leche en polvo'));
    expect(section.text, isNot(contains('Grasa total')));
  });

  test('no mezcla una columna vecina ni bloques muy lejanos', () {
    final ocr = _ocr([
      _block('Ingredients: wheat flour, sugar', 100, 400, 400, 60),
      _block('Nutrition per 100 g', 700, 470, 250, 40),
      _block('milk powder, salt', 100, 470, 400, 40),
      _block('Made in Germany', 100, 1500, 400, 40),
    ]);

    final section = IngredientSectionLocator.locate(ocr);

    expect(section.blockIndices, [0, 2]);
  });

  test('suma las frases de trazas aunque estén en otra parte de la etiqueta', () {
    final ocr = _ocr([
      _block('Zutaten: Weizenmehl, Zucker', 100, 400, 400, 60),
      _block('Kann Spuren von Nüssen enthalten', 600, 1600, 300, 40),
    ]);

    expect(IngredientSectionLocator.locate(ocr).blockIndices, [0, 1]);
  });

  test('reconoce el encabezado en los 6 idiomas', () {
    for (final header in ['Ingredientes:', 'Ingredients:', 'Ingrédients :', 'Zutaten:', 'Ingredienti:']) {
      final ocr = _ocr([_block('$header algo', 0, 0, 100, 20)]);
      expect(IngredientSectionLocator.locate(ocr).found, isTrue, reason: header);
    }
  });

  test('sin encabezado no inventa una sección', () {
    final ocr = _ocr([_block('Galletas con cobertura sabor a chocolate', 0, 0, 100, 20)]);

    expect(IngredientSectionLocator.locate(ocr).found, isFalse);
  });
}
