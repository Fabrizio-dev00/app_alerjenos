import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/empty_state.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({required this.imagePath, super.key});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final path = imagePath;
    final file = path == null ? null : File(path);

    if (file == null || !file.existsSync()) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.previewTitle)),
        body: EmptyState(icon: Icons.broken_image_outlined, message: l10n.previewImageMissing),
      );
    }

    final media = MediaQuery.of(context);
    final cacheWidth = (media.size.width * media.devicePixelRatio).round();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.previewTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.previewHint, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Image.file(file, fit: BoxFit.contain, cacheWidth: cacheWidth),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.ocr, extra: file.path),
                icon: const Icon(Icons.manage_search),
                label: Text(l10n.previewAnalyze),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.replay),
                label: Text(l10n.previewRetake),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
