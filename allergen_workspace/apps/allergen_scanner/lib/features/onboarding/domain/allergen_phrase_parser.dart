import '../../../core/allergens/allergen_dictionary.dart';
import '../../../core/text/fuzzy_matcher.dart';
import '../../../core/text/text_normalizer.dart';
import '../../profiles/domain/allergen_choice.dart';

class AllergenPhraseParser {
  AllergenPhraseParser(AllergenDictionary dictionary)
      : _stopWords = dictionary.fuzzyStopWords,
        _keywords = _buildKeywords(dictionary);

  static const _aliases = {
    AllergenChoice.gluten: ['celiaco', 'celiaca', 'celiaquia', 'celiac', 'coeliac', 'celiaque', 'zoliakie', 'celiachia'],
    AllergenChoice.shellfish: [
      'mariscos', 'marisco', 'shellfish', 'seafood', 'fruits de mer', 'meeresfruchte', 'frutti di mare', 'frutos do mar',
      'frutos del mar',
    ],
    AllergenChoice.peanuts: ['cacahuate', 'cacahuete', 'mani', 'peanut', 'peanuts'],
    AllergenChoice.treeNuts: ['nueces', 'nuez', 'frutos secos', 'nuts', 'tree nuts', 'fruits a coque'],
    AllergenChoice.eggs: ['huevo', 'huevos', 'egg', 'eggs'],
    AllergenChoice.lupin: ['altramuz', 'tarwi', 'chocho', 'lupin', 'lupino'],
  };

  static const _lactoseOnly = ['lactosa', 'lactose', 'laktose', 'lattosio', 'milchzucker', 'intolerante a la lactosa'];

  static const _spanishSoyFollowers = {
    'alergico', 'alergica', 'alergicos', 'alergicas', 'intolerante', 'celiaco', 'celiaca', 'sensible', 'vegano',
    'vegana', 'de', 'muy', 'un', 'una', 'el', 'la', 'mama', 'papa', 'padre', 'madre',
  };

  final Set<String> _stopWords;
  final Map<AllergenChoice, List<List<String>>> _keywords;

  static Map<AllergenChoice, List<List<String>>> _buildKeywords(AllergenDictionary dictionary) {
    final keywords = <AllergenChoice, Set<String>>{};
    for (final choice in AllergenChoice.values) {
      final terms = keywords.putIfAbsent(choice, () => {});
      if (choice == AllergenChoice.lactose) {
        terms.addAll(_lactoseOnly.map(TextNormalizer.normalize));
        continue;
      }
      for (final id in choice.allergenIds) {
        final allergen = dictionary.byId(id);
        if (allergen != null) terms.addAll(allergen.allTerms);
      }
      terms.addAll((_aliases[choice] ?? const []).map(TextNormalizer.normalize));
    }
    keywords[AllergenChoice.milk]!.removeAll(_lactoseOnly.map(TextNormalizer.normalize));
    return {
      for (final entry in keywords.entries) entry.key: [for (final term in entry.value) term.split(' ')],
    };
  }

  Set<String> parse(String phrase) {
    final tokens = [...TextNormalizer.tokens(phrase)];
    for (var i = 0; i < tokens.length; i++) {
      final next = i + 1 < tokens.length ? tokens[i + 1] : null;
      final previous = i > 0 ? tokens[i - 1] : null;
      if (tokens[i] == 'soy' && (_spanishSoyFollowers.contains(next) || previous == 'yo')) tokens[i] = '';
    }
    final found = <String>{};
    for (final MapEntry(key: choice, value: terms) in _keywords.entries) {
      for (final term in terms) {
        if (FuzzyMatcher.findAll(tokens, term, stopWords: _stopWords).isNotEmpty) {
          found.addAll(choice.allergenIds);
          break;
        }
      }
    }
    return found;
  }
}
