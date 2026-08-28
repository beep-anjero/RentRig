import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/responsive_util.dart';
import 'package:rentrig/widgets/tech_monogram_logo.dart';
import 'package:rentrig/screens/log_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LogInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double logoSize = ResponsiveUtil.imageSize(context, 110);

    return GestureDetector(
      onTap: _navigateToLogin,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.06),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _rotateController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(logoSize * 1.6, logoSize * 1.6),
                              painter: OrbitLoaderPainter(
                                _rotateController.value,
                              ),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: TechMonogramLogo(
                            size: logoSize,
                            showText: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'RENTRIG',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TECHNOLOGY RENTALS',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6.0,
                      ),
                    ),
                    const SizedBox(height: 80),
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        final double value =
                            _rotateController.value * 2 * pi;
                        final double opacity =
                            0.3 + 0.4 * (sin(value) + 1.0) / 2.0;
                        return Text(
                          'TAP ANYWHERE TO CONTINUE',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.white.withOpacity(opacity),
                            fontSize: ResponsiveUtil.fontSize(context, 12),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        );
                      },
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

class OrbitLoaderPainter extends CustomPainter {
  final double animationValue;

  OrbitLoaderPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          AppColors.accentSecondary,
          AppColors.accent,
          Colors.transparent,
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(animationValue * 2 * pi);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawArc(rect, 0, pi * 1.25, false, paint);

    final leadingDotPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(
      Offset(size.width, size.height / 2),
      3,
      leadingDotPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OrbitLoaderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
