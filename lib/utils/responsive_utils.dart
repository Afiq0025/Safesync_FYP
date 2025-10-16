import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 360 && width < 414;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 414;
  }

  // Responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double small = 16.0,
    double medium = 20.0,
    double large = 24.0,
  }) {
    if (isSmallScreen(context)) {
      return EdgeInsets.all(small);
    } else if (isMediumScreen(context)) {
      return EdgeInsets.all(medium);
    } else {
      return EdgeInsets.all(large);
    }
  }

  // Responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context, {
    double small = 16.0,
    double medium = 20.0,
    double large = 24.0,
  }) {
    if (isSmallScreen(context)) {
      return EdgeInsets.symmetric(horizontal: small);
    } else if (isMediumScreen(context)) {
      return EdgeInsets.symmetric(horizontal: medium);
    } else {
      return EdgeInsets.symmetric(horizontal: large);
    }
  }

  // Responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    double small = 14.0,
    double medium = 16.0,
    double large = 18.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  // Responsive icon size
  static double getResponsiveIconSize(BuildContext context, {
    double small = 20.0,
    double medium = 24.0,
    double large = 28.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  // Responsive container size
  static double getResponsiveContainerSize(BuildContext context, {
    double small = 40.0,
    double medium = 50.0,
    double large = 60.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  // Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {
    double small = 8.0,
    double medium = 12.0,
    double large = 16.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  // Get percentage-based width
  static double getPercentageWidth(BuildContext context, double percentage) {
    return getScreenWidth(context) * (percentage / 100);
  }

  // Get percentage-based height
  static double getPercentageHeight(BuildContext context, double percentage) {
    return getScreenHeight(context) * (percentage / 100);
  }

  // Safe area aware height
  static double getSafeAreaHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
  }

  // Responsive card width for forms
  static double getCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isSmallScreen(context)) {
      return screenWidth * 0.92;
    } else if (isMediumScreen(context)) {
      return screenWidth * 0.88;
    } else {
      return screenWidth * 0.85;
    }
  }
}
