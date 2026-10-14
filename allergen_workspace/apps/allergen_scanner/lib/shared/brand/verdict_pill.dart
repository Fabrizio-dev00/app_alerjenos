import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'scan_check_icon.dart';

enum Verdict { contains, mayContain, notDetected }

class VerdictPill extends StatelessWidget {
  const VerdictPill({required this.verdict, required this.label, this.large = false, super.key});

  final Verdict verdict;
  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final fontSize = large ? 34.0 : 16.0;
    final iconSize = large ? 34.0 : 18.0;
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 6);

    final (Color foreground, Color background, Widget icon) = switch (verdict) {
      Verdict.contains => (Colors.white, SanoColors.contains, Icon(Icons.cancel_outlined, color: Colors.white, size: iconSize)),
      Verdict.mayContain => (SanoColors.traces, SanoColors.card, Icon(Icons.warning_amber_rounded, color: SanoColors.traces, size: iconSize)),
      Verdict.notDetected => (SanoColors.coffee, SanoColors.card, ScanCheckIcon(size: iconSize, color: SanoColors.coffee)),
    };

    final content = Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: large ? 12 : 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: large ? -0.8 : 0,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: switch (verdict) {
        Verdict.contains => DecoratedBox(
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(40)),
            child: content,
          ),
        Verdict.mayContain => CustomPaint(
            painter: DashedBorderPainter(color: SanoColors.traces, radius: 40, strokeWidth: large ? 3 : 2),
            child: DecoratedBox(
              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(40)),
              child: content,
            ),
          ),
        Verdict.notDetected => DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: SanoColors.coffee, width: large ? 3 : 2),
            ),
            child: content,
          ),
      },
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({required this.color, required this.radius, this.strokeWidth = 2});

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(strokeWidth / 2);
    final dash = strokeWidth * 0.1;
    final gap = strokeWidth * 2.6;
    for (final PathMetric metric in (Path()..addRRect(rect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius || oldDelegate.strokeWidth != strokeWidth;
}
