import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Official RENTRIG brand identity palette & decorations.
abstract final class AppColors {
  /// Obsidian Black (#181818) - Core background and dark mode UI surfaces
  static const Color background = Color(0xFF181818);
  static const Color backgroundGradient = Color(0xFF181818);
  
  /// Obsidian Surface (#222226) - Elevated bento cards and container fills
  static const Color surface = Color(0xFF222226);
  
  /// Elevated Surface (#2A2A30) - Modals, drawers, and active inputs
  static const Color surfaceElevated = Color(0xFF2A2A30);

  /// Electric Cyan (#00FFFF) - High-tech primary accent and glowing highlights
  static const Color accent = Color(0xFF00FFFF);
  
  /// Cyan Secondary (#00C8FF) - Secondary state indicators
  static const Color accentSecondary = Color(0xFF00C8FF);

  /// Titanium Gray (#5A5A5E) - Subtitles, subtle borders, and inactive icons
  static const Color titanium = Color(0xFF5A5A5E);
  
  /// Titanium Light (#8E8E93) - Muted secondary text
  static const Color titaniumLight = Color(0xFF8E8E93);

  /// Pure White (#FFFFFF) - Primary high-contrast text and main icons
  static const Color white = Color(0xFFFFFFFF);

  /// Danger / Error (#FF3B30)
  static const Color error = Color(0xFFFF3B30);

  /// Success / Active (#34C759)
  static const Color success = Color(0xFF34C759);
}

abstract final class AppDecorations {
  static const BoxDecoration screenBackground = BoxDecoration(
    color: AppColors.background,
  );

  static BoxDecoration glassCard({double radius = 16, Color? borderColor}) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? AppColors.titanium.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration bentoCard({double radius = 16, bool isHighlighted = false}) => BoxDecoration(
        color: isHighlighted ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isHighlighted
              ? AppColors.accent.withOpacity(0.6)
              : AppColors.titanium.withOpacity(0.25),
          width: isHighlighted ? 1.5 : 1.0,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : [],
      );

  static AppBar darkAppBar({
    required String title,
    List<Widget>? actions,
    double? toolbarHeight,
    Widget? leading,
  }) {
    return AppBar(
      toolbarHeight: toolbarHeight,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      iconTheme: const IconThemeData(color: AppColors.white),
      title: Text(
        title,
        style: GoogleFonts.spaceGrotesk(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.5,
        ),
      ),
      actions: actions,
    );
  }

  static Widget darkBody({required Widget child}) {
    return Container(
      color: AppColors.background,
      child: child,
    );
  }
}

