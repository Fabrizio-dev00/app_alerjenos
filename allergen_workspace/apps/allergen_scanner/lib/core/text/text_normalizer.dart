abstract final class TextNormalizer {
  static const _replacements = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
    'ß': 'ss', 'œ': 'oe', 'æ': 'ae',
  };

  static final _separators = RegExp(r'[^a-z0-9]+');

  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final char in input.toLowerCase().split('')) {
      buffer.write(_replacements[char] ?? char);
    }
    return buffer.toString().replaceAll(_separators, ' ').trim();
  }

  static List<String> tokens(String input) {
    final normalized = normalize(input);
    return normalized.isEmpty ? const [] : normalized.split(' ');
  }
}
