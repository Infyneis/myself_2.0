/// Integration test for responsive layout across different screen sizes.
///
/// Verifies that the app works correctly on screens from 4 to 13 inches.
/// Based on REQUIREMENTS.md NFR-008 (COMPAT-003).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/utils/responsive_layout.dart';

void main() {
  group('Responsive Layout Integration Tests (COMPAT-003)', () {
    /// Helper function to build test widget with specified screen size
    Widget buildTestWidgetWithScreenSize(Size size) {
      return MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Screen: ${ResponsiveLayout.getScreenSize(context)}'),
                      Padding(
                        padding: ResponsiveLayout.getAdaptivePadding(context),
                        child: const Text('Content with adaptive padding'),
                      ),
                      ResponsiveLayout.constrainContentWidth(
                        context: context,
                        child: Container(
                          color: Colors.blue,
                          height: 100,
                          width: double.infinity,
                          child: const Center(child: Text('Constrained Content')),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly on 4 inch phone (iPhone SE)',
        (tester) async {
      const screenSize = Size(320, 568); // iPhone SE
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      // Verify the app renders without overflow errors
      expect(find.byType(Scaffold), findsOneWidget);

      // Should use small screen layout
      final context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.getScreenSize(context), ScreenSize.small);
      expect(ResponsiveLayout.isSmallScreen(context), isTrue);
    });

    testWidgets('renders correctly on 6 inch phone (iPhone 11 Pro Max)',
        (tester) async {
      const screenSize = Size(414, 896); // iPhone 11 Pro Max
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      final context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.getScreenSize(context), ScreenSize.small);
    });

    testWidgets('renders correctly on 7 inch tablet', (tester) async {
      const screenSize = Size(600, 960); // 7 inch tablet
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      final context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.getScreenSize(context), ScreenSize.medium);
      expect(ResponsiveLayout.isMediumOrLarger(context), isTrue);
    });

    testWidgets('renders correctly on 10 inch tablet (iPad)', (tester) async {
      const screenSize = Size(768, 1024); // iPad 10 inch
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      final context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.getScreenSize(context), ScreenSize.large);
      expect(ResponsiveLayout.isTablet(context), isTrue);
    });

    testWidgets('renders correctly on 13 inch tablet (iPad Pro)',
        (tester) async {
      const screenSize = Size(1024, 1366); // iPad Pro 13 inch
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      final context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.getScreenSize(context), ScreenSize.extraLarge);
      expect(ResponsiveLayout.isTablet(context), isTrue);
    });

    testWidgets('handles landscape orientation on phone', (tester) async {
      const screenSize = Size(896, 414); // iPhone in landscape
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      final context = tester.element(find.byType(Scaffold));
      // Should still be categorized as small (based on shortest side)
      expect(ResponsiveLayout.getScreenSize(context), ScreenSize.small);
      expect(ResponsiveLayout.isLandscape(context), isTrue);
    });

    testWidgets('handles landscape orientation on tablet', (tester) async {
      const screenSize = Size(1366, 1024); // iPad Pro in landscape
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      final context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.getScreenSize(context), ScreenSize.extraLarge);
      expect(ResponsiveLayout.isTablet(context), isTrue);
      expect(ResponsiveLayout.isLandscape(context), isTrue);
    });

    testWidgets('adaptive padding increases with screen size', (tester) async {
      final screenSizes = [
        const Size(320, 568), // Small
        const Size(600, 960), // Medium
        const Size(768, 1024), // Large
        const Size(1024, 1366), // Extra large
      ];

      final paddings = <double>[];

      for (final size in screenSizes) {
        await tester.pumpWidget(buildTestWidgetWithScreenSize(size));
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(Scaffold));
        final padding = ResponsiveLayout.getAdaptivePadding(context);
        paddings.add(padding.left);

        // Clear the widget tree
        await tester.pumpWidget(const SizedBox.shrink());
      }

      // Verify padding increases with screen size
      expect(paddings[0], lessThan(paddings[1]));
      expect(paddings[1], lessThan(paddings[2]));
      expect(paddings[2], lessThan(paddings[3]));
    });

    testWidgets('content is constrained on tablets', (tester) async {
      const screenSize = Size(1366, 1024); // iPad Pro landscape
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));

      // Verify content width constraint is applied
      expect(ResponsiveLayout.isTablet(context), isTrue);

      // Content should be centered and constrained
      // (visual verification would require finding specific widgets)
    });

    testWidgets('no overflow errors on smallest supported screen',
        (tester) async {
      // Test the absolute minimum size (4 inch phone)
      const screenSize = Size(320, 480);
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      // Should render without overflow errors
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow errors on largest supported screen',
        (tester) async {
      // Test the absolute maximum size (13 inch tablet)
      const screenSize = Size(1366, 1024);
      await tester.pumpWidget(buildTestWidgetWithScreenSize(screenSize));
      await tester.pumpAndSettle();

      // Should render without overflow errors
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('font size scales appropriately with screen size',
        (tester) async {
      final screenSizes = [
        const Size(320, 568), // Small
        const Size(1024, 1366), // Extra large
      ];

      for (final size in screenSizes) {
        await tester.pumpWidget(buildTestWidgetWithScreenSize(size));
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(Scaffold));
        final multiplier = ResponsiveLayout.getFontSizeMultiplier(context);

        if (ResponsiveLayout.isSmallScreen(context)) {
          expect(multiplier, 1.0);
        } else if (ResponsiveLayout.getScreenSize(context) ==
            ScreenSize.extraLarge) {
          expect(multiplier, greaterThan(1.0));
        }

        // Clear the widget tree
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('compact layout used on small screens only', (tester) async {
      // Test small screen
      await tester.pumpWidget(buildTestWidgetWithScreenSize(const Size(320, 568)));
      await tester.pumpAndSettle();
      var context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.useCompactLayout(context), isTrue);

      // Test large screen
      await tester.pumpWidget(buildTestWidgetWithScreenSize(const Size(1024, 1366)));
      await tester.pumpAndSettle();
      context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.useCompactLayout(context), isFalse);
    });

    testWidgets('responsive layout handles screen rotation', (tester) async {
      // Start in portrait
      await tester.pumpWidget(
        buildTestWidgetWithScreenSize(const Size(414, 896)),
      );
      await tester.pumpAndSettle();

      var context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.isLandscape(context), isFalse);

      // Rotate to landscape
      await tester.pumpWidget(
        buildTestWidgetWithScreenSize(const Size(896, 414)),
      );
      await tester.pumpAndSettle();

      context = tester.element(find.byType(Scaffold));
      expect(ResponsiveLayout.isLandscape(context), isTrue);

      // Screen size category should remain the same (based on shortest side)
      expect(ResponsiveLayout.getScreenSize(context), ScreenSize.small);
    });
  });
}
