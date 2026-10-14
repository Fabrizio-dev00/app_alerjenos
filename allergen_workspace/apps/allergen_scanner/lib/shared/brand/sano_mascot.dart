import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum SanoMood { idle, waving, listening, happy, thinking, surprised, confused, sleepy, attentive }

class SanoMascot extends StatefulWidget {
  const SanoMascot({
    this.mood = SanoMood.idle,
    this.size = 120,
    this.crowned = false,
    this.sway = false,
    this.crownDrop = 1,
    super.key,
  });

  final double crownDrop;

  final SanoMood mood;
  final double size;
  final bool crowned;
  final bool sway;

  @override
  State<SanoMascot> createState() => _SanoMascotState();
}

class _SanoMascotState extends State<SanoMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _sway = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.mood == SanoMood.thinking ? 700 : 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(SanoMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    final animate = widget.sway && !SanoMotion.reduced(context);
    if (animate && !_sway.isAnimating) {
      _sway.repeat(reverse: true);
    } else if (!animate && _sway.isAnimating) {
      _sway.stop();
      _sway.value = 0.5;
    }
  }

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painted = CustomPaint(painter: _SanoPainter(widget.mood, widget.crowned, widget.crownDrop));
    return ExcludeSemantics(
      child: SizedBox(
        width: widget.size,
        height: widget.size * 1.35,
        child: widget.sway
            ? AnimatedBuilder(
                animation: _sway,
                builder: (context, child) => Transform.rotate(
                  angle: (Curves.easeInOut.transform(_sway.value) - 0.5) * 0.08,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
                child: painted,
              )
            : painted,
      ),
    );
  }
}

class _SanoPainter extends CustomPainter {
  _SanoPainter(this.mood, this.crowned, this.crownDrop);

  final SanoMood mood;
  final bool crowned;
  final double crownDrop;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(size.width / 100, size.height / 135)
      ..translate(0, 10);
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
    if (mood == SanoMood.waving || mood == SanoMood.idle || mood == SanoMood.listening) {
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
      final foot = Rect.fromCenter(center: Offset(x, 112), width: 18, height: 10);
      canvas
        ..drawLine(Offset(x, 98), Offset(x, 108), ink)
        ..drawOval(foot, Paint()..color = SanoColors.tangerine)
        ..drawOval(foot, Paint()
          ..color = SanoColors.coffee
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
    }

    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(22, 8, 56, 92), const Radius.circular(16));
    canvas
      ..drawRRect(body, Paint()..color = SanoColors.card)
      ..drawRRect(body, ink)
      ..drawCircle(const Offset(50, 22), 4.5, Paint()
        ..color = SanoColors.coffee
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5);

    final stripe = Paint()
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(const Offset(36, 80), const Offset(64, 80), stripe..color = SanoColors.orange)
      ..drawLine(const Offset(36, 88), const Offset(52, 88), stripe..color = SanoColors.tangerine);

    _face(canvas, fill);
    if (crowned) _crown(canvas);
  }

  Paint _line(double width) => Paint()
    ..color = SanoColors.coffee
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _face(Canvas canvas, Paint fill) {
    final cheeks = Paint()..color = SanoColors.blush;
    void eyes() => canvas
      ..drawCircle(const Offset(41, 46), 4, fill)
      ..drawCircle(const Offset(59, 46), 4, fill);
    void blush() => canvas
      ..drawCircle(const Offset(33, 56), 4.5, cheeks)
      ..drawCircle(const Offset(67, 56), 4.5, cheeks);

    switch (mood) {
      case SanoMood.idle || SanoMood.waving || SanoMood.happy:
        eyes();
        blush();
        canvas.drawArc(const Rect.fromLTWH(40, 48, 20, 14), 0.2, math.pi - 0.4, false, _line(4.5));
      case SanoMood.listening:
        eyes();
        blush();
        canvas.drawOval(Rect.fromCenter(center: const Offset(50, 60), width: 8, height: 10), fill);
      case SanoMood.surprised:
        eyes();
        canvas.drawCircle(const Offset(50, 60), 4.5, _line(3.5));
      case SanoMood.confused:
        eyes();
        final mouth = Path()
          ..moveTo(40, 60)
          ..quadraticBezierTo(45, 54, 50, 60)
          ..quadraticBezierTo(55, 66, 60, 60);
        canvas.drawPath(mouth, _line(3.5));
      case SanoMood.sleepy:
        canvas
          ..drawLine(const Offset(36, 46), const Offset(46, 46), _line(4))
          ..drawLine(const Offset(54, 46), const Offset(64, 46), _line(4))
          ..drawLine(const Offset(44, 59), const Offset(56, 59), _line(4));
      case SanoMood.thinking || SanoMood.attentive:
        eyes();
        canvas.drawLine(const Offset(44, 59), const Offset(56, 59), _line(4));
    }
  }

  void _crown(Canvas canvas) {
    canvas
      ..save()
      ..translate(50, 6 - (1 - crownDrop) * 40)
      ..rotate(6 * math.pi / 180);
    final crown = Path()
      ..moveTo(-16, 4)
      ..lineTo(-18, -12)
      ..lineTo(-8, -4)
      ..lineTo(0, -16)
      ..lineTo(8, -4)
      ..lineTo(18, -12)
      ..lineTo(16, 4)
      ..close();
    canvas
      ..drawPath(crown, Paint()..color = SanoColors.amber)
      ..drawPath(crown, _line(3));
    final jewel = Paint()..color = SanoColors.orange;
    for (final x in [-9.0, 0.0, 9.0]) {
      canvas.drawCircle(Offset(x, -1), 2.4, jewel);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SanoPainter oldDelegate) =>
      oldDelegate.mood != mood || oldDelegate.crowned != crowned || oldDelegate.crownDrop != crownDrop;
}
