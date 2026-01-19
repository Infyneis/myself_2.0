import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/theme/app_theme.dart';
import 'package:myself_2_0/core/theme/text_styles.dart';
import 'package:myself_2_0/core/constants/colors.dart';
import 'package:myself_2_0/core/constants/dimensions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme', () {
    group('lightTheme', () {
      test('should use Cloud White as scaffold background', () {
        final theme = AppTheme.lightTheme;
        expect(theme.scaffoldBackgroundColor, AppColors.cloudWhite);
      });

      test('should have light brightness', () {
        final theme = AppTheme.lightTheme;
        expect(theme.brightness, Brightness.light);
      });

      test('should use Material 3', () {
        final theme = AppTheme.lightTheme;
        expect(theme.useMaterial3, true);
      });

      test('should have correct color scheme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.primary, AppColors.softSage);
        expect(theme.colorScheme.surface, AppColors.cloudWhite);
        expect(theme.colorScheme.onSurface, AppColors.zenBlack);
        expect(theme.colorScheme.error, AppColors.error);
      });

      test('should have proper card theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.cardTheme.color, AppColors.cloudWhite);
        expect(theme.cardTheme.elevation, AppDimensions.elevationSoft);
      });

      test('should have proper app bar theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.appBarTheme.backgroundColor, AppColors.cloudWhite);
        expect(theme.appBarTheme.foregroundColor, AppColors.zenBlack);
        expect(theme.appBarTheme.elevation, 0);
      });

      test('should have proper FAB theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.floatingActionButtonTheme.backgroundColor, AppColors.softSage);
        expect(theme.floatingActionButtonTheme.foregroundColor, AppColors.zenBlack);
      });
    });

    group('darkTheme', () {
      test('should use Deep Night as scaffold background', () {
        final theme = AppTheme.darkTheme;
        expect(theme.scaffoldBackgroundColor, AppColors.deepNight);
      });

      test('should have dark brightness', () {
        final theme = AppTheme.darkTheme;
        expect(theme.brightness, Brightness.dark);
      });

      test('should use Material 3', () {
        final theme = AppTheme.darkTheme;
        expect(theme.useMaterial3, true);
      });

      test('should have correct color scheme', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.primary, AppColors.softSage);
        expect(theme.colorScheme.surface, AppColors.deepNight);
        expect(theme.colorScheme.onSurface, AppColors.softWhite);
        expect(theme.colorScheme.error, AppColors.error);
      });

      test('should have proper card theme', () {
        final theme = AppTheme.darkTheme;
        expect(theme.cardTheme.color, AppColors.deepNight);
        expect(theme.cardTheme.elevation, AppDimensions.elevationSoft);
      });

      test('should have proper app bar theme', () {
        final theme = AppTheme.darkTheme;
        expect(theme.appBarTheme.backgroundColor, AppColors.deepNight);
        expect(theme.appBarTheme.foregroundColor, AppColors.softWhite);
        expect(theme.appBarTheme.elevation, 0);
      });

      test('should have proper FAB theme', () {
        final theme = AppTheme.darkTheme;
        expect(theme.floatingActionButtonTheme.backgroundColor, AppColors.softSage);
        expect(theme.floatingActionButtonTheme.foregroundColor, AppColors.deepNight);
      });
    });
  });

  group('AppTextStyles', () {
    group('font size getters', () {
      test('should expose all font size constants', () {
        expect(AppTextStyles.affirmationDisplaySize, 24.0);
        expect(AppTextStyles.affirmationDisplayLargeSize, 32.0);
        expect(AppTextStyles.bodySize, 16.0);
        expect(AppTextStyles.headingSize, 20.0);
        expect(AppTextStyles.buttonSize, 14.0);
        expect(AppTextStyles.captionSize, 12.0);
      });
    });
  });

  group('AppColors', () {
    test('should have all zen color palette colors defined', () {
      // Primary backgrounds
      expect(AppColors.cloudWhite, const Color(0xFFFAFBFC));
      expect(AppColors.deepNight, const Color(0xFF1A1D21));

      // Accent colors
      expect(AppColors.softSage, const Color(0xFFA8C5B5));
      expect(AppColors.mistGray, const Color(0xFFE8EAED));

      // Text colors (WCAG AA compliant)
      expect(AppColors.stone, const Color(0xFF5F6672));
      expect(AppColors.zenBlack, const Color(0xFF2D3436));
      expect(AppColors.softWhite, const Color(0xFFF1F3F4));

      // Semantic colors (WCAG AA compliant)
      expect(AppColors.error, const Color(0xFFC62828));
      expect(AppColors.success, const Color(0xFF2E7D32));
    });
  });

  group('AppDimensions', () {
    test('should have all spacing constants defined', () {
      expect(AppDimensions.spacingXs, 4.0);
      expect(AppDimensions.spacingS, 8.0);
      expect(AppDimensions.spacingM, 16.0);
      expect(AppDimensions.spacingL, 24.0);
      expect(AppDimensions.spacingXl, 32.0);
      expect(AppDimensions.spacingXxl, 48.0);
    });

    test('should have border radius constants', () {
      expect(AppDimensions.borderRadiusDefault, 16.0);
      expect(AppDimensions.borderRadiusSmall, 8.0);
      expect(AppDimensions.borderRadiusLarge, 24.0);
    });

    test('should have accessibility touch target size', () {
      expect(AppDimensions.minTouchTarget, 44.0);
    });

    test('should have animation durations', () {
      expect(AppDimensions.animationDurationFast, 200);
      expect(AppDimensions.animationDurationDefault, 300);
      expect(AppDimensions.animationDurationSlow, 500);
    });

    test('should have elevation constants', () {
      expect(AppDimensions.elevationSoft, 2.0);
      expect(AppDimensions.elevationMedium, 4.0);
    });
  });
}
