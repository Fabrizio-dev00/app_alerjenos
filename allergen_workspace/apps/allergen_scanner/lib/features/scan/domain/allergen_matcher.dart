import 'dart:math' as math;

import 'package:core_ocr/core_ocr.dart';

import '../../../core/allergens/allergen_dictionary.dart';
import '../../../core/text/fuzzy_matcher.dart';
import 'token_stream.dart';

enum MatchLevel { mayContain, contains }

enum EvidenceKind { term, eCode, possibleTerm, possibleECode }

class AllergenEvidence {
  const AllergenEvidence({
    required this.allergenId,
    required this.kind,
    required this.term,
    required this.matchedText,
    required this.source,
    required this.inTraceContext,
    required this.blocks,
    required this.boxes,
    required this.distance,
  });

  final String allergenId;
  final EvidenceKind kind;
  final String term;
  final String matchedText;
  final TextSource source;
  final bool inTraceContext;
  final Set<int> blocks;
  final List<OcrBox> boxes;
  final int distance;

  bool get isPossible => kind == EvidenceKind.possibleTerm || kind == EvidenceKind.possibleECode;

  MatchLevel get level => inTraceContext || isPossible ? MatchLevel.mayContain : MatchLevel.contains;
}

class AllergenFinding {
  const AllergenFinding({required this.allergen, required this.evidence});

  final AllergenDefinition allergen;
  final List<AllergenEvidence> evidence;

  MatchLevel get level =>
      evidence.any((e) => e.level == MatchLevel.contains) ? MatchLevel.contains : MatchLevel.mayContain;

  bool get onlyPossible => evidence.every((e) => e.isPossible);
}

class AllergenMatcher {
  AllergenMatcher(this.dictionary)
      : _tracePhrases = [for (final phrase in dictionary.allTracePhrases.toSet()) phrase.split(' ')];

  static const traceWindow = 15;
  static final _eCode = RegExp(r'^e(\d{3,4})([a-z]?)$');
  static final _number = RegExp(r'^(\d{3,4})([a-z]?)$');
  static const _codePrefixes = {'e', 'ins', 'sin'};

  final AllergenDictionary dictionary;
  final List<List<String>> _tracePhrases;

  List<AllergenFinding> match(List<TokenStream> streams) {
    final evidence = <String, List<AllergenEvidence>>{};
    for (final stream in streams) {
      final values = stream.values;
      final trace = _traceMask(stream);
      final codes = _codes(values);
      for (final allergen in dictionary.allergens) {
        final found = _matchAllergen(allergen, stream, values, trace, codes);
        if (found.isNotEmpty) evidence.putIfAbsent(allergen.id, () => []).addAll(found);
      }
    }
    return [
      for (final allergen in dictionary.allergens)
        if (evidence[allergen.id] case final list?) AllergenFinding(allergen: allergen, evidence: list),
    ];
  }

  List<AllergenEvidence> _matchAllergen(
    AllergenDefinition allergen,
    TokenStream stream,
    List<String> values,
    List<bool> trace,
    Map<int, String> codes,
  ) {
    final excluded = _excludedMask(allergen, values);
    final found = <AllergenEvidence>[];
    final covered = List<bool>.filled(values.length, false);

    for (final term in allergen.allTerms.toSet()) {
      for (final match in FuzzyMatcher.findAll(values, term.split(' '), stopWords: dictionary.fuzzyStopWords)) {
        if (_any(excluded, match.start, match.length)) continue;
        _cover(covered, match.start, match.length);
        found.add(_evidence(allergen, EvidenceKind.term, term, stream, match.start, match.length, trace, match.distance));
      }
    }

    for (final MapEntry(key: index, value: code) in codes.entries) {
      if (allergen.eCodes.contains(code)) {
        _cover(covered, index, 1);
        found.add(_evidence(allergen, EvidenceKind.eCode, code, stream, index, 1, trace, 0));
      }
    }

    for (final term in allergen.allPossibleTerms.toSet()) {
      for (final match in FuzzyMatcher.findAll(values, term.split(' '), stopWords: dictionary.fuzzyStopWords)) {
        if (_any(excluded, match.start, match.length) || _any(covered, match.start, match.length)) continue;
        found.add(
          _evidence(allergen, EvidenceKind.possibleTerm, term, stream, match.start, match.length, trace, match.distance),
        );
      }
    }

    for (final MapEntry(key: index, value: code) in codes.entries) {
      if (allergen.possibleECodes.contains(code) && !covered[index]) {
        found.add(_evidence(allergen, EvidenceKind.possibleECode, code, stream, index, 1, trace, 0));
      }
    }
    return found;
  }

  AllergenEvidence _evidence(
    AllergenDefinition allergen,
    EvidenceKind kind,
    String term,
    TokenStream stream,
    int start,
    int length,
    List<bool> trace,
    int distance,
  ) {
    final tokens = stream.tokens.sublist(start, start + length);
    return AllergenEvidence(
      allergenId: allergen.id,
      kind: kind,
      term: term,
      matchedText: tokens.map((t) => t.raw).where((r) => r.isNotEmpty).join(' '),
      source: stream.source,
      inTraceContext: _all(trace, start, length),
      blocks: {for (final token in tokens) token.block},
      boxes: {for (final token in tokens) ?token.box}.toList(),
      distance: distance,
    );
  }

  List<bool> _traceMask(TokenStream stream) {
    final values = stream.values;
    final mask = List<bool>.filled(values.length, false);
    for (final phrase in _tracePhrases) {
      for (final match in FuzzyMatcher.findAll(values, phrase, stopWords: dictionary.fuzzyStopWords)) {
        final from = match.start + match.length;
        final end = math.min(values.length, from + traceWindow);
        for (var i = from; i < end; i++) {
          mask[i] = true;
          if (stream.tokens[i].endsSentence) break;
        }
      }
    }
    return mask;
  }

  List<bool> _excludedMask(AllergenDefinition allergen, List<String> values) {
    final mask = List<bool>.filled(values.length, false);
    for (final phrase in allergen.excludes) {
      final words = phrase.split(' ');
      for (var start = 0; start + words.length <= values.length; start++) {
        var equal = true;
        for (var i = 0; i < words.length && equal; i++) {
          equal = values[start + i] == words[i];
        }
        if (equal) _cover(mask, start, words.length);
      }
    }
    return mask;
  }

  static Map<int, String> _codes(List<String> values) {
    final codes = <int, String>{};
    for (var i = 0; i < values.length; i++) {
      final direct = _eCode.firstMatch(values[i]);
      if (direct != null) {
        codes[i] = 'E${direct.group(1)}${direct.group(2)!.toUpperCase()}';
        continue;
      }
      if (_codePrefixes.contains(values[i]) && i + 1 < values.length) {
        final number = _number.firstMatch(values[i + 1]);
        if (number != null) codes[i + 1] = 'E${number.group(1)}${number.group(2)!.toUpperCase()}';
      }
    }
    return codes;
  }

  static bool _any(List<bool> mask, int start, int length) {
    for (var i = start; i < start + length; i++) {
      if (mask[i]) return true;
    }
    return false;
  }

  static bool _all(List<bool> mask, int start, int length) {
    for (var i = start; i < start + length; i++) {
      if (!mask[i]) return false;
    }
    return true;
  }

  static void _cover(List<bool> mask, int start, int length) {
    for (var i = start; i < start + length; i++) {
      mask[i] = true;
    }
  }
}
