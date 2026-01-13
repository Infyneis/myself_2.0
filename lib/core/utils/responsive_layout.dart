/// Responsive layout utilities for supporting screens from 4 to 13 inches.
///
/// Provides adaptive layout helpers and responsive sizing utilities.
/// Based on REQUIREMENTS.md NFR-008 (COMPAT-003).
library;

import 'package:flutter/material.dart';

/// Screen size categories based on diagonal size.
///
/// - Small: 4-6 inches (phones)
/// - Medium: 6-8 inches (large phones, small tablets)
/// - Large: 8-11 inches (tablets)
/// - ExtraLarge: 11-13 inches (large tablets, small laptops)
enum ScreenSize {
  /// Small screens: 4-6 inches (typical phones)
  small,

  /// Medium screens: 6-8 inches (large phones, small tablets)
  medium,

  /// Large screens: 8-11 inches (tablets)
  large,

  /// Extra large screens: 11-13 inches (large tablets)
  extraLarge,
}

/// Responsive layout utilities for adaptive UI.
///
/// Provides methods to determine screen size category and adaptive sizing.
class ResponsiveLayout {
  ResponsiveLayout._();

  // Breakpoints based on shortest side (in logical pixels)
  // Typical DPI for mobile devices: 2-3x
  // 4 inch phone @ 2x = ~320 logical pixels
  // 6 inch phone @ 2x = ~360-400 logical pixels
  // 8 inch tablet @ 2x = ~600 logical pixels
  // 10 inch tablet @ 2x = ~720 logical pixels
  // 13 inch tablet @ 2x = ~900 logical pixels

  /// Small screen breakpoint (max shortest side for phones)
  static const double smallBreakpoint = 600;

  /// Medium screen breakpoint (max shortest side for large phones/small tablets)
  static const double mediumBreakpoint = 720;

  /// Large screen breakpoint (max shortest side for tablets)
  static const double largeBreakpoint = 900;

  /// Maximum content width for large screens (prevents excessive stretching)
  static const double maxContentWidth = 800;

  /// Gets the screen size category based on the shortest side.
  ///
  /// This ensures consistent categorization in both portrait and landscape.
  static ScreenSize getScreenSize(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    if (shortestSide < smallBreakpoint) {
      return ScreenSize.small;
    } else if (shortestSide < mediumBreakpoint) {
      return ScreenSize.medium;
    } else if (shortestSide < largeBreakpoint) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }

  /// Checks if the current screen is small (phone).
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.small;
  }

  /// Checks if the current screen is medium or larger.
  static bool isMediumOrLarger(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.medium ||
        size == ScreenSize.large ||
        size == ScreenSize.extraLarge;
  }

  /// Checks if the current screen is large or extra large (tablet).
  static bool isTablet(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.large || size == ScreenSize.extraLarge;
  }

  /// Returns a responsive value based on screen size.
  ///
  /// Provide values for different screen sizes, and this will return
  /// the appropriate one based on the current screen.
  ///
  /// Example:
  /// ```dart
  /// final columns = ResponsiveLayout.valueWhen(
  ///   context: context,
  ///   small: 1,
  ///   medium: 2,
  ///   large: 3,
  ///   extraLarge: 4,
  /// );
  /// ```
  static T valueWhen<T>({
    required BuildContext context,
    required T small,
    T? medium,
    T? large,
    T? extraLarge,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium ?? small;
      case ScreenSize.large:
        return large ?? medium ?? small;
      case ScreenSize.extraLarge:
        return extraLarge ?? large ?? medium ?? small;
    }
  }

  /// Returns adaptive padding based on screen size.
  ///
  /// Small screens get smaller padding, larger screens get more generous padding.
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    return valueWhen(
      context: context,
      small: const EdgeInsets.all(16),
      medium: const EdgeInsets.all(24),
      large: const EdgeInsets.all(32),
      extraLarge: const EdgeInsets.all(40),
    );
  }

  /// Returns adaptive horizontal padding based on screen size.
  static EdgeInsets getAdaptiveHorizontalPadding(BuildContext context) {
    return valueWhen(
      context: context,
      small: const EdgeInsets.symmetric(horizontal: 16),
      medium: const EdgeInsets.symmetric(horizontal: 24),
      large: const EdgeInsets.symmetric(horizontal: 32),
      extraLarge: const EdgeInsets.symmetric(horizontal: 48),
    );
  }

  /// Wraps content with max width constraint on larger screens.
  ///
  /// This prevents content from stretching too wide on tablets.
  /// Centers the content when max width is applied.
  static Widget constrainContentWidth({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    if (isTablet(context)) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? maxContentWidth,
          ),
          child: child,
        ),
      );
    }
    return child;
  }

  /// Returns adaptive font size multiplier based on screen size.
  ///
  /// This is in addition to user font size preference.
  /// Larger screens can afford slightly larger base text.
  static double getFontSizeMultiplier(BuildContext context) {
    return valueWhen(
      context: context,
      small: 1.0,
      medium: 1.05,
      large: 1.1,
      extraLarge: 1.15,
    );
  }

  /// Returns adaptive grid column count for list items.
  ///
  /// Used for displaying items in a grid layout that adapts to screen size.
  static int getGridColumnCount(BuildContext context) {
    return valueWhen(
      context: context,
      small: 1,
      medium: 2,
      large: 2,
      extraLarge: 3,
    );
  }

  /// Returns whether to use compact layout mode.
  ///
  /// Small screens should use compact layouts to maximize space.
  static bool useCompactLayout(BuildContext context) {
    return getScreenSize(context) == ScreenSize.small;
  }

  /// Returns adaptive card width for dialog/modal layouts.
  static double getDialogWidth(BuildContext context) {
    return valueWhen(
      context: context,
      small: MediaQuery.of(context).size.width * 0.9,
      medium: 400,
      large: 500,
      extraLarge: 600,
    );
  }

  /// Returns adaptive spacing value based on screen size.
  static double getAdaptiveSpacing(BuildContext context, double baseSpacing) {
    final multiplier = valueWhen(
      context: context,
      small: 1.0,
      medium: 1.2,
      large: 1.4,
      extraLarge: 1.6,
    );
    return baseSpacing * multiplier;
  }

  /// Returns orientation-aware layout flag.
  ///
  /// Some layouts should adapt differently in landscape vs portrait.
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Returns whether to show side-by-side layout for large screens.
  ///
  /// Useful for master-detail patterns on tablets.
  static bool shouldUseSideBySideLayout(BuildContext context) {
    return isTablet(context) && isLandscape(context);
  }

  /// Returns adaptive icon size based on screen size.
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    final multiplier = valueWhen(
      context: context,
      small: 1.0,
      medium: 1.1,
      large: 1.2,
      extraLarge: 1.3,
    );
    return baseSize * multiplier;
  }

  /// Returns safe area insets for the current context.
  ///
  /// Useful for handling notches, status bars, and navigation bars.
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Calculates responsive text scale factor.
  ///
  /// Combines system text scale with our adaptive scaling.
  /// Clamps to reasonable limits to prevent text from becoming too large.
  static double getTextScaleFactor(
    BuildContext context, {
    double? userMultiplier,
  }) {
    final systemScale = MediaQuery.of(context).textScaler.scale(1.0);
    final adaptiveScale = getFontSizeMultiplier(context);
    final userScale = userMultiplier ?? 1.0;

    // Combine all scales but clamp to prevent extreme sizes
    final combined = systemScale * adaptiveScale * userScale;
    return combined.clamp(0.8, 2.0);
  }
}
