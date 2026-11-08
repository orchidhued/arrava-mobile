import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painter vektor resmi Logo Arrava
/// Merepresentasikan huruf 'A' futuristik warna biru dengan titik kuning di tengah,
/// identik 100% secara matematis dengan SVG resmi Arrava.
class ArravaLogoPainter extends CustomPainter {
  final Color outerStrokeColor;
  final Color innerStrokeColor;
  final Color dotColor;

  const ArravaLogoPainter({
    this.outerStrokeColor = const Color(0xFF0875F9),
    this.innerStrokeColor = const Color(0xFF0C55C8),
    this.dotColor = const Color(0xFFFFBE35),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 40.0;

    canvas.save();
    canvas.scale(scale, scale);

    // 1. Garis Luar 'A' (Biru Cerah)
    final outerPaint = Paint()
      ..color = outerStrokeColor
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final outerPath = Path()
      ..moveTo(5.0, 31.0)
      ..lineTo(17.5, 7.5)
      ..cubicTo(18.5, 5.5, 21.5, 5.5, 22.5, 7.5)
      ..lineTo(35.0, 31.0);
    canvas.drawPath(outerPath, outerPaint);

    // 2. Garis Dalam 'A' (Biru Tua)
    final innerPaint = Paint()
      ..color = innerStrokeColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final innerPath = Path()
      ..moveTo(13.5, 23.5)
      ..lineTo(20.0, 11.5)
      ..lineTo(26.5, 23.5);
    canvas.drawPath(innerPath, innerPaint);

    // 3. Titik Tengah Emas (Kuning Amber)
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(20.0, 26.5), 4.0, dotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ArravaLogoPainter oldDelegate) {
    return oldDelegate.outerStrokeColor != outerStrokeColor ||
        oldDelegate.innerStrokeColor != innerStrokeColor ||
        oldDelegate.dotColor != dotColor;
  }
}

/// Widget Logo Resmi Arrava (Vektor Tajam di Semua Resolusi)
class ArravaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double? fontSize;
  final Color? textColor;
  final String text;

  const ArravaLogo({
    super.key,
    this.size = 32.0,
    this.showText = false,
    this.fontSize,
    this.textColor,
    this.text = 'Arrava',
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(
        painter: ArravaLogoPainter(),
      ),
    );

    if (!showText) {
      return logoWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoWidget,
        SizedBox(width: size * 0.28),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize ?? (size * 0.65),
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
            color: textColor ?? const Color(0xFF082765),
          ),
        ),
      ],
    );
  }
}

