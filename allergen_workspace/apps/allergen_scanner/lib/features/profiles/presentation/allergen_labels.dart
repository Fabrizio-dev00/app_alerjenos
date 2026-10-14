import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/allergen_choice.dart';
import '../domain/profile.dart';

extension AllergenChoiceLabel on AllergenChoice {
  String label(AppLocalizations l10n) => switch (this) {
        AllergenChoice.milk => l10n.allergenMilk,
        AllergenChoice.eggs => l10n.allergenEggs,
        AllergenChoice.gluten => l10n.allergenGluten,
        AllergenChoice.peanuts => l10n.allergenPeanuts,
        AllergenChoice.treeNuts => l10n.allergenTreeNuts,
        AllergenChoice.soy => l10n.allergenSoy,
        AllergenChoice.fish => l10n.allergenFish,
        AllergenChoice.shellfish => l10n.allergenShellfish,
        AllergenChoice.sesame => l10n.allergenSesame,
        AllergenChoice.mustard => l10n.allergenMustard,
        AllergenChoice.celery => l10n.allergenCelery,
        AllergenChoice.sulphites => l10n.allergenSulphites,
        AllergenChoice.lactose => l10n.allergenLactose,
        AllergenChoice.lupin => l10n.allergenLupin,
      };

  IconData get icon => switch (this) {
        AllergenChoice.milk => LucideIcons.milk,
        AllergenChoice.eggs => LucideIcons.egg,
        AllergenChoice.gluten => LucideIcons.wheat,
        AllergenChoice.peanuts => LucideIcons.bean,
        AllergenChoice.treeNuts => LucideIcons.nut,
        AllergenChoice.soy => LucideIcons.sprout,
        AllergenChoice.fish => LucideIcons.fish,
        AllergenChoice.shellfish => LucideIcons.shell,
        AllergenChoice.sesame => LucideIcons.cookie,
        AllergenChoice.mustard => LucideIcons.droplet,
        AllergenChoice.celery => LucideIcons.leaf,
        AllergenChoice.sulphites => LucideIcons.wine,
        AllergenChoice.lactose => LucideIcons.milkOff,
        AllergenChoice.lupin => LucideIcons.flower2,
      };
}

extension ProfileSummary on Profile {
  List<AllergenChoice> get choices => AllergenChoice.selectedIn(allergenIds);

  String summary(AppLocalizations l10n) {
    final labels = [for (final choice in choices) choice.label(l10n)];
    if (labels.isEmpty) return l10n.allergensNone;
    if (labels.length == 1) return labels.single;
    return l10n.listAnd(labels.sublist(0, labels.length - 1).join(', '), labels.last);
  }

  String get initial => name.isEmpty ? '?' : name.characters.first.toUpperCase();
}
