import 'package:core_i18n/core_i18n.dart';
import 'package:core_ocr/core_ocr.dart';

enum TranslationOutcome { notNeeded, translated, modelMissing, unsupportedLanguage, undetermined, failed }

class LabelAnalysis {
  const LabelAnalysis({
    required this.ocr,
    required this.target,
    required this.outcome,
    this.detectedCode,
    this.detectedLanguage,
    this.translatedBlocks,
    this.missingModels = const [],
  });

  final OcrResult ocr;
  final AppLanguage target;
  final TranslationOutcome outcome;
  final String? detectedCode;
  final AppLanguage? detectedLanguage;
  final List<String>? translatedBlocks;
  final List<AppLanguage> missingModels;

  String? get translatedText => translatedBlocks?.join('\n');

  String? translatedBlock(int index) {
    final blocks = translatedBlocks;
    if (blocks == null || index < 0 || index >= blocks.length) return null;
    return blocks[index];
  }
}

class AnalyzeLabel {
  const AnalyzeLabel({required this.detector, required this.translator});

  final LanguageDetector detector;
  final TranslationService translator;

  Future<LabelAnalysis> call(OcrResult ocr, {required AppLanguage target}) async {
    LabelAnalysis result(
      TranslationOutcome outcome, {
      String? code,
      AppLanguage? language,
      List<String>? translated,
      List<AppLanguage> missing = const [],
    }) =>
        LabelAnalysis(
          ocr: ocr,
          target: target,
          outcome: outcome,
          detectedCode: code,
          detectedLanguage: language,
          translatedBlocks: translated,
          missingModels: missing,
        );

    if (ocr.isEmpty) return result(TranslationOutcome.undetermined);

    final String? code;
    try {
      code = await detector.detect(ocr.text);
    } on Exception {
      return result(TranslationOutcome.undetermined);
    }
    if (code == null) return result(TranslationOutcome.undetermined);

    final language = AppLanguage.fromCode(code.split('-').first);
    if (language == null) return result(TranslationOutcome.unsupportedLanguage, code: code);
    if (language == target) {
      return result(TranslationOutcome.notNeeded, code: code, language: language);
    }

    try {
      final translated = await translator.translate(
        [for (final block in ocr.blocks) block.text],
        from: language,
        to: target,
      );
      return result(TranslationOutcome.translated, code: code, language: language, translated: translated);
    } on TranslationModelMissing catch (error) {
      return result(
        TranslationOutcome.modelMissing,
        code: code,
        language: language,
        missing: error.missing,
      );
    } on Exception {
      return result(TranslationOutcome.failed, code: code, language: language);
    }
  }
}
