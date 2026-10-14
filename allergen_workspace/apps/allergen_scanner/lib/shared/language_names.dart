import '../l10n/generated/app_localizations.dart';

String languageName(AppLocalizations l10n, String? code) => switch (code?.split('-').first) {
      'es' => l10n.langEs,
      'en' => l10n.langEn,
      'fr' => l10n.langFr,
      'de' => l10n.langDe,
      'it' => l10n.langIt,
      'pt' => l10n.langPt,
      'ja' => l10n.langJa,
      'ko' => l10n.langKo,
      'zh' => l10n.langZh,
      'nl' => l10n.langNl,
      null => l10n.langUnknown,
      final other => other.toUpperCase(),
    };
