import 'dart:io';

import 'package:core_ocr/core_ocr.dart';
import 'package:flutter/material.dart';

class OcrOverlay extends StatelessWidget {
  const OcrOverlay({
    required this.imagePath,
    required this.result,
    required this.selectedBlock,
    required this.onBlockTap,
    required this.imageErrorLabel,
    this.highlighted = const {},
    super.key,
  });

  final String imagePath;
  final OcrResult result;
  final int? selectedBlock;
  final ValueChanged<int?> onBlockTap;
  final String imageErrorLabel;
  final Set<int> highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return AspectRatio(
      aspectRatio: result.imageWidth / result.imageHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / result.imageWidth;
          return GestureDetector(
            onTapUp: (details) => onBlockTap(
              result.blockIndexAt(details.localPosition.dx / scale, details.localPosition.dy / scale),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(imagePath),
                  fit: BoxFit.fill,
                  cacheWidth: (constraints.maxWidth * pixelRatio).round(),
                  errorBuilder: (context, error, stackTrace) => Center(child: Text(imageErrorLabel)),
                ),
                CustomPaint(
                  painter: _BlocksPainter(
                    boxes: [for (final block in result.blocks) block.box.scale(scale)],
                    selected: selectedBlock,
                    highlighted: highlighted,
                    color: scheme.outline,
                    highlightColor: scheme.primary,
                    selectedColor: scheme.tertiary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BlocksPainter extends CustomPainter {
  _BlocksPainter({
    required this.boxes,
    required this.selected,
    required this.highlighted,
    required this.color,
    required this.highlightColor,
    required this.selectedColor,
  });

  final List<OcrBox> boxes;
  final int? selected;
  final Set<int> highlighted;
  final Color color;
  final Color highlightColor;
  final Color selectedColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < boxes.length; i++) {
      final box = boxes[i];
      final isSelected = i == selected;
      final isHighlighted = highlighted.contains(i);
      final base = isSelected ? selectedColor : (isHighlighted ? highlightColor : color);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(box.left, box.top, box.width, box.height).inflate(2),
        const Radius.circular(4),
      );
      canvas
        ..drawRRect(
          rect,
          Paint()..color = base.withValues(alpha: isSelected ? 0.3 : (isHighlighted ? 0.18 : 0.06)),
        )
        ..drawRRect(
          rect,
          Paint()
            ..color = base
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSelected || isHighlighted ? 3 : 1,
        );
    }
  }

  @override
  bool shouldRepaint(_BlocksPainter oldDelegate) =>
      oldDelegate.boxes != boxes ||
      oldDelegate.selected != selected ||
      oldDelegate.highlighted != highlighted ||
      oldDelegate.highlightColor != highlightColor ||
      oldDelegate.color != color ||
      oldDelegate.selectedColor != selectedColor;
}
