import 'package:core_i18n/core_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/empty_state.dart';
import 'translation_models_controller.dart';

class ScanLanguagesScreen extends ConsumerWidget {
  const ScanLanguagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    ref.listen(translationModelsProvider, (previous, next) {
      final failed = next.value?.failed;
      if (failed != null && failed != previous?.value?.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.languageDownloadFailed(failed.nativeName))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsScanLanguages)),
      body: switch (ref.watch(translationModelsProvider)) {
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(l10n.languagesIntro, style: Theme.of(context).textTheme.bodyLarge),
              ),
              for (final language in AppLanguage.values) _LanguageTile(language: language, state: value),
            ],
          ),
        AsyncError() => EmptyState(icon: Icons.error_outline, message: l10n.languagesLoadFailed),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile({required this.language, required this.state});

  final AppLanguage language;
  final TranslationModelsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(translationModelsProvider.notifier);
    final busy = state.isBusy(language);
    final downloaded = state.isDownloaded(language);

    final String subtitle;
    final Widget trailing;
    if (busy) {
      subtitle = l10n.languageDownloading;
      trailing = const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 3));
    } else if (downloaded) {
      subtitle = l10n.languageDownloaded;
      trailing = IconButton(
        onPressed: () => controller.delete(language),
        tooltip: l10n.languageDelete,
        icon: const Icon(Icons.delete_outline),
      );
    } else {
      subtitle = l10n.languageNotDownloaded;
      trailing = IconButton(
        onPressed: () => controller.download(language),
        tooltip: l10n.languageDownload,
        icon: const Icon(Icons.download),
      );
    }

    return ListTile(
      leading: Icon(
        downloaded ? Icons.check_circle : Icons.language,
        color: downloaded ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(language.nativeName),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}
