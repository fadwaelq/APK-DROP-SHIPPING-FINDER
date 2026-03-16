import 'package:flutter/material.dart';

class GooglePlayLogo extends StatelessWidget {
  final double size;
  const GooglePlayLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CustomPaint(
        painter: GooglePlayLogoPainter(),
      ),
    );
  }
}

class GooglePlayLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Center point intersection
    final Offset c = Offset(w * 0.45, h * 0.5);
    
    // Boundary points
    final Offset p1 = Offset(w * 0.15, h * 0.15); // Top Left
    final Offset p2 = Offset(w * 0.15, h * 0.85); // Bottom Left
    final Offset pRight = Offset(w * 0.85, h * 0.5); // Far right point

    // Slanted intersections for green/yellow/red shapes
    final Offset pTopEdge = Offset(w * 0.58, h * 0.36);
    final Offset pBottomEdge = Offset(w * 0.58, h * 0.64);

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.08;
      
    // Blue (Left)
    Path pathBlue = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    paint.color = const Color(0xFF4285F4); // Real Google Blue
    canvas.drawPath(pathBlue, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(pathBlue, paint);

    // Green (Top)
    paint.style = PaintingStyle.fill;
    Path pathGreen = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(pTopEdge.dx, pTopEdge.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    paint.color = const Color(0xFF34A853); // Real Google Green
    canvas.drawPath(pathGreen, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(pathGreen, paint);

    // Red (Bottom)
    paint.style = PaintingStyle.fill;
    Path pathRed = Path()
      ..moveTo(p2.dx, p2.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(pBottomEdge.dx, pBottomEdge.dy)
      ..close();
    paint.color = const Color(0xFFEA4335); // Real Google Red
    canvas.drawPath(pathRed, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(pathRed, paint);

    // Yellow (Right)
    paint.style = PaintingStyle.fill;
    Path pathYellow = Path()
      ..moveTo(pTopEdge.dx, pTopEdge.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(pBottomEdge.dx, pBottomEdge.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    paint.color = const Color(0xFFFBBC05); // Real Google Yellow
    canvas.drawPath(pathYellow, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(pathYellow, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
