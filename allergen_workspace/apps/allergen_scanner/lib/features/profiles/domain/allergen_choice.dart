enum AllergenChoice {
  milk(['milk']),
  eggs(['eggs']),
  gluten(['gluten']),
  peanuts(['peanuts']),
  treeNuts(['tree_nuts']),
  soy(['soy']),
  fish(['fish']),
  shellfish(['crustaceans', 'molluscs']),
  sesame(['sesame']),
  mustard(['mustard']),
  celery(['celery']),
  sulphites(['sulphites']),
  lactose(['lactose']),
  lupin(['lupin']);

  const AllergenChoice(this.allergenIds);

  final List<String> allergenIds;

  bool isSelectedIn(Set<String> selected) => allergenIds.every(selected.contains);

  Set<String> toggle(Set<String> selected) => isSelectedIn(selected)
      ? selected.difference(allergenIds.toSet())
      : {...selected, ...allergenIds};

  static List<AllergenChoice> selectedIn(Set<String> selected) =>
      [for (final choice in values) if (choice.isSelectedIn(selected)) choice];
}
