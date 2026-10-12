import 'package:core_ocr/core_ocr.dart';
import 'package:flutter_test/flutter_test.dart';

OcrBlock _block(String text, double left, double top, double width, double height) => OcrBlock(
      text: text,
      box: OcrBox(left: left, top: top, width: width, height: height),
    );

void main() {
  group('OcrBox', () {
    const box = OcrBox(left: 10, top: 20, width: 100, height: 50);

    test('contains incluye los bordes y excluye lo de afuera', () {
      expect(box.contains(10, 20), isTrue);
      expect(box.contains(110, 70), isTrue);
      expect(box.contains(60, 45), isTrue);
      expect(box.contains(9, 45), isFalse);
      expect(box.contains(60, 71), isFalse);
    });

    test('scale lleva la caja de la imagen a la pantalla', () {
      expect(box.scale(0.5), const OcrBox(left: 5, top: 10, width: 50, height: 25));
    });
  });

  group('OcrResult', () {
    test('isEmpty es verdadero sin bloques o con texto en blanco', () {
      expect(
        const OcrResult(text: '', blocks: [], imageWidth: 100, imageHeight: 100).isEmpty,
        isTrue,
      );
      expect(
        OcrResult(text: '  \n', blocks: [_block(' ', 0, 0, 1, 1)], imageWidth: 1, imageHeight: 1)
            .isEmpty,
        isTrue,
      );
    });

    test('blockIndexAt encuentra el bloque tocado y prioriza el de arriba', () {
      final result = OcrResult(
        text: 'Ingredientes: leche\nPuede contener nueces',
        blocks: [
          _block('Ingredientes: leche', 0, 0, 200, 100),
          _block('Puede contener nueces', 0, 120, 200, 40),
          _block('leche', 50, 40, 60, 20),
        ],
        imageWidth: 200,
        imageHeight: 200,
      );

      expect(result.isEmpty, isFalse);
      expect(result.blockIndexAt(10, 10), 0);
      expect(result.blockIndexAt(60, 45), 2);
      expect(result.blockIndexAt(100, 130), 1);
      expect(result.blockIndexAt(100, 190), isNull);
    });
  });
}
