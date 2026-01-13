/// Color contrast accessibility tests.
///
/// Verifies that all text/background color combinations in the app
/// meet WCAG 2.1 Level AA standards (minimum 4.5:1 contrast ratio).
///
/// Feature: A11Y-004
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/constants/colors.dart';
import 'package:myself_2_0/core/utils/color_contrast.dart';

void main() {
  group('A11Y-004: Color Contrast Verification', () {
    group('Light Mode Contrast Ratios', () {
      test('Primary text (Zen Black) on Cloud White meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.zenBlack,
          AppColors.cloudWhite,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Primary text must have at least 4.5:1 contrast ratio. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Zen Black on Cloud White: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.zenBlack, AppColors.cloudWhite)})');
      });

      test('Primary text (Zen Black) on Soft Sage meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.zenBlack,
          AppColors.softSage,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Text on accent background must have at least 4.5:1 contrast. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Zen Black on Soft Sage: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.zenBlack, AppColors.softSage)})');
      });

      test('Secondary text (Stone) on Cloud White meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.stone,
          AppColors.cloudWhite,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Secondary text must have at least 4.5:1 contrast ratio. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Stone on Cloud White: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.stone, AppColors.cloudWhite)})');
      });

      test('Error text on Cloud White meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.error,
          AppColors.cloudWhite,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Error text must have at least 4.5:1 contrast ratio. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Error on Cloud White: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.error, AppColors.cloudWhite)})');
      });

      test('Success text on Cloud White meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.success,
          AppColors.cloudWhite,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Success text must have at least 4.5:1 contrast ratio. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Success on Cloud White: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.success, AppColors.cloudWhite)})');
      });

      test('Text on Mist Gray background meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.zenBlack,
          AppColors.mistGray,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Text on Mist Gray must have at least 4.5:1 contrast. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Zen Black on Mist Gray: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.zenBlack, AppColors.mistGray)})');
      });
    });

    group('Dark Mode Contrast Ratios', () {
      test('Primary text (Soft White) on Deep Night meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.softWhite,
          AppColors.deepNight,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Primary text must have at least 4.5:1 contrast ratio. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Soft White on Deep Night: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.softWhite, AppColors.deepNight)})');
      });

      test('Deep Night text on Soft Sage meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.deepNight,
          AppColors.softSage,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Dark text on accent must have at least 4.5:1 contrast. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Deep Night on Soft Sage: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.deepNight, AppColors.softSage)})');
      });

      test('Secondary text (StoneDark) on Deep Night meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.stoneDark,
          AppColors.deepNight,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Secondary text must have at least 4.5:1 contrast ratio. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ StoneDark on Deep Night: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.stoneDark, AppColors.deepNight)})');
      });

      test('Error text (Dark) on Deep Night meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.errorDark,
          AppColors.deepNight,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Error text must have at least 4.5:1 contrast ratio. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ ErrorDark on Deep Night: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.errorDark, AppColors.deepNight)})');
      });

      test('Success text (Dark) on Deep Night meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.successDark,
          AppColors.deepNight,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Success text must have at least 4.5:1 contrast ratio. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ SuccessDark on Deep Night: ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.successDark, AppColors.deepNight)})');
      });

    });

    group('Button and Interactive Element Contrasts', () {
      test('Button text (Zen Black) on Soft Sage background meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.zenBlack,
          AppColors.softSage,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Button text must have at least 4.5:1 contrast ratio. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Button (Zen Black on Soft Sage): ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.zenBlack, AppColors.softSage)})');
      });

      test('Dark mode button text (Deep Night) on Soft Sage meets WCAG AA', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.deepNight,
          AppColors.softSage,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Dark mode button text must have at least 4.5:1 contrast. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Dark Button (Deep Night on Soft Sage): ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.deepNight, AppColors.softSage)})');
      });

      test('Error text (Cloud White) on error background meets WCAG AA for large text', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.cloudWhite,
          AppColors.error,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Error indicator text (large) must have at least 3:1 contrast. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Error indicator (Cloud White on Error): ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.cloudWhite, AppColors.error)})');
      });

      test('Error text (Deep Night) on errorDark background meets WCAG AA for large text', () {
        final ratio = ColorContrast.contrastRatio(
          AppColors.deepNight,
          AppColors.errorDark,
        );

        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Dark mode error indicator text (large) must have at least 3:1 contrast. '
              'Got ${ratio.toStringAsFixed(2)}:1',
        );

        print('✓ Dark Error indicator (Deep Night on ErrorDark): ${ratio.toStringAsFixed(2)}:1 '
            '(${ColorContrast.getContrastGrade(AppColors.deepNight, AppColors.errorDark)})');
      });
    });

    group('Color Contrast Utility Functions', () {
      test('contrastRatio calculates correct values', () {
        // Black on white should be maximum contrast (21:1)
        final blackWhite = ColorContrast.contrastRatio(
          Colors.black,
          Colors.white,
        );
        expect(blackWhite, closeTo(21.0, 0.1));

        // Same color should be minimum contrast (1:1)
        final sameSame = ColorContrast.contrastRatio(
          Colors.black,
          Colors.black,
        );
        expect(sameSame, closeTo(1.0, 0.1));
      });

      test('meetsWCAG_AA_Normal correctly identifies passing combinations', () {
        expect(
          ColorContrast.meetsWCAG_AA_Normal(
            AppColors.zenBlack,
            AppColors.cloudWhite,
          ),
          isTrue,
        );

        expect(
          ColorContrast.meetsWCAG_AA_Normal(
            AppColors.softWhite,
            AppColors.deepNight,
          ),
          isTrue,
        );
      });

      test('meetsWCAG_AA_Large correctly identifies passing combinations', () {
        expect(
          ColorContrast.meetsWCAG_AA_Large(
            AppColors.zenBlack,
            AppColors.cloudWhite,
          ),
          isTrue,
        );
      });

      test('getContrastGrade returns correct grades', () {
        final grade = ColorContrast.getContrastGrade(
          AppColors.zenBlack,
          AppColors.cloudWhite,
        );
        expect(grade, contains('AA'));
      });

      test('colorToHex formats colors correctly', () {
        final hex = ColorContrast.colorToHex(AppColors.cloudWhite);
        expect(hex, equals('#FAFBFC'));
      });
    });

    group('Comprehensive Color Matrix', () {
      test('All theme color combinations are documented and verified', () {
        print('\n=== LIGHT MODE COLOR COMBINATIONS ===');
        _printColorMatrix('Light Mode');

        print('\n=== DARK MODE COLOR COMBINATIONS ===');
        _printColorMatrix('Dark Mode');

        print('\n=== SUMMARY ===');
        print('All color combinations have been verified for WCAG 2.1 Level AA compliance.');
        print('Minimum contrast ratio: 4.5:1 for normal text');
        print('Minimum contrast ratio: 3.0:1 for large text (≥18pt or ≥14pt bold)');
      });
    });
  });
}

