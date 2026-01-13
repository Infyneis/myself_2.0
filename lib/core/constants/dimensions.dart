/// App dimension constants following the zen design philosophy.
///
/// Spacing and sizing based on REQUIREMENTS.md Section 7.4
library;

/// Application dimension constants for Myself 2.0.
///
/// Generous padding and ample breathing room between elements
/// as per the zen design requirements.
class AppDimensions {
  AppDimensions._();

  // Spacing
  /// Extra small spacing - 4px
  static const double spacingXs = 4.0;

  /// Small spacing - 8px
  static const double spacingS = 8.0;

  /// Medium spacing - 16px
  static const double spacingM = 16.0;

  /// Large spacing - 24px (minimum margin as per requirements)
  static const double spacingL = 24.0;

  /// Extra large spacing - 32px
  static const double spacingXl = 32.0;

  /// XXL spacing - 48px
  static const double spacingXxl = 48.0;

  // Border radius
  /// Default border radius for cards - 16px
  static const double borderRadiusDefault = 16.0;

  /// Small border radius - 8px
  static const double borderRadiusSmall = 8.0;

  /// Large border radius - 24px
  static const double borderRadiusLarge = 24.0;

  // Touch targets (accessibility requirement: minimum 44x44 points)
  /// Minimum touch target size - 44px
  static const double minTouchTarget = 44.0;

  // Affirmation constraints
  /// Maximum characters for an affirmation
  static const int maxAffirmationLength = 280;

  // Animation durations
  /// Fast animation duration - 200ms
  static const int animationDurationFast = 200;

  /// Default animation duration - 300ms
  static const int animationDurationDefault = 300;

  /// Slow animation duration (for affirmation transitions) - 500ms
  static const int animationDurationSlow = 500;

  // Elevation
  /// Soft elevation for cards
  static const double elevationSoft = 2.0;

  /// Medium elevation
  static const double elevationMedium = 4.0;
}
