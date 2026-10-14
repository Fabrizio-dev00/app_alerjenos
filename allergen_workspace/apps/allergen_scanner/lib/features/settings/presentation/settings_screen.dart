import 'package:core_i18n/core_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../profiles/presentation/profiles_providers.dart';
import '../../profiles/presentation/profiles_screen.dart';
import 'locale_controller.dart';
import 'translation_models_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(localeControllerProvider);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: RadioGroup<AppLanguage?>(
          groupValue: current,
          onChanged: (language) {
            ref.read(localeControllerProvider.notifier).select(language);
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppLanguage?>(value: null, title: Text(l10n.settingsLanguageSystem)),
              for (final language in AppLanguage.interfaceLanguages)
                RadioListTile<AppLanguage?>(value: language, title: Text(language.nativeName)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeProfileProvider);
    final language = ref.watch(localeControllerProvider);
    final readyModels = ref.watch(translationModelsProvider).value?.downloaded.length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Text(l10n.navSettings, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 20),
            if (active != null)
              ProfileCard(
                profile: active,
                active: true,
                caption: l10n.activeProfile,
                onTap: () => context.push(AppRoutes.profiles),
              ),
            const SizedBox(height: 20),
            _ProBanner(onTap: () => context.push(AppRoutes.paywall)),
            const SizedBox(height: 20),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.language,
                    title: l10n.settingsLanguage,
                    value: language?.nativeName ?? l10n.settingsLanguageSystem,
                    onTap: () => _pickLanguage(context, ref),
                  ),
                  const Divider(),
                  _SettingsRow(
                    icon: Icons.download_outlined,
                    title: l10n.settingsScanLanguages,
                    value: readyModels == null ? null : l10n.settingsOfflineReady(readyModels),
                    onTap: () => context.push(AppRoutes.scanLanguages),
                  ),
                  const Divider(),
                  _SettingsRow(
                    icon: Icons.info_outline,
                    title: l10n.settingsAbout,
                    value: l10n.settingsVersion(AppInfo.version),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBanner extends StatelessWidget {
  const _ProBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(24)),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: SanoColors.card),
                  child: const Icon(Icons.star_outline, color: SanoColors.orange),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.proBannerTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(l10n.proBannerSubtitle),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.title, this.value, this.onTap});

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: SanoColors.card, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(value!, overflow: TextOverflow.ellipsis, style: const TextStyle(color: SanoColors.muted)),
            ),
          if (onTap != null) const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
