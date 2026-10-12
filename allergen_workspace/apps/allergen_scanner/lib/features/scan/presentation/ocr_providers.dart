import 'dart:ui';

import 'package:core_i18n/core_i18n.dart';
import 'package:core_ocr/core_ocr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/presentation/locale_controller.dart';
import '../domain/label_analysis.dart';

final textRecognizerProvider = Provider<TextRecognizerService>((ref) {
  final service = MlKitTextRecognizerService();
  ref.onDispose(service.close);
  return service;
});

final languageDetectorProvider = Provider<LanguageDetector>((ref) {
  final detector = MlKitLanguageDetector();
  ref.onDispose(detector.close);
  return detector;
});

final translationModelRepositoryProvider = Provider<TranslationModelRepository>(
  (ref) => MlKitTranslationModelRepository(),
);

final translationServiceProvider = Provider<TranslationService>((ref) {
  final service = MlKitTranslationService(ref.watch(translationModelRepositoryProvider));
  ref.onDispose(service.close);
  return service;
});

final scanTargetLanguageProvider = Provider<AppLanguage>((ref) {
  final chosen = ref.watch(localeControllerProvider);
  if (chosen != null) return chosen;
  final system = AppLanguage.fromCode(PlatformDispatcher.instance.locale.languageCode);
  return system != null && AppLanguage.interfaceLanguages.contains(system) ? system : AppLanguage.spanish;
});

final ocrResultProvider = FutureProvider.autoDispose.family<OcrResult, String>(
  (ref, imagePath) => ref.read(textRecognizerProvider).recognize(imagePath),
  retry: (retryCount, error) => null,
);

final labelAnalysisProvider = FutureProvider.autoDispose.family<LabelAnalysis, String>(
  (ref, imagePath) async {
    final ocr = await ref.watch(ocrResultProvider(imagePath).future);
    final analyze = AnalyzeLabel(
      detector: ref.read(languageDetectorProvider),
      translator: ref.read(translationServiceProvider),
    );
    return analyze(ocr, target: ref.watch(scanTargetLanguageProvider));
  },
  retry: (retryCount, error) => null,
);
