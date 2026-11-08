import 'dart:math';
import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.22;
    final radius = size.width / 2 - strokeWidth / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final outerRect = Rect.fromCircle(center: center, radius: radius);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(outerRect, -pi / 2, 1.05, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(outerRect, 0.55, 0.95, false, paint);

    paint.color = const Color(0xFFF4B400);
    canvas.drawArc(outerRect, 1.55, 0.55, false, paint);

    paint.color = const Color(0xFF0F9D58);
    canvas.drawArc(outerRect, 2.2, 1.6, false, paint);

    final fillPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.62, fillPaint);

    final rectWidth = size.width * 0.28;
    final rectHeight = size.height * 0.16;
    final rectOffset = Offset(center.dx + size.width * 0.05, center.dy - rectHeight / 2);
    final barRect = Rect.fromLTWH(rectOffset.dx, rectOffset.dy, rectWidth, rectHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(barRect, const Radius.circular(8)), fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
