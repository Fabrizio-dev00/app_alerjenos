import 'package:flutter/material.dart';

class ScanCheckIcon extends StatelessWidget {
  const ScanCheckIcon({required this.size, required this.color, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: size, child: CustomPaint(painter: _ScanCheckPainter(color)));
  }
}

class _ScanCheckPainter extends CustomPainter {
  _ScanCheckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawCircle(Offset(10 * s, 10 * s), 7 * s, paint)
      ..drawLine(Offset(15.5 * s, 15.5 * s), Offset(21 * s, 21 * s), paint);
    final check = Path()
      ..moveTo(6.8 * s, 10.2 * s)
      ..lineTo(9.2 * s, 12.6 * s)
      ..lineTo(13.4 * s, 7.8 * s);
    canvas.drawPath(check, paint);
  }

  @override
  bool shouldRepaint(_ScanCheckPainter oldDelegate) => oldDelegate.color != color;
}
