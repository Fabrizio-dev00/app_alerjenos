import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

import 'text_recognizer_service.dart';

abstract final class ImagePreprocessor {
  static const maxSide = 2048;

  static Future<String> enhanceContrast(String imagePath) => Isolate.run(() => _enhance(imagePath));

  static String _enhance(String imagePath) {
    final decoded = img.decodeImage(File(imagePath).readAsBytesSync());
    if (decoded == null) throw OcrException('No se pudo decodificar la imagen $imagePath');

    var image = img.bakeOrientation(decoded);
    final longest = math.max(image.width, image.height);
    if (longest > maxSide) {
      image = image.width >= image.height
          ? img.copyResize(image, width: maxSide)
          : img.copyResize(image, height: maxSide);
    }
    image = img.normalize(img.grayscale(image), min: 0, max: 255);

    final dot = imagePath.lastIndexOf('.');
    final base = dot > imagePath.lastIndexOf(Platform.pathSeparator) ? imagePath.substring(0, dot) : imagePath;
    final output = '${base}_enhanced.jpg';
    File(output).writeAsBytesSync(img.encodeJpg(image, quality: 92));
    return output;
  }
}
