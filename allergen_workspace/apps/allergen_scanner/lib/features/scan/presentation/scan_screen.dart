import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/safety_notice.dart';
import 'scan_controller.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  Future<void> _takePhoto(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(scanControllerProvider.notifier);
    final cropTitle = AppLocalizations.of(context).cropTitle;
    if (!await controller.ensureCameraPermission() || !context.mounted) return;
    final captured = await context.push<String>(AppRoutes.camera);
    if (captured == null || !context.mounted) return;
    final cropped = await controller.crop(captured, title: cropTitle);
    if (cropped != null && context.mounted) context.push(AppRoutes.preview, extra: cropped);
  }

  Future<void> _pickFromGallery(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(scanControllerProvider.notifier);
    final path = await controller.pickFromGallery(cropTitle: AppLocalizations.of(context).cropTitle);
    if (path != null && context.mounted) context.push(AppRoutes.preview, extra: path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final status = ref.watch(scanControllerProvider);
    final working = status == ScanStatus.working;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.scanHeadline, style: textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(l10n.scanDescription, style: textTheme.bodyLarge),
            const SizedBox(height: 32),
            _StatusMessage(status: status),
            FilledButton.icon(
              onPressed: working ? null : () => _takePhoto(context, ref),
              icon: const Icon(Icons.photo_camera),
              label: Text(l10n.scanTakePhoto),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: working ? null : () => _pickFromGallery(context, ref),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.scanFromGallery),
            ),
            if (working) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 32),
            const SafetyNotice(),
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends ConsumerWidget {
  const _StatusMessage({required this.status});

  final ScanStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(scanControllerProvider.notifier);

    final (String message, String? actionLabel, VoidCallback? action) = switch (status) {
      ScanStatus.idle || ScanStatus.working => ('', null, null),
      ScanStatus.cameraDenied => (l10n.cameraDenied, null, null),
      ScanStatus.cameraBlocked => (l10n.cameraBlocked, l10n.openSettings, controller.openSettings),
      ScanStatus.galleryFailed => (l10n.galleryFailed, null, null),
      ScanStatus.cropFailed => (l10n.cropFailed, null, null),
    };
    if (message.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: scheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: controller.dismissMessage,
                    child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                  ),
                  if (actionLabel != null) TextButton(onPressed: action, child: Text(actionLabel)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
