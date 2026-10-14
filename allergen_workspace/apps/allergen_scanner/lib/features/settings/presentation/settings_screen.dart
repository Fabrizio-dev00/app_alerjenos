import 'package:core_i18n/core_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/home_shell.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/sano_mascot.dart';
import '../../profiles/domain/profile.dart';
import '../../profiles/presentation/allergen_labels.dart';
import '../../profiles/presentation/profiles_providers.dart';
import 'app_settings.dart';
import 'locale_controller.dart';
import 'translation_models_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(localeControllerProvider);
    await showModalBottomSheet<void>(
      context: context,
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
    final pro = ref.watch(isProProvider);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final language = ref.watch(localeControllerProvider);
    final readyModels = ref.watch(translationModelsProvider).value?.downloaded.length;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, HomeShell.bottomInset(context)),
          children: [
            Text(l10n.navSettings, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 20),
            if (active != null)
              _ActiveProfileCard(
                profile: active,
                onTap: () => context.push(pro ? AppRoutes.profiles : AppRoutes.profileEditor(active.id)),
              ),
            const SizedBox(height: 20),
            if (pro) const _ProActiveCard() else _ProBanner(onTap: () => context.push(AppRoutes.pro)),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: SanoShadows.soft),
              child: Material(
                color: SanoColors.card,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (pro) ...[
                      _SettingsRow(
                        icon: LucideIcons.users,
                        title: l10n.profilesTitle,
                        value: l10n.profilesCount(profiles.length, ProfileLimits.pro),
                        onTap: () => context.push(AppRoutes.profiles),
                      ),
                      const Divider(indent: 72),
                    ],
                    _SettingsRow(
                      icon: LucideIcons.globe,
                      title: l10n.settingsLanguage,
                      value: language?.nativeName ?? l10n.settingsLanguageSystem,
                      onTap: () => _pickLanguage(context, ref),
                    ),
                    const Divider(indent: 72),
                    _SettingsRow(
                      icon: LucideIcons.download,
                      title: l10n.settingsOfflineLanguages,
                      value: readyModels == null ? null : l10n.settingsOfflineReady(readyModels),
                      onTap: () => context.push(AppRoutes.scanLanguages),
                    ),
                    const Divider(indent: 72),
                    _SettingsRow(
                      icon: LucideIcons.shield,
                      title: l10n.settingsPrivacy,
                      value: l10n.settingsPrivacyValue,
                      onTap: () => context.push(AppRoutes.privacy),
                    ),
                    const Divider(indent: 72),
                    _SettingsRow(
                      icon: LucideIcons.history,
                      title: l10n.settingsSaveHistory,
                      trailing: Switch(
                        value: settings.saveHistory,
                        onChanged: ref.read(appSettingsProvider.notifier).setSaveHistory,
                      ),
                    ),
                    const Divider(indent: 72),
                    _SettingsRow(
                      icon: LucideIcons.vibrate,
                      title: l10n.settingsVibrate,
                      trailing: Switch(
                        value: settings.vibrate,
                        onChanged: ref.read(appSettingsProvider.notifier).setVibrate,
                      ),
                    ),
                    const Divider(indent: 72),
                    _SettingsRow(
                      icon: LucideIcons.info,
                      title: l10n.settingsAbout,
                      value: l10n.settingsVersion(AppInfo.version),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveProfileCard extends StatelessWidget {
  const _ActiveProfileCard({required this.profile, required this.onTap});

  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: SanoColors.card,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: SanoColors.accent, width: 3)),
                child: Text(profile.initial, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: SanoColors.accent)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.activeProfile, style: textTheme.bodyMedium?.copyWith(color: SanoColors.muted)),
                    Text(profile.name, overflow: TextOverflow.ellipsis, style: textTheme.headlineMedium),
                    Text(profile.summary(l10n), maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodyLarge),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight),
            ],
          ),
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
      decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(28), boxShadow: SanoShadows.brand),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: SanoColors.paper),
                  child: const Icon(LucideIcons.star, color: SanoColors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.proBannerTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      Text(l10n.proBannerSubtitle, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProActiveCard extends StatelessWidget {
  const _ProActiveCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [SanoColors.coffee, Color(0xFF5A2A0E)]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: SanoColors.brandGradient),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: FittedBox(child: SanoMascot(mood: SanoMood.happy, size: 60, crowned: true)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l10n.proBannerTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: SanoColors.card)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(14)),
                      child: Text(l10n.proActive, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(l10n.proActiveBody, style: const TextStyle(color: SanoColors.amber, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.title, this.value, this.onTap, this.trailing});

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minTileHeight: 72,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: SanoColors.card, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(value!, overflow: TextOverflow.ellipsis, style: const TextStyle(color: SanoColors.muted, fontSize: 16)),
                ),
              if (onTap != null) ...[const SizedBox(width: 6), const Icon(LucideIcons.chevronRight)],
            ],
          ),
    );
  }
}
