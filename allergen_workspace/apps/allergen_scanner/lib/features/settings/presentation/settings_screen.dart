import 'package:core_i18n/core_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'locale_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(localeControllerProvider);
    final controller = ref.read(localeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.settingsScanLanguages),
            subtitle: Text(l10n.settingsScanLanguagesSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.scanLanguages),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.settingsLanguage, style: Theme.of(context).textTheme.titleSmall),
          ),
          RadioGroup<AppLanguage?>(
            groupValue: selected,
            onChanged: controller.select,
            child: Column(
              children: [
                RadioListTile<AppLanguage?>(value: null, title: Text(l10n.settingsLanguageSystem)),
                for (final language in AppLanguage.interfaceLanguages)
                  RadioListTile<AppLanguage?>(value: language, title: Text(language.nativeName)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
