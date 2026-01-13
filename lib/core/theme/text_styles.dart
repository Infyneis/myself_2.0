/// Text styles for Myself 2.0.
///
/// Typography based on REQUIREMENTS.md Section 7.3
/// Uses Playfair Display for affirmations (serif, elegant)
/// Uses Inter for body text (sans-serif, clean)
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

/// Application text styles.
///
/// Uses Playfair Display for affirmations and Inter for body text.
/// Google Fonts are loaded dynamically for a zen, elegant aesthetic.
class AppTextStyles {
  AppTextStyles._();

  // Font sizes
  static const double _affirmationDisplaySize = 24.0;
  static const double _affirmationDisplayLargeSize = 32.0;
  static const double _bodySize = 16.0;
  static const double _headingSize = 20.0;
  static const double _buttonSize = 14.0;
  static const double _captionSize = 12.0;

  /// Playfair Display text style for affirmations.
  ///
  /// Elegant serif font for prominent affirmation display.
  static TextStyle playfairDisplay({
    double fontSize = _affirmationDisplaySize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.zenBlack,
    double height = 1.4,
    double letterSpacing = 0.25,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Inter text style for body text.
  ///
  /// Clean sans-serif font for general UI text.
  static TextStyle inter({
    double fontSize = _bodySize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.zenBlack,
    double height = 1.5,
    double letterSpacing = 0.0,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Light mode text theme.
  static TextTheme get lightTextTheme {
    return TextTheme(
      // Affirmation display - large prominent text (Playfair Display)
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: _affirmationDisplayLargeSize,
        fontWeight: FontWeight.w400,
        color: AppColors.zenBlack,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: _affirmationDisplaySize,
        fontWeight: FontWeight.w400,
        color: AppColors.zenBlack,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: _headingSize,
        fontWeight: FontWeight.w400,
        color: AppColors.zenBlack,
        height: 1.4,
        letterSpacing: 0.15,
      ),
      // Headings (Inter)
      headlineLarge: GoogleFonts.inter(
        fontSize: _headingSize + 4,
        fontWeight: FontWeight.w600,
        color: AppColors.zenBlack,
        letterSpacing: 0.15,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: _headingSize,
        fontWeight: FontWeight.w600,
        color: AppColors.zenBlack,
        letterSpacing: 0.15,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: _headingSize - 2,
        fontWeight: FontWeight.w600,
        color: AppColors.zenBlack,
        letterSpacing: 0.15,
      ),
      // Title styles (Inter)
      titleLarge: GoogleFonts.inter(
        fontSize: _headingSize,
        fontWeight: FontWeight.w500,
        color: AppColors.zenBlack,
        letterSpacing: 0.15,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: _bodySize,
        fontWeight: FontWeight.w500,
        color: AppColors.zenBlack,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: _buttonSize,
        fontWeight: FontWeight.w500,
        color: AppColors.zenBlack,
        letterSpacing: 0.1,
      ),
      // Body text (Inter)
      bodyLarge: GoogleFonts.inter(
        fontSize: _bodySize,
        fontWeight: FontWeight.w400,
        color: AppColors.zenBlack,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: _bodySize,
        fontWeight: FontWeight.w400,
        color: AppColors.stone,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: _captionSize,
        fontWeight: FontWeight.w400,
        color: AppColors.stone,
      ),
      // Label/button text (Inter)
      labelLarge: GoogleFonts.inter(
        fontSize: _buttonSize,
        fontWeight: FontWeight.w500,
        color: AppColors.zenBlack,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: _captionSize,
        fontWeight: FontWeight.w500,
        color: AppColors.zenBlack,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: _captionSize - 1,
        fontWeight: FontWeight.w500,
        color: AppColors.stone,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Dark mode text theme.
  static TextTheme get darkTextTheme {
    return TextTheme(
      // Affirmation display - large prominent text (Playfair Display)
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: _affirmationDisplayLargeSize,
        fontWeight: FontWeight.w400,
        color: AppColors.softWhite,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: _affirmationDisplaySize,
        fontWeight: FontWeight.w400,
        color: AppColors.softWhite,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: _headingSize,
        fontWeight: FontWeight.w400,
        color: AppColors.softWhite,
        height: 1.4,
        letterSpacing: 0.15,
      ),
      // Headings (Inter)
      headlineLarge: GoogleFonts.inter(
        fontSize: _headingSize + 4,
        fontWeight: FontWeight.w600,
        color: AppColors.softWhite,
        letterSpacing: 0.15,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: _headingSize,
        fontWeight: FontWeight.w600,
        color: AppColors.softWhite,
        letterSpacing: 0.15,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: _headingSize - 2,
        fontWeight: FontWeight.w600,
        color: AppColors.softWhite,
        letterSpacing: 0.15,
      ),
      // Title styles (Inter)
      titleLarge: GoogleFonts.inter(
        fontSize: _headingSize,
        fontWeight: FontWeight.w500,
        color: AppColors.softWhite,
        letterSpacing: 0.15,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: _bodySize,
        fontWeight: FontWeight.w500,
        color: AppColors.softWhite,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: _buttonSize,
        fontWeight: FontWeight.w500,
        color: AppColors.softWhite,
        letterSpacing: 0.1,
      ),
      // Body text (Inter)
      bodyLarge: GoogleFonts.inter(
        fontSize: _bodySize,
        fontWeight: FontWeight.w400,
        color: AppColors.softWhite,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: _bodySize,
        fontWeight: FontWeight.w400,
        color: AppColors.stoneDark,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: _captionSize,
        fontWeight: FontWeight.w400,
        color: AppColors.stoneDark,
      ),
      // Label/button text (Inter)
      labelLarge: GoogleFonts.inter(
        fontSize: _buttonSize,
        fontWeight: FontWeight.w500,
        color: AppColors.softWhite,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: _captionSize,
        fontWeight: FontWeight.w500,
        color: AppColors.softWhite,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: _captionSize - 1,
        fontWeight: FontWeight.w500,
        color: AppColors.stoneDark,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Font size constants for external use

  /// Standard affirmation display font size (24px).
  static double get affirmationDisplaySize => _affirmationDisplaySize;

  /// Large affirmation display font size (32px).
  static double get affirmationDisplayLargeSize => _affirmationDisplayLargeSize;

  /// Standard body text font size (16px).
  static double get bodySize => _bodySize;

  /// Heading text font size (20px).
  static double get headingSize => _headingSize;

  /// Button text font size (14px).
  static double get buttonSize => _buttonSize;

  /// Caption text font size (12px).
  static double get captionSize => _captionSize;
}
