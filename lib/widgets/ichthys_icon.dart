import 'package:flutter/material.dart';

class IchthysIcon extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;

  const IchthysIcon({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 3.5, // Increased default stroke width to appear thicker
  });

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double iconSize = size ?? iconTheme.size ?? 24.0;
    final Color iconColor = color ?? iconTheme.color ?? Colors.white;

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Center(
        child: CustomPaint(
          size: Size(iconSize, iconSize * 0.5),
          painter: _IchthysPainter(
            color: iconColor,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _IchthysPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _IchthysPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Start at top-left of tail
    path.moveTo(size.width * 0.15, size.height * 0.25);
    // Curve down and right to the nose
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 1.1, 
      size.width * 0.9, size.height * 0.5
    );
    // Curve up and left back to bottom-left of tail
    path.quadraticBezierTo(
      size.width * 0.5, -size.height * 0.1, 
      size.width * 0.15, size.height * 0.75
    );

    canvas.drawPath(path, paint);
  }


  @override
  bool shouldRepaint(covariant _IchthysPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
