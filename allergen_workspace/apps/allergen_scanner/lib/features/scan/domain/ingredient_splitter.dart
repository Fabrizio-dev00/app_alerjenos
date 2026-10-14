abstract final class IngredientSplitter {
  static final _header = RegExp(
    r'^\s*(ingredientes|ingredients|ingr[eé]dients|zutaten|ingredienti)\s*[:.]?\s*',
    caseSensitive: false,
  );
  static final _whitespace = RegExp(r'\s+');
  static const _open = {'(', '['};
  static const _close = {')', ']'};
  static const _separators = {',', ';'};

  static List<String> split(String text) {
    final flat = text.replaceAll(_whitespace, ' ').replaceFirst(_header, '');
    final parts = <String>[];
    final current = StringBuffer();
    var depth = 0;

    void flush() {
      final item = current.toString().trim().replaceAll(RegExp(r'[.\s]+$'), '');
      if (item.isNotEmpty) parts.add(item);
      current.clear();
    }

    for (final char in flat.split('')) {
      if (_open.contains(char)) depth++;
      if (_close.contains(char) && depth > 0) depth--;
      if (depth == 0 && (_separators.contains(char) || char == '.')) {
        flush();
        continue;
      }
      current.write(char);
    }
    flush();
    return parts;
  }
}
