/// Application theme configuration for Myself 2.0.
///
/// Implements the zen design philosophy with calm, serene aesthetics.
/// Based on REQUIREMENTS.md Section 7.
library;

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';
import 'text_styles.dart';

/// Main theme configuration for the application.
///
/// Provides both light and dark theme data following the zen design requirements.
class AppTheme {
  AppTheme._();

  /// Light theme configuration.
  ///
  /// Uses Cloud White background with Zen Black text.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cloudWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.softSage,
        onPrimary: AppColors.zenBlack,
        secondary: AppColors.mistGray,
        onSecondary: AppColors.zenBlack,
        surface: AppColors.cloudWhite,
        onSurface: AppColors.zenBlack,
        error: AppColors.error,
        onError: AppColors.cloudWhite,
      ),
      textTheme: AppTextStyles.lightTextTheme,
      cardTheme: CardThemeData(
        color: AppColors.cloudWhite,
        elevation: AppDimensions.elevationSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cloudWhite,
        foregroundColor: AppColors.zenBlack,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.softSage,
        foregroundColor: AppColors.zenBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.softSage,
          foregroundColor: AppColors.zenBlack,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.mistGray.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.softSage, width: 2),
        ),
      ),
    );
  }

  /// Dark theme configuration.
  ///
  /// Uses Deep Night background with Soft White text.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepNight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.softSage,
        onPrimary: AppColors.deepNight,
        secondary: AppColors.stoneDark,
        onSecondary: AppColors.softWhite,
        surface: AppColors.deepNight,
        onSurface: AppColors.softWhite,
        error: AppColors.errorDark,
        onError: AppColors.deepNight,
      ),
      textTheme: AppTextStyles.darkTextTheme,
      cardTheme: CardThemeData(
        color: AppColors.deepNight,
        elevation: AppDimensions.elevationSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepNight,
        foregroundColor: AppColors.softWhite,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.softSage,
        foregroundColor: AppColors.deepNight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.softSage,
          foregroundColor: AppColors.deepNight,
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.stoneDark.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.softSage, width: 2),
        ),
      ),
    );
  }
}
