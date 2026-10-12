import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ocr_models.dart';
import 'text_recognizer_service.dart';

class MlKitTextRecognizerService implements TextRecognizerService {
  MlKitTextRecognizerService() : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<OcrResult> recognize(String imagePath) async {
    try {
      final size = await _imageSize(imagePath);
      final recognized = await _recognizer.processImage(InputImage.fromFilePath(imagePath));
      return OcrResult(
        text: recognized.text,
        blocks: [for (final block in recognized.blocks) _block(block)],
        imageWidth: size.width,
        imageHeight: size.height,
      );
    } on PlatformException catch (error) {
      throw OcrException('El reconocimiento de texto falló', error);
    } on FileSystemException catch (error) {
      throw OcrException('No se pudo leer la imagen', error);
    }
  }

  @override
  Future<void> close() => _recognizer.close();

  static Future<ui.Size> _imageSize(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final size = ui.Size(descriptor.width.toDouble(), descriptor.height.toDouble());
    descriptor.dispose();
    buffer.dispose();
    return size;
  }

  static OcrBox _box(ui.Rect rect) =>
      OcrBox(left: rect.left, top: rect.top, width: rect.width, height: rect.height);

  static OcrBlock _block(TextBlock block) => OcrBlock(
        text: block.text,
        box: _box(block.boundingBox),
        languages: block.recognizedLanguages,
        lines: [
          for (final line in block.lines)
            OcrLine(
              text: line.text,
              box: _box(line.boundingBox),
              words: [
                for (final element in line.elements)
                  OcrWord(text: element.text, box: _box(element.boundingBox)),
              ],
            ),
        ],
      );
}
