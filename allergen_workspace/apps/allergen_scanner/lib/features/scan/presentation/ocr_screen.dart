import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/empty_state.dart';
import '../../settings/presentation/translation_models_controller.dart';
import '../domain/label_analysis.dart';
import 'ocr_overlay.dart';
import 'ocr_providers.dart';

class OcrScreen extends ConsumerStatefulWidget {
  const OcrScreen({required this.imagePath, super.key});

  final String? imagePath;

  @override
  ConsumerState<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends ConsumerState<OcrScreen> {
  int? _selectedBlock;
  bool _showTranslation = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final path = widget.imagePath;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ocrTitle)),
      body: SafeArea(
        child: path == null
            ? EmptyState(icon: Icons.broken_image_outlined, message: l10n.previewImageMissing)
            : switch (ref.watch(labelAnalysisProvider(path))) {
                AsyncData(:final value) when value.ocr.isEmpty => _Problem(
                    icon: Icons.text_fields,
                    message: l10n.ocrNoText,
                  ),
                AsyncData(:final value) => _Recognized(
                    imagePath: path,
                    analysis: value,
                    selectedBlock: _selectedBlock,
                    showTranslation: _showTranslation,
                    onBlockTap: (index) => setState(() => _selectedBlock = index),
                    onShowTranslation: (show) => setState(() => _showTranslation = show),
                  ),
                AsyncError() => _Problem(
                    icon: Icons.error_outline,
                    message: l10n.ocrFailed,
                    onRetry: () => ref.invalidate(ocrResultProvider(path)),
                  ),
                _ => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Semantics(liveRegion: true, child: Text(l10n.ocrReading)),
                      ],
                    ),
                  ),
              },
      ),
    );
  }
}

class _Recognized extends StatelessWidget {
  const _Recognized({
    required this.imagePath,
    required this.analysis,
    required this.selectedBlock,
    required this.showTranslation,
    required this.onBlockTap,
    required this.onShowTranslation,
  });

  final String imagePath;
  final LabelAnalysis analysis;
  final int? selectedBlock;
  final bool showTranslation;
  final ValueChanged<int?> onBlockTap;
  final ValueChanged<bool> onShowTranslation;

  bool get _translating => showTranslation && analysis.outcome == TranslationOutcome.translated;

  void _showAllText(BuildContext context) {
    final text = _translating ? analysis.translatedText! : analysis.ocr.text;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SelectableText(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final selected = selectedBlock;
    final ocr = analysis.ocr;
    final selectedText = selected == null
        ? null
        : (_translating ? analysis.translatedBlock(selected) : null) ?? ocr.blocks[selected].text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: OcrOverlay(
                  imagePath: imagePath,
                  result: ocr,
                  selectedBlock: selected,
                  onBlockTap: onBlockTap,
                  imageErrorLabel: l10n.ocrImageUnavailable,
                  highlighted: analysis.section.blockIndices.toSet(),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            children: [
              Text(l10n.ocrBlocksFound(ocr.blocks.length), style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _LanguageStatus(
                imagePath: imagePath,
                analysis: analysis,
                showTranslation: showTranslation,
                onShowTranslation: onShowTranslation,
              ),
              const SizedBox(height: 12),
              _SectionStatus(found: analysis.section.found),
              const SizedBox(height: 12),
              if (selectedText != null)
                SelectableText(selectedText, style: textTheme.bodyLarge)
              else if (analysis.section.found)
                SelectableText(analysis.sectionText(translated: _translating), style: textTheme.bodyLarge)
              else
                Text(l10n.ocrTapHint, style: textTheme.bodyMedium),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showAllText(context),
                icon: const Icon(Icons.notes),
                label: Text(l10n.ocrShowAllText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageStatus extends ConsumerWidget {
  const _LanguageStatus({
    required this.imagePath,
    required this.analysis,
    required this.showTranslation,
    required this.onShowTranslation,
  });

  final String imagePath;
  final LabelAnalysis analysis;
  final bool showTranslation;
  final ValueChanged<bool> onShowTranslation;

  Future<void> _downloadAndTranslate(WidgetRef ref) async {
    final ok = await ref.read(translationModelsProvider.notifier).downloadAll(analysis.missingModels);
    if (ok) ref.invalidate(labelAnalysisProvider(imagePath));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final detected = analysis.detectedLanguage?.nativeName;
    final downloading = analysis.missingModels.any(
      (language) => ref.watch(translationModelsProvider).value?.isBusy(language) ?? false,
    );

    Widget note(String text) => Text(text, style: textTheme.bodyMedium);

    return switch (analysis.outcome) {
      TranslationOutcome.notNeeded => note(l10n.detectedLanguage(detected!)),
      TranslationOutcome.translated => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            note(l10n.translatedFrom(detected!, analysis.target.nativeName)),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.showOriginal)),
                ButtonSegment(value: true, label: Text(l10n.showTranslation)),
              ],
              selected: {showTranslation},
              onSelectionChanged: (selection) => onShowTranslation(selection.first),
            ),
          ],
        ),
      TranslationOutcome.modelMissing => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            note(l10n.translationModelMissing(detected!)),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: downloading ? null : () => _downloadAndTranslate(ref),
              icon: downloading
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download),
              label: Text(downloading ? l10n.languageDownloading : l10n.translationDownload),
            ),
          ],
        ),
      TranslationOutcome.unsupportedLanguage => note(l10n.translationUnsupported(analysis.detectedCode!)),
      TranslationOutcome.failed => note(l10n.translationFailed),
      TranslationOutcome.undetermined => note(l10n.languageUndetermined),
    };
  }
}

class _SectionStatus extends StatelessWidget {
  const _SectionStatus({required this.found});

  final bool found;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (found) {
      return Row(
        children: [
          Icon(Icons.check_circle_outline, color: scheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.ingredientsFound)),
        ],
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.ingredientsNotFound, style: TextStyle(color: scheme.onErrorContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.icon, required this.message, this.onRetry});

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final retry = onRetry;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: EmptyState(icon: icon, message: message)),
          if (retry != null) ...[
            FilledButton.icon(onPressed: retry, icon: const Icon(Icons.refresh), label: Text(l10n.retry)),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.replay),
            label: Text(l10n.previewRetake),
          ),
        ],
      ),
    );
  }
}
