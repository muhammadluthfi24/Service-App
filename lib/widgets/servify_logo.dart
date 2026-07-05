import 'package:flutter/material.dart';

/// Servify logo widget — pin shape dengan sun/mountain di tengah + teks
class ServifyLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool darkBackground; // true = teks putih, false = teks navy

  const ServifyLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final navy = const Color(0xFF1A2B6B);
    final gold = const Color(0xFFFFC107);
    final textColor = darkBackground ? Colors.white : navy;
    final subtitleColor = darkBackground ? Colors.white70 : navy.withOpacity(0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size * 1.1,
          child: CustomPaint(
            painter: _ServifyPinPainter(navy: navy, gold: gold),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 10),
          Text(
            'Servify',
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'ON-DEMAND SERVICE',
            style: TextStyle(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}

class _ServifyPinPainter extends CustomPainter {
  final Color navy;
  final Color gold;

  _ServifyPinPainter({required this.navy, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintNavy = Paint()..color = navy..style = PaintingStyle.fill;
    final paintGold = Paint()..color = gold..style = PaintingStyle.fill;
    final paintWhite = Paint()..color = Colors.white..style = PaintingStyle.fill;

    // Pin body (teardrop shape)
    final pinPath = Path();
    final cx = w / 2;
    final cy = h * 0.38;
    final r = w * 0.42;

    pinPath.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    // Tail of pin
    pinPath.moveTo(cx - r * 0.35, cy + r * 0.7);
    pinPath.quadraticBezierTo(cx, h * 0.98, cx + r * 0.35, cy + r * 0.7);
    pinPath.close();
    canvas.drawPath(pinPath, paintNavy);

    // Inner white circle
    final innerR = r * 0.62;
    canvas.drawCircle(Offset(cx, cy), innerR, paintWhite);

    // Gold sun (semicircle top)
    final sunRect = Rect.fromCircle(center: Offset(cx, cy + innerR * 0.1), radius: innerR * 0.72);
    canvas.drawArc(sunRect, 3.14159, 3.14159, true, paintGold);

    // White mountain peaks over sun
    final mtPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final mtPath = Path();
    final mx = cx;
    final my = cy + innerR * 0.1;
    // Left peak
    mtPath.moveTo(mx - innerR * 0.55, my + innerR * 0.3);
    mtPath.lineTo(mx - innerR * 0.15, my - innerR * 0.28);
    mtPath.lineTo(mx + innerR * 0.12, my + innerR * 0.05);
    // Right peak
    mtPath.lineTo(mx + innerR * 0.12, my + innerR * 0.05);
    mtPath.lineTo(mx + innerR * 0.38, my - innerR * 0.42);
    mtPath.lineTo(mx + innerR * 0.65, my + innerR * 0.3);
    mtPath.close();
    canvas.drawPath(mtPath, mtPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
