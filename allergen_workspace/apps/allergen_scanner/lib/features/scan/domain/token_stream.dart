import 'package:core_ocr/core_ocr.dart';

import '../../../core/text/text_normalizer.dart';

enum TextSource { original, translated }

class TextToken {
  const TextToken({
    required this.value,
    required this.block,
    this.box,
    this.endsSentence = false,
  });

  final String value;
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
      final words = [for (final line in block.lines) ...line.words];
      if (words.isEmpty) {
        _addRaw(tokens, block.text, b);
      } else {
        for (final word in words) {
          _addWord(tokens, word.text, b, word.box);
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

  static void _addRaw(List<TextToken> tokens, String text, int block) {
    for (final word in text.split(_whitespace)) {
      if (word.isNotEmpty) _addWord(tokens, word, block, null);
    }
  }

  static void _addWord(List<TextToken> tokens, String raw, int block, OcrBox? box) {
    final parts = TextNormalizer.tokens(raw);
    for (var i = 0; i < parts.length; i++) {
      tokens.add(TextToken(
        value: parts[i],
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
