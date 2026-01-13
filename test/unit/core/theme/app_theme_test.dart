import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/theme/app_theme.dart';
import 'package:myself_2_0/core/theme/text_styles.dart';
import 'package:myself_2_0/core/constants/colors.dart';

void main() {
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

      test('should have text theme configured', () {
        final theme = AppTheme.lightTheme;
        expect(theme.textTheme.displayLarge, isNotNull);
        expect(theme.textTheme.displayMedium, isNotNull);
        expect(theme.textTheme.bodyLarge, isNotNull);
        expect(theme.textTheme.labelLarge, isNotNull);
      });

      test('should have proper card theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.cardTheme.color, AppColors.cloudWhite);
        expect(theme.cardTheme.elevation, isNotNull);
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

      test('should have text theme configured', () {
        final theme = AppTheme.darkTheme;
        expect(theme.textTheme.displayLarge, isNotNull);
        expect(theme.textTheme.displayMedium, isNotNull);
        expect(theme.textTheme.bodyLarge, isNotNull);
        expect(theme.textTheme.labelLarge, isNotNull);
      });

      test('should have proper card theme', () {
        final theme = AppTheme.darkTheme;
        expect(theme.cardTheme.color, AppColors.deepNight);
        expect(theme.cardTheme.elevation, isNotNull);
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
    group('lightTextTheme', () {
      test('should have all required text styles', () {
        final textTheme = AppTextStyles.lightTextTheme;
        expect(textTheme.displayLarge, isNotNull);
        expect(textTheme.displayMedium, isNotNull);
        expect(textTheme.displaySmall, isNotNull);
        expect(textTheme.headlineLarge, isNotNull);
        expect(textTheme.headlineMedium, isNotNull);
        expect(textTheme.headlineSmall, isNotNull);
        expect(textTheme.titleLarge, isNotNull);
        expect(textTheme.titleMedium, isNotNull);
        expect(textTheme.titleSmall, isNotNull);
        expect(textTheme.bodyLarge, isNotNull);
        expect(textTheme.bodyMedium, isNotNull);
        expect(textTheme.bodySmall, isNotNull);
        expect(textTheme.labelLarge, isNotNull);
        expect(textTheme.labelMedium, isNotNull);
        expect(textTheme.labelSmall, isNotNull);
      });

      test('display styles should use proper colors for light mode', () {
        final textTheme = AppTextStyles.lightTextTheme;
        expect(textTheme.displayLarge!.color, AppColors.zenBlack);
        expect(textTheme.displayMedium!.color, AppColors.zenBlack);
      });

      test('body styles should have proper font sizes', () {
        final textTheme = AppTextStyles.lightTextTheme;
        expect(textTheme.bodyLarge!.fontSize, AppTextStyles.bodySize);
        expect(textTheme.bodySmall!.fontSize, AppTextStyles.captionSize);
      });
    });

    group('darkTextTheme', () {
      test('should have all required text styles', () {
        final textTheme = AppTextStyles.darkTextTheme;
        expect(textTheme.displayLarge, isNotNull);
        expect(textTheme.displayMedium, isNotNull);
        expect(textTheme.displaySmall, isNotNull);
        expect(textTheme.headlineLarge, isNotNull);
        expect(textTheme.headlineMedium, isNotNull);
        expect(textTheme.headlineSmall, isNotNull);
        expect(textTheme.titleLarge, isNotNull);
        expect(textTheme.titleMedium, isNotNull);
        expect(textTheme.titleSmall, isNotNull);
        expect(textTheme.bodyLarge, isNotNull);
        expect(textTheme.bodyMedium, isNotNull);
        expect(textTheme.bodySmall, isNotNull);
        expect(textTheme.labelLarge, isNotNull);
        expect(textTheme.labelMedium, isNotNull);
        expect(textTheme.labelSmall, isNotNull);
      });

      test('display styles should use proper colors for dark mode', () {
        final textTheme = AppTextStyles.darkTextTheme;
        expect(textTheme.displayLarge!.color, AppColors.softWhite);
        expect(textTheme.displayMedium!.color, AppColors.softWhite);
      });

      test('body styles should have proper font sizes', () {
        final textTheme = AppTextStyles.darkTextTheme;
        expect(textTheme.bodyLarge!.fontSize, AppTextStyles.bodySize);
        expect(textTheme.bodySmall!.fontSize, AppTextStyles.captionSize);
      });
    });

    group('helper methods', () {
      test('playfairDisplay should return a text style', () {
        final style = AppTextStyles.playfairDisplay();
        expect(style, isNotNull);
        expect(style.fontSize, AppTextStyles.affirmationDisplaySize);
      });

      test('playfairDisplay should accept custom parameters', () {
        final style = AppTextStyles.playfairDisplay(
          fontSize: 40.0,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        );
        expect(style.fontSize, 40.0);
        expect(style.fontWeight, FontWeight.bold);
        expect(style.color, Colors.red);
      });

      test('inter should return a text style', () {
        final style = AppTextStyles.inter();
        expect(style, isNotNull);
        expect(style.fontSize, AppTextStyles.bodySize);
      });

      test('inter should accept custom parameters', () {
        final style = AppTextStyles.inter(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        );
        expect(style.fontSize, 20.0);
        expect(style.fontWeight, FontWeight.w600);
        expect(style.color, Colors.blue);
      });
    });

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

      // Text colors
      expect(AppColors.stone, const Color(0xFF6B7280));
      expect(AppColors.zenBlack, const Color(0xFF2D3436));
      expect(AppColors.softWhite, const Color(0xFFF1F3F4));

      // Semantic colors
      expect(AppColors.error, const Color(0xFFE57373));
      expect(AppColors.success, const Color(0xFF81C784));
    });
  });
}
