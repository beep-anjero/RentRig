import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentrig/utils/app_colors.dart';

/// Official RENTRIG 'R' Tech-Monogram Brandmark and Logotype Widget.
class TechMonogramLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isVertical;
  final Color monogramColor;
  final Color textColor;
  final Color subtitleColor;

  const TechMonogramLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.isVertical = false,
    this.monogramColor = AppColors.accent,
    this.textColor = AppColors.white,
    this.subtitleColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    final monogramWidget = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TechMonogramPainter(color: monogramColor),
      ),
    );

    if (!showText) {
      return monogramWidget;
    }

    final textWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isVertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'RENTRIG',
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.45,
            letterSpacing: 2.0,
            height: 1.0,
          ),
        ),
        SizedBox(height: size * 0.05),
        Text(
          'TECHNOLOGY RENTALS',
          style: GoogleFonts.spaceGrotesk(
            color: subtitleColor,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.18,
            letterSpacing: 3.0,
            height: 1.0,
          ),
        ),
      ],
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          monogramWidget,
          SizedBox(height: size * 0.3),
          textWidget,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        monogramWidget,
        SizedBox(width: size * 0.3),
        textWidget,
      ],
    );
  }
}

/// Precise Custom Painter for the 'R' Tech-Monogram brandmark with cybernetic bevels & cut-outs.
class _TechMonogramPainter extends CustomPainter {
  final Color color;

  _TechMonogramPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background Shadow / Border Cut
    final borderPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.square;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Outer 'R' Tech Monogram Path
    final Path path = Path();
    
    // Left vertical stem with tech notch
    path.moveTo(w * 0.15, h * 0.05);
    path.lineTo(w * 0.65, h * 0.05);
    path.lineTo(w * 0.85, h * 0.25);
    path.lineTo(w * 0.85, h * 0.45);
    path.lineTo(w * 0.60, h * 0.55);
    path.lineTo(w * 0.88, h * 0.95);
    path.lineTo(w * 0.68, h * 0.95);
    path.lineTo(w * 0.45, h * 0.58);
    path.lineTo(w * 0.35, h * 0.58);
    path.lineTo(w * 0.35, h * 0.95);
    path.lineTo(w * 0.15, h * 0.95);
    path.close();

    // Inner Cutout loop of 'R'
    final Path innerPath = Path();
    innerPath.moveTo(w * 0.35, h * 0.22);
    innerPath.lineTo(w * 0.58, h * 0.22);
    innerPath.lineTo(w * 0.68, h * 0.32);
    innerPath.lineTo(w * 0.58, h * 0.42);
    innerPath.lineTo(w * 0.35, h * 0.42);
    innerPath.close();

    // Cybernetic Cyber Cut Accent (Tech notch in top left)
    final Path notchPath = Path();
    notchPath.moveTo(w * 0.05, h * 0.25);
    notchPath.lineTo(w * 0.22, h * 0.25);
    notchPath.lineTo(w * 0.22, h * 0.45);
    notchPath.lineTo(w * 0.05, h * 0.45);
    notchPath.close();

    // Combine paths
    final Path finalR = Path.combine(
      PathOperation.difference,
      path,
      innerPath,
    );

    // Draw cyber notch
    canvas.drawPath(notchPath, fillPaint);
    canvas.drawPath(finalR, fillPaint);
    canvas.drawPath(finalR, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _TechMonogramPainter oldDelegate) =>
      oldDelegate.color != color;
}
