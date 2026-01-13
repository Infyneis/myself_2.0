/// Text styles for Myself 2.0.
///
/// Typography based on REQUIREMENTS.md Section 7.3
library;

import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Application text styles.
///
/// Uses Playfair Display for affirmations and Inter for body text.
/// Note: Google Fonts will be integrated in a later feature (UI-001).
class AppTextStyles {
  AppTextStyles._();

  // Font sizes
  static const double _affirmationDisplaySize = 24.0;
  static const double _affirmationDisplayLargeSize = 32.0;
  static const double _bodySize = 16.0;
  static const double _headingSize = 20.0;
  static const double _buttonSize = 14.0;
  static const double _captionSize = 12.0;

  /// Light mode text theme.
  static TextTheme get lightTextTheme {
    return TextTheme(
      // Affirmation display - large prominent text
      displayLarge: const TextStyle(
        fontSize: _affirmationDisplayLargeSize,
        fontWeight: FontWeight.w400,
        color: AppColors.zenBlack,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      displayMedium: const TextStyle(
        fontSize: _affirmationDisplaySize,
        fontWeight: FontWeight.w400,
        color: AppColors.zenBlack,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      // Headings
      headlineMedium: const TextStyle(
        fontSize: _headingSize,
        fontWeight: FontWeight.w600,
        color: AppColors.zenBlack,
        letterSpacing: 0.15,
      ),
      // Body text
      bodyLarge: const TextStyle(
        fontSize: _bodySize,
        fontWeight: FontWeight.w400,
        color: AppColors.zenBlack,
        height: 1.5,
      ),
      bodyMedium: const TextStyle(
        fontSize: _bodySize,
        fontWeight: FontWeight.w400,
        color: AppColors.stone,
        height: 1.5,
      ),
      // Button text
      labelLarge: const TextStyle(
        fontSize: _buttonSize,
        fontWeight: FontWeight.w500,
        color: AppColors.zenBlack,
        letterSpacing: 0.5,
      ),
      // Caption/helper text
      bodySmall: const TextStyle(
        fontSize: _captionSize,
        fontWeight: FontWeight.w400,
        color: AppColors.stone,
      ),
    );
  }

  /// Dark mode text theme.
  static TextTheme get darkTextTheme {
    return TextTheme(
      // Affirmation display - large prominent text
      displayLarge: const TextStyle(
        fontSize: _affirmationDisplayLargeSize,
        fontWeight: FontWeight.w400,
        color: AppColors.softWhite,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      displayMedium: const TextStyle(
        fontSize: _affirmationDisplaySize,
        fontWeight: FontWeight.w400,
        color: AppColors.softWhite,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      // Headings
      headlineMedium: const TextStyle(
        fontSize: _headingSize,
        fontWeight: FontWeight.w600,
        color: AppColors.softWhite,
        letterSpacing: 0.15,
      ),
      // Body text
      bodyLarge: const TextStyle(
        fontSize: _bodySize,
        fontWeight: FontWeight.w400,
        color: AppColors.softWhite,
        height: 1.5,
      ),
      bodyMedium: const TextStyle(
        fontSize: _bodySize,
        fontWeight: FontWeight.w400,
        color: AppColors.stone,
        height: 1.5,
      ),
      // Button text
      labelLarge: const TextStyle(
        fontSize: _buttonSize,
        fontWeight: FontWeight.w500,
        color: AppColors.softWhite,
        letterSpacing: 0.5,
      ),
      // Caption/helper text
      bodySmall: const TextStyle(
        fontSize: _captionSize,
        fontWeight: FontWeight.w400,
        color: AppColors.stone,
      ),
    );
  }
}
