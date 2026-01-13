/// Tests for responsive layout utilities.
///
/// Verifies that screens from 4 to 13 inches are properly supported.
/// Based on REQUIREMENTS.md NFR-008 (COMPAT-003).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/utils/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    group('Screen Size Detection', () {
      testWidgets('detects small screen (4 inch phone)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 568), // iPhone SE (4 inch)
              ),
              child: Builder(
                builder: (context) {
                  expect(
                    ResponsiveLayout.getScreenSize(context),
                    ScreenSize.small,
                  );
                  expect(ResponsiveLayout.isSmallScreen(context), isTrue);
                  expect(ResponsiveLayout.isTablet(context), isFalse);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('detects small screen (6 inch phone)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(414, 896), // iPhone 11 Pro Max (6.5 inch)
              ),
              child: Builder(
                builder: (context) {
                  expect(
                    ResponsiveLayout.getScreenSize(context),
                    ScreenSize.small,
                  );
                  expect(ResponsiveLayout.isSmallScreen(context), isTrue);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('detects medium screen (7 inch tablet)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(600, 960), // 7 inch tablet
              ),
              child: Builder(
                builder: (context) {
                  expect(
                    ResponsiveLayout.getScreenSize(context),
                    ScreenSize.medium,
                  );
                  expect(ResponsiveLayout.isSmallScreen(context), isFalse);
                  expect(ResponsiveLayout.isMediumOrLarger(context), isTrue);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('detects large screen (10 inch tablet)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 1280), // 10 inch tablet (iPad)
              ),
              child: Builder(
                builder: (context) {
                  expect(
                    ResponsiveLayout.getScreenSize(context),
                    ScreenSize.large,
                  );
                  expect(ResponsiveLayout.isTablet(context), isTrue);
                  expect(ResponsiveLayout.isMediumOrLarger(context), isTrue);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('detects extra large screen (13 inch tablet)',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(1024, 1366), // 13 inch iPad Pro
              ),
              child: Builder(
                builder: (context) {
                  expect(
                    ResponsiveLayout.getScreenSize(context),
                    ScreenSize.extraLarge,
                  );
                  expect(ResponsiveLayout.isTablet(context), isTrue);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('handles landscape orientation correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(896, 414), // iPhone in landscape
              ),
              child: Builder(
                builder: (context) {
                  // Should still detect as small screen (based on shortest side)
                  expect(
                    ResponsiveLayout.getScreenSize(context),
                    ScreenSize.small,
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Responsive Values', () {
      testWidgets('valueWhen returns correct value for small screen',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(320, 568)),
              child: Builder(
                builder: (context) {
                  final value = ResponsiveLayout.valueWhen<int>(
                    context: context,
                    small: 1,
                    medium: 2,
                    large: 3,
                    extraLarge: 4,
                  );
                  expect(value, 1);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('valueWhen returns correct value for large screen',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1280)),
              child: Builder(
                builder: (context) {
                  final value = ResponsiveLayout.valueWhen<int>(
                    context: context,
                    small: 1,
                    medium: 2,
                    large: 3,
                    extraLarge: 4,
                  );
                  expect(value, 3);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('valueWhen falls back to previous value if null',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1280)),
              child: Builder(
                builder: (context) {
                  final value = ResponsiveLayout.valueWhen<int>(
                    context: context,
                    small: 1,
                    // medium, large, extraLarge not provided
                  );
                  expect(value, 1); // Falls back to small
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Adaptive Layout Utilities', () {
      testWidgets('getAdaptivePadding increases with screen size',
          (tester) async {
        const sizes = [
          Size(320, 568), // Small
          Size(600, 960), // Medium
          Size(800, 1280), // Large
          Size(1024, 1366), // Extra large
        ];

        final paddings = <double>[];

        for (final size in sizes) {
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(size: size),
                child: Builder(
                  builder: (context) {
                    final padding =
                        ResponsiveLayout.getAdaptivePadding(context);
                    paddings.add(padding.left);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
        }

        // Verify padding increases with screen size
        expect(paddings[0], lessThan(paddings[1]));
        expect(paddings[1], lessThan(paddings[2]));
        expect(paddings[2], lessThan(paddings[3]));
      });

      testWidgets('getGridColumnCount increases with screen size',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(320, 568)),
              child: Builder(
                builder: (context) {
                  final columns =
                      ResponsiveLayout.getGridColumnCount(context);
                  expect(columns, 1); // Small screen = 1 column
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1024, 1366)),
              child: Builder(
                builder: (context) {
                  final columns =
                      ResponsiveLayout.getGridColumnCount(context);
                  expect(columns, 3); // Extra large screen = 3 columns
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('constrainContentWidth applies max width on tablets',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1024, 1366)),
              child: Builder(
                builder: (context) {
                  final widget = ResponsiveLayout.constrainContentWidth(
                    context: context,
                    child: Container(width: 2000),
                  );

                  // Should have Center and ConstrainedBox
                  expect(widget, isA<Center>());
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('constrainContentWidth does not apply on phones',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(320, 568)),
              child: Builder(
                builder: (context) {
                  final child = Container(width: 200);
                  final widget = ResponsiveLayout.constrainContentWidth(
                    context: context,
                    child: child,
                  );

                  // Should return child directly without wrapping
                  expect(widget, same(child));
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('getFontSizeMultiplier increases with screen size',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(320, 568)),
              child: Builder(
                builder: (context) {
                  final multiplier =
                      ResponsiveLayout.getFontSizeMultiplier(context);
                  expect(multiplier, 1.0); // Small screen baseline
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1024, 1366)),
              child: Builder(
                builder: (context) {
                  final multiplier =
                      ResponsiveLayout.getFontSizeMultiplier(context);
                  expect(multiplier, greaterThan(1.0)); // Larger on tablets
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Orientation Detection', () {
      testWidgets('detects landscape orientation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(896, 414),
              ),
              child: Builder(
                builder: (context) {
                  expect(ResponsiveLayout.isLandscape(context), isTrue);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('detects portrait orientation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(414, 896),
              ),
              child: Builder(
                builder: (context) {
                  expect(ResponsiveLayout.isLandscape(context), isFalse);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('shouldUseSideBySideLayout only on tablets in landscape',
          (tester) async {
        // Tablet in landscape
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(1280, 800),
              ),
              child: Builder(
                builder: (context) {
                  expect(
                    ResponsiveLayout.shouldUseSideBySideLayout(context),
                    isTrue,
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        // Phone in landscape (should be false)
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(896, 414),
              ),
              child: Builder(
                builder: (context) {
                  expect(
                    ResponsiveLayout.shouldUseSideBySideLayout(context),
                    isFalse,
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        // Tablet in portrait (should be false)
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 1280),
              ),
              child: Builder(
                builder: (context) {
                  expect(
                    ResponsiveLayout.shouldUseSideBySideLayout(context),
                    isFalse,
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Text Scale Factor', () {
      testWidgets('getTextScaleFactor combines system and adaptive scaling',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 568),
                textScaler: TextScaler.linear(1.0),
              ),
              child: Builder(
                builder: (context) {
                  final scale = ResponsiveLayout.getTextScaleFactor(context);
                  expect(scale, 1.0); // Base scale
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('getTextScaleFactor clamps to reasonable limits',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 568),
                textScaler: TextScaler.linear(10.0), // Extremely large
              ),
              child: Builder(
                builder: (context) {
                  final scale = ResponsiveLayout.getTextScaleFactor(context);
                  expect(scale, lessThanOrEqualTo(2.0)); // Should be clamped
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('getTextScaleFactor respects user multiplier',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 568),
                textScaler: TextScaler.linear(1.0),
              ),
              child: Builder(
                builder: (context) {
                  final scale = ResponsiveLayout.getTextScaleFactor(
                    context,
                    userMultiplier: 1.2,
                  );
                  expect(scale, 1.2); // Should apply user multiplier
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Edge Cases', () {
      testWidgets('handles very small screens (minimum 4 inch)',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 480), // Very small 4 inch screen
              ),
              child: Builder(
                builder: (context) {
                  // Should still work and categorize as small
                  expect(
                    ResponsiveLayout.getScreenSize(context),
                    ScreenSize.small,
                  );
                  expect(ResponsiveLayout.useCompactLayout(context), isTrue);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('handles very large screens (maximum 13 inch)',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(1366, 1024), // 13 inch iPad Pro landscape
              ),
              child: Builder(
                builder: (context) {
                  // Should categorize as extra large
                  expect(
                    ResponsiveLayout.getScreenSize(context),
                    ScreenSize.extraLarge,
                  );
                  expect(ResponsiveLayout.isTablet(context), isTrue);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });
  });
}
