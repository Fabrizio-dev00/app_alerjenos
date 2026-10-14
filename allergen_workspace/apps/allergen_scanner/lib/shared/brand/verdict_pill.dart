import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme.dart';

enum Verdict { contains, mayContain, notDetected }

class VerdictStyle {
  const VerdictStyle({required this.foreground, required this.background, required this.icon});

  final Color foreground;
  final Color background;
  final IconData icon;

  static VerdictStyle of(Verdict verdict) => switch (verdict) {
        Verdict.contains => const VerdictStyle(
            foreground: Colors.white,
            background: SanoColors.contains,
            icon: LucideIcons.circleX,
          ),
        Verdict.mayContain => const VerdictStyle(
            foreground: SanoColors.traces,
            background: SanoColors.tracesBg,
            icon: LucideIcons.triangleAlert,
          ),
        Verdict.notDetected => const VerdictStyle(
            foreground: SanoColors.coffee,
            background: SanoColors.card,
            icon: LucideIcons.searchCheck,
          ),
      };
}

class VerdictPill extends StatelessWidget {
  const VerdictPill({required this.verdict, required this.label, this.large = false, super.key});

  final Verdict verdict;
  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final style = VerdictStyle.of(verdict);
    final fontSize = large ? 28.0 : 15.0;
    final iconSize = large ? 30.0 : 17.0;
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 22, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 7);

    final content = Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.foreground, size: iconSize),
          SizedBox(width: large ? 12 : 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: large ? -0.5 : 0,
                color: style.foreground,
              ),
            ),
          ),
        ],
      ),
    );

    final radius = BorderRadius.circular(40);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: switch (verdict) {
        Verdict.contains => DecoratedBox(
            decoration: BoxDecoration(color: style.background, borderRadius: radius),
            child: content,
          ),
        Verdict.mayContain => CustomPaint(
            foregroundPainter: DashedBorderPainter(color: SanoColors.traces, radius: 40, strokeWidth: large ? 3 : 2),
            child: DecoratedBox(
              decoration: BoxDecoration(color: style.background, borderRadius: radius),
              child: content,
            ),
          ),
        Verdict.notDetected => DecoratedBox(
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: radius,
              border: Border.all(color: SanoColors.coffee, width: large ? 3 : 2),
            ),
            child: content,
          ),
      },
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 2,
    this.dotted = true,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final bool dotted;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = dotted ? StrokeCap.round : StrokeCap.butt;
    final rect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(strokeWidth / 2);
    final dash = dotted ? strokeWidth * 0.1 : strokeWidth * 3;
    final gap = dotted ? strokeWidth * 2.6 : strokeWidth * 2.5;
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
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dotted != dotted;
}

class DashedActionButton extends StatelessWidget {
  const DashedActionButton({required this.label, required this.onPressed, this.icon = Icons.add, super.key});

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: const DashedBorderPainter(color: SanoColors.accent, radius: 28, strokeWidth: 1.5, dotted: false),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: SanoColors.accent),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: SanoColors.accent, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
