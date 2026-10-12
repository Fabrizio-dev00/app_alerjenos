import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/safety_notice.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.scanHeadline, style: textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(l10n.scanDescription, style: textTheme.bodyLarge),
              const Spacer(),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.photo_camera),
                label: Text(l10n.scanTakePhoto),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.scanFromGallery),
              ),
              const SizedBox(height: 24),
              const SafetyNotice(),
            ],
          ),
        ),
      ),
    );
  }
}
