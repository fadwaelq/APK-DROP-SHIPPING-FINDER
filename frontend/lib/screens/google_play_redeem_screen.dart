import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class GooglePlayRedeemScreen extends StatefulWidget {
  const GooglePlayRedeemScreen({super.key});

  @override
  State<GooglePlayRedeemScreen> createState() => _GooglePlayRedeemScreenState();
}

class _GooglePlayRedeemScreenState extends State<GooglePlayRedeemScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Redeem Code',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Carte-cadeau ou code\npromotionnel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _codeController,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'FGGH-HNFE-YJ...',
                            hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Color(0xFF0F7A2F), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Color(0xFF0F7A2F), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),
                  SizedBox(
                    height: 240,
                    width: 240,
                    child: CustomPaint(
                      painter: GooglePlayLogoPainter(),
                    ),
                  ),
                  const SizedBox(height: 180), // Spacer for sticky bottom area
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F7A2F),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Redeem',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              text: "Code d'échange pour ",
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              children: const [
                                TextSpan(
                                  text: 'user@gmail.com',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomBottomNavBar(
                      currentIndex: -1,
                      onTap: (i) {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GooglePlayLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Shift boundaries slightly inwards to allow room for rounded edges
    final Offset p1 = Offset(w * 0.15, h * 0.15); // Top Left
    final Offset p2 = Offset(w * 0.15, h * 0.85); // Bottom Left
    final Offset pRight = Offset(w * 0.85, h * 0.5); // Far right point
    
    // Calculate the intersections based on a standard 'play triangle' center point
    final Offset c = Offset(w * 0.45, h * 0.5); // Center point intersection
    
    // Slanted intersections for green/yellow/red shapes
    final Offset pTopEdge = Offset(w * 0.58, h * 0.36);
    final Offset pBottomEdge = Offset(w * 0.58, h * 0.64);

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round // Smooth corners
      ..strokeWidth = 20.0; // Use thick strokes to emulate rounded outer edges
      
    // Blue (Left)
    Path pathBlue = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    paint.color = const Color(0xFFC8E0FB); // Pale blue
    canvas.drawPath(pathBlue, paint);
    
    // We effectively draw the path with both fill and stroke of the same color
    // This makes the outer edges naturally rounded due to the StrokeJoin.round
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(pathBlue, paint);

    // Green (Top)
    paint.style = PaintingStyle.fill;
    Path pathGreen = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(pTopEdge.dx, pTopEdge.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    paint.color = const Color(0xFFC3E8CC); // Pale green
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
    paint.color = const Color(0xFFF7BFC0); // Pale red
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
    paint.color = const Color(0xFFFBE4B6); // Pale yellow
    canvas.drawPath(pathYellow, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(pathYellow, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
