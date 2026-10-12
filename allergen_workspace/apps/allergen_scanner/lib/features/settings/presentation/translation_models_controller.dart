import 'package:core_i18n/core_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scan/presentation/ocr_providers.dart';

final translationModelsProvider =
    AsyncNotifierProvider<TranslationModelsController, TranslationModelsState>(
  TranslationModelsController.new,
);

class TranslationModelsState {
  const TranslationModelsState({
    required this.downloaded,
    this.busy = const {},
    this.failed,
  });

  final Set<AppLanguage> downloaded;
  final Set<AppLanguage> busy;
  final AppLanguage? failed;

  bool isDownloaded(AppLanguage language) => downloaded.contains(language);

  bool isBusy(AppLanguage language) => busy.contains(language);

  TranslationModelsState copyWith({
    Set<AppLanguage>? downloaded,
    Set<AppLanguage>? busy,
    AppLanguage? failed,
    bool clearFailed = false,
  }) {
    return TranslationModelsState(
      downloaded: downloaded ?? this.downloaded,
      busy: busy ?? this.busy,
      failed: clearFailed ? null : failed ?? this.failed,
    );
  }
}

class TranslationModelsController extends AsyncNotifier<TranslationModelsState> {
  TranslationModelRepository get _models => ref.read(translationModelRepositoryProvider);

  @override
  Future<TranslationModelsState> build() async {
    final downloaded = <AppLanguage>{};
    for (final language in AppLanguage.values) {
      if (await _models.isDownloaded(language)) downloaded.add(language);
    }
    return TranslationModelsState(downloaded: downloaded);
  }

  Future<bool> download(AppLanguage language) =>
      _change(language, () => _models.download(language), (set) => set.add(language));

  Future<bool> downloadAll(Iterable<AppLanguage> languages) async {
    var ok = true;
    for (final language in languages) {
      ok = await download(language) && ok;
    }
    return ok;
  }

  Future<bool> delete(AppLanguage language) =>
      _change(language, () => _models.delete(language), (set) => set.remove(language));

  Future<bool> _change(
    AppLanguage language,
    Future<void> Function() action,
    void Function(Set<AppLanguage>) apply,
  ) async {
    final current = await future;
    if (current.isBusy(language)) return false;
    state = AsyncData(current.copyWith(busy: {...current.busy, language}, clearFailed: true));
    try {
      await action();
      if (!ref.mounted) return true;
      final latest = state.requireValue;
      final downloaded = {...latest.downloaded};
      apply(downloaded);
      state = AsyncData(latest.copyWith(
        downloaded: downloaded,
        busy: {...latest.busy}..remove(language),
      ));
      return true;
    } on Exception {
      if (!ref.mounted) return false;
      final latest = state.requireValue;
      state = AsyncData(latest.copyWith(busy: {...latest.busy}..remove(language), failed: language));
      return false;
    }
  }
}
