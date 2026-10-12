import 'package:core_ocr/core_ocr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/empty_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final path = widget.imagePath;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ocrTitle)),
      body: SafeArea(
        child: path == null
            ? EmptyState(icon: Icons.broken_image_outlined, message: l10n.previewImageMissing)
            : switch (ref.watch(ocrResultProvider(path))) {
                AsyncData(:final value) when value.isEmpty => _Problem(
                    icon: Icons.text_fields,
                    message: l10n.ocrNoText,
                  ),
                AsyncData(:final value) => _Recognized(
                    imagePath: path,
                    result: value,
                    selectedBlock: _selectedBlock,
                    onBlockTap: (index) => setState(() => _selectedBlock = index),
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
    required this.result,
    required this.selectedBlock,
    required this.onBlockTap,
  });

  final String imagePath;
  final OcrResult result;
  final int? selectedBlock;
  final ValueChanged<int?> onBlockTap;

  void _showAllText(BuildContext context) {
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
          child: SelectableText(result.text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final selected = selectedBlock;

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
                  result: result,
                  selectedBlock: selected,
                  onBlockTap: onBlockTap,
                  imageErrorLabel: l10n.ocrImageUnavailable,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.ocrBlocksFound(result.blocks.length), style: textTheme.titleMedium),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: SingleChildScrollView(
                  child: selected == null
                      ? Text(l10n.ocrTapHint, style: textTheme.bodyMedium)
                      : SelectableText(result.blocks[selected].text, style: textTheme.bodyLarge),
                ),
              ),
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
