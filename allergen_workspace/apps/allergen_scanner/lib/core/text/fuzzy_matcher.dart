import 'dart:math' as math;

import 'text_normalizer.dart';

class FuzzyMatch {
  const FuzzyMatch({required this.start, required this.length, required this.distance});

  final int start;
  final int length;
  final int distance;
}

abstract final class FuzzyMatcher {
  static int allowedDistance(String term) {
    if (term.length <= 4) return 0;
    if (term.length <= 7) return 1;
    return 2;
  }

  static int levenshtein(String a, String b, {int? max}) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    if (max != null && (a.length - b.length).abs() > max) return max + 1;

    var previous = List<int>.generate(b.length + 1, (i) => i);
    var current = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      current[0] = i;
      var rowMin = current[0];
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        current[j] = math.min(math.min(current[j - 1] + 1, previous[j] + 1), previous[j - 1] + cost);
        rowMin = math.min(rowMin, current[j]);
      }
      if (max != null && rowMin > max) return max + 1;
      final swap = previous;
      previous = current;
      current = swap;
    }
    return previous[b.length];
  }

  static FuzzyMatch? findPhrase(List<String> tokens, List<String> phrase) {
    if (phrase.isEmpty || tokens.length < phrase.length) return null;
    final target = phrase.join(' ');
    final allowed = allowedDistance(target);
    FuzzyMatch? best;
    for (var start = 0; start + phrase.length <= tokens.length; start++) {
      final window = tokens.sublist(start, start + phrase.length).join(' ');
      final distance = levenshtein(window, target, max: allowed);
      if (distance <= allowed && (best == null || distance < best.distance)) {
        best = FuzzyMatch(start: start, length: phrase.length, distance: distance);
        if (distance == 0) break;
      }
    }
    return best;
  }

  static Iterable<FuzzyMatch> findAll(
    List<String> tokens,
    List<String> phrase, {
    Set<String> stopWords = const {},
  }) sync* {
    if (phrase.isEmpty || tokens.length < phrase.length) return;
    final target = phrase.join(' ');
    final allowed = allowedDistance(target);
    for (var start = 0; start + phrase.length <= tokens.length; start++) {
      final windowTokens = tokens.sublist(start, start + phrase.length);
      final window = windowTokens.join(' ');
      if (window == target) {
        yield FuzzyMatch(start: start, length: phrase.length, distance: 0);
        continue;
      }
      if (allowed == 0 || windowTokens.any(stopWords.contains)) continue;
      final distance = levenshtein(window, target, max: allowed);
      if (distance <= allowed) yield FuzzyMatch(start: start, length: phrase.length, distance: distance);
    }
  }

  static bool containsPhrase(String text, String phrase) =>
      findPhrase(TextNormalizer.tokens(text), TextNormalizer.tokens(phrase)) != null;
}
