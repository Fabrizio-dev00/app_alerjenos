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
}

extension ProfileSummary on Profile {
  String summary(AppLocalizations l10n) {
    final labels = [for (final choice in AllergenChoice.selectedIn(allergenIds)) choice.label(l10n)];
    return labels.isEmpty ? l10n.allergensNone : labels.join(', ');
  }
}
