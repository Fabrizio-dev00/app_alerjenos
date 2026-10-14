import 'package:core_ocr/core_ocr.dart';

import '../../../core/text/text_normalizer.dart';

enum TextSource { original, translated }

class TextToken {
  const TextToken({
    required this.value,
    required this.block,
    this.raw = '',
    this.box,
    this.endsSentence = false,
  });

  final String value;
  final String raw;
  final int block;
  final OcrBox? box;
  final bool endsSentence;
}

class TokenStream {
  const TokenStream(this.source, this.tokens);

  factory TokenStream.fromOcr(OcrResult ocr) {
    final tokens = <TextToken>[];
    for (var b = 0; b < ocr.blocks.length; b++) {
      final block = ocr.blocks[b];
      if (block.lines.isEmpty) {
        _addRaw(tokens, block.text, b, block.box);
        continue;
      }
      for (final line in block.lines) {
        if (line.words.isEmpty) {
          _addRaw(tokens, line.text, b, line.box);
        } else {
          for (final word in line.words) {
            _addWord(tokens, word.text, b, word.box);
          }
        }
      }
    }
    return TokenStream(TextSource.original, tokens);
  }

  factory TokenStream.fromTranslatedBlocks(List<String> blocks) {
    final tokens = <TextToken>[];
    for (var b = 0; b < blocks.length; b++) {
      _addRaw(tokens, blocks[b], b);
    }
    return TokenStream(TextSource.translated, tokens);
  }

  static final _whitespace = RegExp(r'\s+');
  static final _sentenceEnd = RegExp(r'[.;!?]\W*$');

  static void _addRaw(List<TextToken> tokens, String text, int block, [OcrBox? box]) {
    for (final word in text.split(_whitespace)) {
      if (word.isNotEmpty) _addWord(tokens, word, block, box);
    }
  }

  static final _edgePunctuation = RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true);

  static void _addWord(List<TextToken> tokens, String raw, int block, OcrBox? box) {
    final parts = TextNormalizer.tokens(raw);
    final cleaned = raw.replaceAll(_edgePunctuation, '');
    for (var i = 0; i < parts.length; i++) {
      tokens.add(TextToken(
        value: parts[i],
        raw: i == 0 ? cleaned : '',
        block: block,
        box: box,
        endsSentence: i == parts.length - 1 && _sentenceEnd.hasMatch(raw),
      ));
    }
  }

  final TextSource source;
  final List<TextToken> tokens;

  List<String> get values => [for (final token in tokens) token.value];
}
