import 'package:flutter/material.dart';

class CrosshairOverlay extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const CrosshairOverlay({
    super.key,
    this.size = 80.0,
    this.color = Colors.white,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CrosshairPainter(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _CrosshairPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.4;
    final gapSize = radius * 0.15;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw crosshair lines (4 lines with gap in center)
    final path = Path();
    
    // Top line
    path.moveTo(center.dx, center.dy - innerRadius);
    path.lineTo(center.dx, center.dy - gapSize);
    
    // Bottom line
    path.moveTo(center.dx, center.dy + gapSize);
    path.lineTo(center.dx, center.dy + innerRadius);
    
    // Left line
    path.moveTo(center.dx - innerRadius, center.dy);
    path.lineTo(center.dx - gapSize, center.dy);
    
    // Right line
    path.moveTo(center.dx + gapSize, center.dy);
    path.lineTo(center.dx + innerRadius, center.dy);

    canvas.drawPath(path, paint);

    // Draw center dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
