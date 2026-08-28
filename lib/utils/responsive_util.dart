import 'package:flutter/material.dart';

class ResponsiveUtil {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Check if device is mobile (< 600px)
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < 600;
  }

  // Check if device is tablet (600px - 900px)
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= 600 && width < 900;
  }

  // Check if device is desktop (>= 900px)
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= 900;
  }

  // Responsive width (percentage of screen width)
  static double width(BuildContext context, double percentage) {
    return screenWidth(context) * percentage / 100;
  }

  // Responsive height (percentage of screen height)
  static double height(BuildContext context, double percentage) {
    return screenHeight(context) * percentage / 100;
  }

  // Responsive font size
  static double fontSize(BuildContext context, double size) {
    final width = screenWidth(context);
    if (width < 360) {
      return size * 0.85; // Small phones
    } else if (width < 600) {
      return size; // Normal phones
    } else if (width < 900) {
      return size * 1.2; // Tablets
    } else {
      return size * 1.4; // Desktop
    }
  }

  // Responsive padding
  static double padding(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width < 360) {
      return baseSize * 0.7;
    } else if (width < 600) {
      return baseSize;
    } else if (width < 900) {
      return baseSize * 1.3;
    } else {
      return baseSize * 1.5;
    }
  }

  // Get responsive container width for forms
  static double formWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width < 600) {
      return width * 0.9; // 90% on mobile
    } else if (width < 900) {
      return 500; // Fixed width on tablet
    } else {
      return 550; // Fixed width on desktop
    }
  }

  // Responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width < 360) {
      return baseSize * 0.8;
    } else if (width < 600) {
      return baseSize;
    } else if (width < 900) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.4;
    }
  }

  // Responsive image size
  static double imageSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width < 360) {
      return baseSize * 0.75;
    } else if (width < 600) {
      return baseSize;
    } else if (width < 900) {
      return baseSize * 1.3;
    } else {
      return baseSize * 1.5;
    }
  }
}
