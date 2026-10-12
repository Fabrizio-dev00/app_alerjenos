import 'dart:io';

import 'package:core_ocr/core_ocr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('preprocessor_test'));
  tearDown(() => temp.deleteSync(recursive: true));

  test('reduce a 2048 px, pasa a grises y estira el contraste', () async {
    final source = img.Image(width: 3000, height: 1000);
    img.fill(source, color: img.ColorRgb8(120, 130, 140));
    img.fillRect(source, x1: 0, y1: 0, x2: 1500, y2: 1000, color: img.ColorRgb8(100, 110, 120));
    final path = '${temp.path}${Platform.pathSeparator}label.jpg';
    File(path).writeAsBytesSync(img.encodeJpg(source, quality: 100));

    final output = await ImagePreprocessor.enhanceContrast(path);
    final result = img.decodeImage(File(output).readAsBytesSync())!;

    expect(output, endsWith('label_enhanced.jpg'));
    expect(result.width, ImagePreprocessor.maxSide);
    expect(result.height, closeTo(683, 1));
    final dark = result.getPixel(100, 500);
    final light = result.getPixel(2000, 500);
    expect(dark.r, dark.g);
    expect(light.r - dark.r, greaterThan(150));
  });

  test('una imagen que no se puede leer lanza OcrException', () async {
    final path = '${temp.path}${Platform.pathSeparator}broken.jpg';
    File(path).writeAsStringSync('no es una imagen');

    expect(ImagePreprocessor.enhanceContrast(path), throwsA(isA<OcrException>()));
  });
}
