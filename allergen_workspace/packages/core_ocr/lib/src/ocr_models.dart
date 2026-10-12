class OcrBox {
  const OcrBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;

  bool contains(double x, double y) => x >= left && x <= right && y >= top && y <= bottom;

  OcrBox scale(double factor) => OcrBox(
        left: left * factor,
        top: top * factor,
        width: width * factor,
        height: height * factor,
      );

  @override
  bool operator ==(Object other) =>
      other is OcrBox &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() => 'OcrBox($left, $top, $width x $height)';
}

class OcrWord {
  const OcrWord({required this.text, required this.box});

  final String text;
  final OcrBox box;
}

class OcrLine {
  const OcrLine({required this.text, required this.box, this.words = const []});

  final String text;
  final OcrBox box;
  final List<OcrWord> words;
}

class OcrBlock {
  const OcrBlock({
    required this.text,
    required this.box,
    this.lines = const [],
    this.languages = const [],
  });

  final String text;
  final OcrBox box;
  final List<OcrLine> lines;
  final List<String> languages;
}

class OcrResult {
  const OcrResult({
    required this.text,
    required this.blocks,
    required this.imageWidth,
    required this.imageHeight,
  });

  final String text;
  final List<OcrBlock> blocks;
  final double imageWidth;
  final double imageHeight;

  bool get isEmpty => text.trim().isEmpty || blocks.isEmpty;

  int? blockIndexAt(double x, double y) {
    for (var i = blocks.length - 1; i >= 0; i--) {
      if (blocks[i].box.contains(x, y)) return i;
    }
    return null;
  }
}
