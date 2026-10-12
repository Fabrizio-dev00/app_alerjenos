import 'package:core_ocr/core_ocr.dart';

import '../../../core/text/fuzzy_matcher.dart';
import '../../../core/text/text_normalizer.dart';

class IngredientSection {
  const IngredientSection({required this.blockIndices, required this.text});

  static const none = IngredientSection(blockIndices: [], text: '');

  final List<int> blockIndices;
  final String text;

  bool get found => blockIndices.isNotEmpty;

  bool contains(int blockIndex) => blockIndices.contains(blockIndex);
}

abstract final class IngredientSectionLocator {
  static const _headers = ['ingredientes', 'ingredients', 'zutaten', 'ingredienti'];

  static const _stopPhrases = [
    'informacion nutricional',
    'nutrition facts',
    'valeurs nutritionnelles',
    'nahrwerte',
    'valori nutrizionali',
    'informacao nutricional',
    'conservese',
    'consumir antes',
    'best before',
    'registro sanitario',
  ];

  static const _tracePhrases = [
    'puede contener',
    'contiene',
    'may contain',
    'contains',
    'peut contenir',
    'kann spuren',
    'puo contenere',
    'pode conter',
  ];

  static const _headerWindow = 3;
  static const _maxGapInLines = 2.5;

  static IngredientSection locate(OcrResult ocr) {
    final start = _headerBlock(ocr);
    if (start == null) return IngredientSection.none;

    final indices = <int>[start];
    var bottom = ocr.blocks[start].box.bottom;
    final header = ocr.blocks[start].box;
    final lineHeight = _lineHeight(ocr.blocks[start]);

    final below = [
      for (var i = 0; i < ocr.blocks.length; i++)
        if (i != start && ocr.blocks[i].box.top >= header.top) i,
    ]..sort((a, b) => ocr.blocks[a].box.top.compareTo(ocr.blocks[b].box.top));

    for (final index in below) {
      final block = ocr.blocks[index];
      if (!_overlapsHorizontally(block.box, header)) continue;
      if (block.box.top - bottom > lineHeight * _maxGapInLines) break;
      if (_matchesAny(block.text, _stopPhrases)) break;
      indices.add(index);
      bottom = block.box.bottom > bottom ? block.box.bottom : bottom;
    }

    for (var i = 0; i < ocr.blocks.length; i++) {
      if (!indices.contains(i) && _matchesAny(ocr.blocks[i].text, _tracePhrases)) indices.add(i);
    }

    return IngredientSection(
      blockIndices: indices,
      text: [for (final i in indices) ocr.blocks[i].text].join('\n'),
    );
  }

  static int? _headerBlock(OcrResult ocr) {
    for (var i = 0; i < ocr.blocks.length; i++) {
      final tokens = TextNormalizer.tokens(ocr.blocks[i].text);
      final head = tokens.take(_headerWindow).toList();
      for (final header in _headers) {
        if (FuzzyMatcher.findPhrase(head, [header]) != null) return i;
      }
    }
    return null;
  }

  static bool _matchesAny(String text, List<String> phrases) {
    final tokens = TextNormalizer.tokens(text);
    return phrases.any((phrase) => FuzzyMatcher.findPhrase(tokens, phrase.split(' ')) != null);
  }

  static double _lineHeight(OcrBlock block) {
    if (block.lines.isEmpty) return block.box.height;
    return block.lines.map((line) => line.box.height).reduce((a, b) => a + b) / block.lines.length;
  }

  static bool _overlapsHorizontally(OcrBox a, OcrBox b) => a.left < b.right && b.left < a.right;
}
