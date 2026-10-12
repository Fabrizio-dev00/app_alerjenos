import 'ocr_models.dart';

abstract interface class TextRecognizerService {
  Future<OcrResult> recognize(String imagePath);

  Future<void> close();
}

class OcrException implements Exception {
  const OcrException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'OcrException: $message';
}
