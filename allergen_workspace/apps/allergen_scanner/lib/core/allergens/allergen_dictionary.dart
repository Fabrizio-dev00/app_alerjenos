import 'dart:convert';

import '../text/text_normalizer.dart';

typedef TermsByLanguage = Map<String, List<String>>;

TermsByLanguage _termsFrom(Object? json) {
  if (json == null) return const {};
  return {
    for (final entry in (json as Map<String, dynamic>).entries)
      entry.key: [for (final term in entry.value as List) TextNormalizer.normalize(term as String)],
  };
}

List<String> _codesFrom(Object? json) => [
      for (final code in (json as List?) ?? const []) (code as String).toUpperCase(),
    ];

class AllergenDefinition {
  const AllergenDefinition({
    required this.id,
    required this.names,
    required this.terms,
    this.possibleTerms = const {},
    this.eCodes = const [],
    this.possibleECodes = const [],
    this.excludes = const [],
  });

  factory AllergenDefinition.fromJson(Map<String, dynamic> json) => AllergenDefinition(
        id: json['id'] as String,
        names: (json['names'] as Map<String, dynamic>).cast<String, String>(),
        terms: _termsFrom(json['terms']),
        possibleTerms: _termsFrom(json['possibleTerms']),
        eCodes: _codesFrom(json['eCodes']),
        possibleECodes: _codesFrom(json['possibleECodes']),
        excludes: [
          for (final phrase in (json['excludes'] as List?) ?? const [])
            TextNormalizer.normalize(phrase as String),
        ],
      );

  final String id;
  final Map<String, String> names;
  final TermsByLanguage terms;
  final TermsByLanguage possibleTerms;
  final List<String> eCodes;
  final List<String> possibleECodes;
  final List<String> excludes;

  String nameFor(String languageCode) => names[languageCode] ?? names['en'] ?? id;

  Iterable<String> get allTerms => terms.values.expand((list) => list);

  Iterable<String> get allPossibleTerms => possibleTerms.values.expand((list) => list);
}

class AllergenDictionary {
  const AllergenDictionary({
    required this.version,
    required this.languages,
    required this.allergens,
    required this.tracePhrases,
    this.fuzzyStopWords = const {},
  });

  factory AllergenDictionary.fromJson(Map<String, dynamic> json) => AllergenDictionary(
        version: json['version'] as int,
        languages: (json['languages'] as List).cast<String>(),
        fuzzyStopWords: {
          for (final word in (json['fuzzyStopWords'] as List?) ?? const [])
            TextNormalizer.normalize(word as String),
        },
        tracePhrases: _termsFrom(json['tracePhrases']),
        allergens: [
          for (final entry in json['allergens'] as List)
            AllergenDefinition.fromJson(entry as Map<String, dynamic>),
        ],
      );

  factory AllergenDictionary.parse(String source) =>
      AllergenDictionary.fromJson(jsonDecode(source) as Map<String, dynamic>);

  final int version;
  final List<String> languages;
  final List<AllergenDefinition> allergens;
  final TermsByLanguage tracePhrases;
  final Set<String> fuzzyStopWords;

  AllergenDefinition? byId(String id) {
    for (final allergen in allergens) {
      if (allergen.id == id) return allergen;
    }
    return null;
  }

  Iterable<String> get allTracePhrases => tracePhrases.values.expand((list) => list);
}
