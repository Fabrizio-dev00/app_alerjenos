import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum SanoMood { happy, waving, surprised, worried, neutral }

class SanoMascot extends StatelessWidget {
  const SanoMascot({this.mood = SanoMood.happy, this.size = 120, super.key});

  final SanoMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size * 1.25,
        child: CustomPaint(painter: _SanoPainter(mood)),
      ),
    );
  }
}

class _SanoPainter extends CustomPainter {
  _SanoPainter(this.mood);

  final SanoMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 125);
    final ink = Paint()
      ..color = SanoColors.coffee
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = SanoColors.coffee;

    final leftArm = Path()
      ..moveTo(22, 64)
      ..quadraticBezierTo(10, 66, 10, 80);
    final rightArm = Path();
    if (mood == SanoMood.waving) {
      rightArm
        ..moveTo(78, 58)
        ..quadraticBezierTo(90, 50, 92, 30);
    } else {
      rightArm
        ..moveTo(78, 64)
        ..quadraticBezierTo(90, 66, 90, 80);
    }
    canvas
      ..drawPath(leftArm, ink)
      ..drawPath(rightArm, ink);

    for (final x in [36.0, 64.0]) {
      canvas
        ..drawLine(Offset(x, 98), Offset(x, 108), ink)
        ..drawOval(Rect.fromCenter(center: Offset(x, 112), width: 18, height: 10), Paint()..color = SanoColors.tangerine)
        ..drawOval(Rect.fromCenter(center: Offset(x, 112), width: 18, height: 10), ink..strokeWidth = 4);
    }
    ink.strokeWidth = 5;

    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(22, 8, 56, 92), const Radius.circular(16));
    canvas
      ..drawRRect(body, Paint()..color = SanoColors.card)
      ..drawRRect(body, ink)
      ..drawCircle(const Offset(50, 22), 4.5, ink..strokeWidth = 3.5);
    ink.strokeWidth = 4.5;

    final stripe = Paint()
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(const Offset(36, 80), const Offset(64, 80), stripe..color = SanoColors.orange)
      ..drawLine(const Offset(36, 88), const Offset(52, 88), stripe..color = SanoColors.tangerine);

    _face(canvas, ink, fill);
  }

  void _face(Canvas canvas, Paint ink, Paint fill) {
    final cheeks = Paint()..color = SanoColors.blush;
    switch (mood) {
      case SanoMood.happy || SanoMood.waving:
        canvas
          ..drawCircle(const Offset(41, 46), 4, fill)
          ..drawCircle(const Offset(59, 46), 4, fill)
          ..drawCircle(const Offset(33, 56), 4.5, cheeks)
          ..drawCircle(const Offset(67, 56), 4.5, cheeks)
          ..drawArc(const Rect.fromLTWH(40, 48, 20, 14), 0.2, math.pi - 0.4, false, ink);
      case SanoMood.surprised:
        canvas
          ..drawCircle(const Offset(41, 45), 4, fill)
          ..drawCircle(const Offset(59, 45), 4, fill)
          ..drawCircle(const Offset(50, 60), 4.5, ink..strokeWidth = 3.5);
      case SanoMood.worried:
        final mouth = Path()
          ..moveTo(40, 60)
          ..quadraticBezierTo(45, 54, 50, 60)
          ..quadraticBezierTo(55, 66, 60, 60);
        canvas
          ..drawCircle(const Offset(41, 46), 4, fill)
          ..drawCircle(const Offset(59, 46), 4, fill)
          ..drawPath(mouth, ink..strokeWidth = 3.5);
      case SanoMood.neutral:
        ink.strokeWidth = 4;
        canvas
          ..drawLine(const Offset(36, 46), const Offset(46, 46), ink)
          ..drawLine(const Offset(54, 46), const Offset(64, 46), ink)
          ..drawLine(const Offset(44, 59), const Offset(56, 59), ink);
    }
  }

  @override
  bool shouldRepaint(_SanoPainter oldDelegate) => oldDelegate.mood != mood;
}
