import 'dart:math' as math;
import 'package:flutter/material.dart';

enum StripeDirection { leftToRight, rightToLeft }

class AppStripePainter extends CustomPainter {
  final Color stripeColor;
  final Color? backgroundColor;
  final double spacing;
  final double strokeWidth;
  final double angleDegrees;
  final StripeDirection direction;

  const AppStripePainter({
    required this.stripeColor,
    this.backgroundColor,
    this.spacing = 6.0,
    this.strokeWidth = 1.5,
    this.angleDegrees = 45.0,
    this.direction = StripeDirection.leftToRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = backgroundColor!,
      );
    }

    final linePaint = Paint()
      ..color = stripeColor
      ..strokeWidth = strokeWidth;

    final rad = angleDegrees * math.pi / 180.0;
    final run = size.height / math.tan(rad);

    var x = -size.height.toDouble();
    while (x < size.width + size.height) {
      if (direction == StripeDirection.leftToRight) {
        canvas.drawLine(Offset(x, size.height), Offset(x + run, 0), linePaint);
      } else {
        canvas.drawLine(Offset(x + run, size.height), Offset(x, 0), linePaint);
      }
      x += spacing;
    }
  }

  @override
  bool shouldRepaint(AppStripePainter old) =>
      old.stripeColor != stripeColor ||
      old.backgroundColor != backgroundColor ||
      old.spacing != spacing ||
      old.strokeWidth != strokeWidth ||
      old.angleDegrees != angleDegrees ||
      old.direction != direction;
}
