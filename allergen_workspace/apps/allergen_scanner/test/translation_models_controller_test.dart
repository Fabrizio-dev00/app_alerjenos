import 'package:allergen_scanner/features/scan/presentation/ocr_providers.dart';
import 'package:allergen_scanner/features/settings/presentation/translation_models_controller.dart';
import 'package:core_i18n/core_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockModels extends Mock implements TranslationModelRepository {}

void main() {
  late _MockModels models;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(AppLanguage.spanish));

  setUp(() {
    models = _MockModels();
    when(() => models.isDownloaded(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first == AppLanguage.english,
    );
    container = ProviderContainer.test(
      overrides: [translationModelRepositoryProvider.overrideWithValue(models)],
    );
  });

  Future<TranslationModelsState> state() => container.read(translationModelsProvider.future);

  test('carga qué idiomas ya están descargados', () async {
    final loaded = await state();

    expect(loaded.downloaded, {AppLanguage.english});
  });

  test('descargar marca el idioma como disponible', () async {
    when(() => models.download(AppLanguage.french)).thenAnswer((_) async {});
    await state();

    final ok = await container.read(translationModelsProvider.notifier).download(AppLanguage.french);

    expect(ok, isTrue);
    final latest = await state();
    expect(latest.isDownloaded(AppLanguage.french), isTrue);
    expect(latest.busy, isEmpty);
  });

  test('una descarga fallida queda registrada sin marcar el idioma', () async {
    when(() => models.download(AppLanguage.german))
        .thenThrow(const TranslationModelDownloadFailed(AppLanguage.german));
    await state();

    final ok = await container.read(translationModelsProvider.notifier).download(AppLanguage.german);

    expect(ok, isFalse);
    final latest = await state();
    expect(latest.isDownloaded(AppLanguage.german), isFalse);
    expect(latest.failed, AppLanguage.german);
  });

  test('eliminar quita el idioma descargado', () async {
    when(() => models.delete(AppLanguage.english)).thenAnswer((_) async {});
    await state();

    await container.read(translationModelsProvider.notifier).delete(AppLanguage.english);

    expect((await state()).isDownloaded(AppLanguage.english), isFalse);
  });
}
