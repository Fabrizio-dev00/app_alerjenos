import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/sano_mascot.dart';
import '../../profiles/presentation/profiles_providers.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).linkFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final spanish = Localizations.localeOf(context).languageCode == 'es';

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
          Center(child: SanoMascot(mood: SanoMood.happy, size: 96, crowned: ref.watch(isProProvider))),
          const SizedBox(height: 12),
          Text(l10n.appTitle, textAlign: TextAlign.center, style: textTheme.headlineLarge),
          Text(l10n.settingsVersion(AppInfo.version), textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: SanoColors.muted)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: SanoColors.coffee, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.info, color: SanoColors.card),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l10n.disclaimerTitle, style: const TextStyle(color: SanoColors.card, fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(l10n.disclaimerBody, style: const TextStyle(color: SanoColors.card, fontSize: 16, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: SanoColors.card,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  minTileHeight: 64,
                  leading: const Icon(LucideIcons.shield, color: SanoColors.accent),
                  title: Text(l10n.privacyPolicy, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: const Icon(LucideIcons.externalLink, size: 20),
                  onTap: () => _open(context, Uri.parse(spanish ? AppInfo.privacyUrlEs : AppInfo.privacyUrlEn)),
                ),
                const Divider(indent: 56),
                ListTile(
                  minTileHeight: 64,
                  leading: const Icon(LucideIcons.fileText, color: SanoColors.accent),
                  title: Text(l10n.termsOfUse, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: const Icon(LucideIcons.externalLink, size: 20),
                  onTap: () => _open(context, Uri.parse(spanish ? AppInfo.termsUrlEs : AppInfo.termsUrlEn)),
                ),
                if (AppInfo.supportEmail.isNotEmpty) ...[
                  const Divider(indent: 56),
                  ListTile(
                    minTileHeight: 64,
                    leading: const Icon(LucideIcons.mail, color: SanoColors.accent),
                    title: Text(l10n.contactSupport, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text(AppInfo.supportEmail),
                    onTap: () => _open(context, Uri(scheme: 'mailto', path: AppInfo.supportEmail, query: 'subject=SanoScan')),
                  ),
                ],
                const Divider(indent: 56),
                ListTile(
                  minTileHeight: 64,
                  leading: const Icon(LucideIcons.code, color: SanoColors.accent),
                  title: Text(l10n.openSourceLicenses, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: AppInfo.version,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.madeWithCare, textAlign: TextAlign.center, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