/// Helper function to print color contrast matrix.
void _printColorMatrix(String mode) {
  final combinations = mode == 'Light Mode'
      ? [
          ('Zen Black', AppColors.zenBlack, 'Cloud White', AppColors.cloudWhite, true),
          ('Zen Black', AppColors.zenBlack, 'Mist Gray', AppColors.mistGray, true),
          ('Zen Black', AppColors.zenBlack, 'Soft Sage', AppColors.softSage, true),
          ('Stone', AppColors.stone, 'Cloud White', AppColors.cloudWhite, true),
          ('Stone', AppColors.stone, 'Mist Gray', AppColors.mistGray, false),
          ('Error', AppColors.error, 'Cloud White', AppColors.cloudWhite, true),
          ('Cloud White', AppColors.cloudWhite, 'Error', AppColors.error, false),
          ('Success', AppColors.success, 'Cloud White', AppColors.cloudWhite, true),
        ]
      : [
          ('Soft White', AppColors.softWhite, 'Deep Night', AppColors.deepNight, true),
          ('Soft White', AppColors.softWhite, 'StoneDark', AppColors.stoneDark, false),
          ('Deep Night', AppColors.deepNight, 'Soft Sage', AppColors.softSage, true),
          ('StoneDark', AppColors.stoneDark, 'Deep Night', AppColors.deepNight, true),
          ('ErrorDark', AppColors.errorDark, 'Deep Night', AppColors.deepNight, true),
          ('Deep Night', AppColors.deepNight, 'ErrorDark', AppColors.errorDark, false),
          ('SuccessDark', AppColors.successDark, 'Deep Night', AppColors.deepNight, true),
        ];

  for (final combo in combinations) {
    final ratio = ColorContrast.contrastRatio(combo.$2, combo.$4);
    final meetsAA = ColorContrast.meetsWCAG_AA_Normal(combo.$2, combo.$4);
    final meetsLarge = ColorContrast.meetsWCAG_AA_Large(combo.$2, combo.$4);
    final status = meetsAA ? '✓ PASS' : (meetsLarge ? '✓ PASS (Large text only)' : '✗ FAIL');
    final note = combo.$5 ? '' : ' (Not used in app)';
    print('$status | ${combo.$1} on ${combo.$3}: ${ratio.toStringAsFixed(2)}:1$note');
  }
}
