import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final points = [
      (LucideIcons.userX, l10n.privacyNoAccount),
      (LucideIcons.smartphone, l10n.privacyOnDevice),
      (LucideIcons.mic, l10n.privacyVoice),
      (LucideIcons.image, l10n.privacyPhotos),
      (LucideIcons.chartNoAxesColumn, l10n.privacyMetrics),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(LucideIcons.chevronLeft, size: 28),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text(l10n.settingsPrivacy, style: textTheme.displaySmall),
          const SizedBox(height: 20),
          for (final (icon, text) in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: SanoColors.card, borderRadius: BorderRadius.circular(22), boxShadow: SanoShadows.soft),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: SanoColors.accent),
                    const SizedBox(width: 14),
                    Expanded(child: Text(text, style: textTheme.bodyLarge)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
