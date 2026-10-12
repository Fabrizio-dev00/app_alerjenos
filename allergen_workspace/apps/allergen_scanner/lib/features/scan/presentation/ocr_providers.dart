import 'package:core_ocr/core_ocr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final textRecognizerProvider = Provider<TextRecognizerService>((ref) {
  final service = MlKitTextRecognizerService();
  ref.onDispose(service.close);
  return service;
});

final ocrResultProvider = FutureProvider.autoDispose.family<OcrResult, String>(
  (ref, imagePath) => ref.read(textRecognizerProvider).recognize(imagePath),
  retry: (retryCount, error) => null,
);
