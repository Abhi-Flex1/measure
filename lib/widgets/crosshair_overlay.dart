import 'package:flutter/material.dart';

class CrosshairOverlay extends StatelessWidget {
  final double size;
  final Color color;
  final bool isActive;

  const CrosshairOverlay({
    super.key,
    this.size = 100.0,
    this.color = Colors.white,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: CustomPaint(
        size: Size(size, size),
        painter: _CrosshairPainter(
          color: isActive ? color : color.withAlpha(100),
          isActive: isActive,
        ),
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _CrosshairPainter({
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring
    final outerRingPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, outerRingPaint);

    // Inner ring (thinner)
    final innerRingPaint = Paint()
      ..color = color.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.6, innerRingPaint);

    // Crosshair segments (4 lines with gaps)
    final crosshairPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final outerCrossRadius = radius * 0.85;
    final innerCrossRadius = radius * 0.25;

    // Top
    canvas.drawLine(
      Offset(center.dx, center.dy - innerCrossRadius),
      Offset(center.dx, center.dy - outerCrossRadius),
      crosshairPaint,
    );
    // Bottom
    canvas.drawLine(
      Offset(center.dx, center.dy + innerCrossRadius),
      Offset(center.dx, center.dy + outerCrossRadius),
      crosshairPaint,
    );
    // Left
    canvas.drawLine(
      Offset(center.dx - innerCrossRadius, center.dy),
      Offset(center.dx - outerCrossRadius, center.dy),
      crosshairPaint,
    );
    // Right
    canvas.drawLine(
      Offset(center.dx + innerCrossRadius, center.dy),
      Offset(center.dx + outerCrossRadius, center.dy),
      crosshairPaint,
    );

    // Center dot
    final dotPaint = Paint()
      ..color = isActive ? color : color.withAlpha(100)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, dotPaint);

    // Corner brackets (like Apple Measure app)
    _drawCornerBrackets(canvas, center, radius, color);
  }

  void _drawCornerBrackets(Canvas canvas, Offset center, double radius, Color color) {
    final bracketPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final bracketSize = radius * 0.35;
    final bracketOffset = radius * 0.75;

    // Top-left corner
    canvas.drawLine(
      Offset(center.dx - bracketOffset, center.dy - bracketOffset),
      Offset(center.dx - bracketOffset, center.dy - bracketOffset + bracketSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx - bracketOffset, center.dy - bracketOffset),
      Offset(center.dx - bracketOffset + bracketSize, center.dy - bracketOffset),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(center.dx + bracketOffset, center.dy - bracketOffset),
      Offset(center.dx + bracketOffset, center.dy - bracketOffset + bracketSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx + bracketOffset, center.dy - bracketOffset),
      Offset(center.dx + bracketOffset - bracketSize, center.dy - bracketOffset),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(center.dx - bracketOffset, center.dy + bracketOffset),
      Offset(center.dx - bracketOffset, center.dy + bracketOffset - bracketSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx - bracketOffset, center.dy + bracketOffset),
      Offset(center.dx - bracketOffset + bracketSize, center.dy + bracketOffset),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(center.dx + bracketOffset, center.dy + bracketOffset),
      Offset(center.dx + bracketOffset, center.dy + bracketOffset - bracketSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx + bracketOffset, center.dy + bracketOffset),
      Offset(center.dx + bracketOffset - bracketSize, center.dy + bracketOffset),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}
