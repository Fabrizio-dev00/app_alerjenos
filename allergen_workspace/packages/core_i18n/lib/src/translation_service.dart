import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'app_language.dart';

class TranslationModelMissing implements Exception {
  const TranslationModelMissing(this.missing);

  final List<AppLanguage> missing;

  @override
  String toString() => 'TranslationModelMissing(${missing.map((l) => l.code).join(', ')})';
}

class TranslationModelDownloadFailed implements Exception {
  const TranslationModelDownloadFailed(this.language);

  final AppLanguage language;

  @override
  String toString() => 'TranslationModelDownloadFailed(${language.code})';
}

abstract interface class TranslationService {
  Future<List<String>> translate(
    List<String> texts, {
    required AppLanguage from,
    required AppLanguage to,
  });

  Future<void> close();
}

abstract interface class TranslationModelRepository {
  Future<bool> isDownloaded(AppLanguage language);

  Future<void> download(AppLanguage language);

  Future<void> delete(AppLanguage language);
}

TranslateLanguage _mlKitLanguage(AppLanguage language) =>
    TranslateLanguage.values.firstWhere((candidate) => candidate.bcpCode == language.code);

class MlKitTranslationModelRepository implements TranslationModelRepository {
  MlKitTranslationModelRepository({OnDeviceTranslatorModelManager? manager})
      : _manager = manager ?? OnDeviceTranslatorModelManager();

  final OnDeviceTranslatorModelManager _manager;

  @override
  Future<bool> isDownloaded(AppLanguage language) =>
      _manager.isModelDownloaded(_mlKitLanguage(language).bcpCode);

  @override
  Future<void> download(AppLanguage language) async {
    final ok = await _manager.downloadModel(_mlKitLanguage(language).bcpCode, isWifiRequired: false);
    if (!ok) throw TranslationModelDownloadFailed(language);
  }

  @override
  Future<void> delete(AppLanguage language) async {
    await _manager.deleteModel(_mlKitLanguage(language).bcpCode);
  }
}

class MlKitTranslationService implements TranslationService {
  MlKitTranslationService(this._models);

  final TranslationModelRepository _models;
  final Map<(AppLanguage, AppLanguage), OnDeviceTranslator> _translators = {};

  @override
  Future<List<String>> translate(
    List<String> texts, {
    required AppLanguage from,
    required AppLanguage to,
  }) async {
    if (from == to) return List.of(texts);
    final missing = [
      for (final language in {from, to})
        if (!await _models.isDownloaded(language)) language,
    ];
    if (missing.isNotEmpty) throw TranslationModelMissing(missing);

    final translator = _translators.putIfAbsent(
      (from, to),
      () => OnDeviceTranslator(sourceLanguage: _mlKitLanguage(from), targetLanguage: _mlKitLanguage(to)),
    );
    return [
      for (final text in texts) text.trim().isEmpty ? text : await translator.translateText(text),
    ];
  }

  @override
  Future<void> close() async {
    for (final translator in _translators.values) {
      await translator.close();
    }
    _translators.clear();
  }
}
