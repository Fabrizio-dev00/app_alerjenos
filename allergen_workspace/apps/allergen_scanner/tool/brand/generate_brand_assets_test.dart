import 'dart:io';
import 'dart:ui' as ui;

import 'package:allergen_scanner/app/theme.dart';
import 'package:allergen_scanner/shared/brand/sano_mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class _SearchCheckPainter extends CustomPainter {
  _SearchCheckPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width * scale / 24;
    canvas.translate((size.width - 24 * s) / 2, (size.height - 24 * s) / 2);
    final paint = Paint()
      ..color = SanoColors.card
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawCircle(Offset(10.5 * s, 10.5 * s), 7.5 * s, paint)
      ..drawLine(Offset(16.2 * s, 16.2 * s), Offset(21.5 * s, 21.5 * s), paint)
      ..drawPath(
        Path()
          ..moveTo(7 * s, 10.8 * s)
          ..lineTo(9.6 * s, 13.4 * s)
          ..lineTo(14.2 * s, 8.2 * s),
        paint,
      );
  }

  @override
  bool shouldRepaint(_SearchCheckPainter oldDelegate) => false;
}

Future<void> _render(WidgetTester tester, Widget child, String path, {double size = 512}) async {
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(Size(size, size));
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: RepaintBoundary(key: key, child: SizedBox.square(dimension: size, child: child))),
    ),
  );
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1024 / size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  const out = 'assets/brand';
  const gradient = DecoratedBox(decoration: BoxDecoration(gradient: SanoColors.brandGradient));

  testWidgets('genera el ícono, sus capas adaptativas y el splash', (tester) async {
    await _render(
      tester,
      Stack(fit: StackFit.expand, children: [gradient, CustomPaint(painter: _SearchCheckPainter(scale: 0.62))]),
      '$out/icon.png',
    );
    await _render(tester, gradient, '$out/icon_background.png');
    await _render(tester, CustomPaint(painter: _SearchCheckPainter(scale: 0.4)), '$out/icon_foreground.png');
    await _render(tester, const Center(child: SanoMascot(mood: SanoMood.idle, size: 300)), '$out/splash.png');
    await _render(
      tester,
      const Center(child: SanoMascot(mood: SanoMood.idle, size: 300, crowned: true)),
      '$out/splash_pro.png',
    );
  });
}
