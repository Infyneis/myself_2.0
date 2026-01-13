/// Touch target size accessibility tests.
///
/// Verifies that all interactive elements meet the minimum 44x44 points
/// touch target size requirement as per NFR-014 and A11Y-003.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/constants/dimensions.dart';
import 'package:myself_2_0/core/utils/accessibility_helper.dart';

void main() {
  group('Touch Target Size - A11Y-003', () {
    testWidgets('Minimum touch target constant is defined correctly',
        (tester) async {
      expect(AppDimensions.minTouchTarget, equals(44.0));
    });

    testWidgets('AccessibleTouchTarget wraps child with minimum constraints',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTouchTarget(
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Find the Container that AccessibleTouchTarget creates
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final Container container = tester.widget(containerFinder);
      expect(container.constraints, isNotNull);
      expect(
        container.constraints!.minWidth,
        equals(AppDimensions.minTouchTarget),
      );
      expect(
        container.constraints!.minHeight,
        equals(AppDimensions.minTouchTarget),
      );
    });

    testWidgets('withMinTouchTarget extension works correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ).withMinTouchTarget(),
          ),
        ),
      );

      // Verify the extension creates the proper wrapper
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final Container container = tester.widget(containerFinder);
      expect(
        container.constraints!.minWidth,
        greaterThanOrEqualTo(AppDimensions.minTouchTarget),
      );
      expect(
        container.constraints!.minHeight,
        greaterThanOrEqualTo(AppDimensions.minTouchTarget),
      );
    });

    group('Button Styles', () {
      testWidgets('TextButton style has minimum touch target',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: TextButton(
                    style: AccessibleButtonStyles.textButton(context),
                    onPressed: () {},
                    child: const Text('Test'),
                  ),
                );
              },
            ),
          ),
        );

        final textButton = tester.widget<TextButton>(find.byType(TextButton));
        final style = textButton.style!;
        final minimumSize = style.minimumSize!.resolve({});

        expect(minimumSize!.width, equals(AppDimensions.minTouchTarget));
        expect(minimumSize.height, equals(AppDimensions.minTouchTarget));
      });

      testWidgets('ElevatedButton style has minimum touch target',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    style: AccessibleButtonStyles.elevatedButton(context),
                    onPressed: () {},
                    child: const Text('Test'),
                  ),
                );
              },
            ),
          ),
        );

        final elevatedButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final style = elevatedButton.style!;
        final minimumSize = style.minimumSize!.resolve({});

        expect(minimumSize!.width, equals(AppDimensions.minTouchTarget));
        expect(minimumSize.height, equals(AppDimensions.minTouchTarget));
      });

      testWidgets('IconButton style has minimum touch target',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: IconButton(
                    style: AccessibleButtonStyles.iconButton(context),
                    onPressed: () {},
                    icon: const Icon(Icons.settings),
                  ),
                );
              },
            ),
          ),
        );

        final iconButton =
            tester.widget<IconButton>(find.byType(IconButton));
        final style = iconButton.style!;
        final minimumSize = style.minimumSize!.resolve({});

        expect(minimumSize!.width, equals(AppDimensions.minTouchTarget));
        expect(minimumSize.height, equals(AppDimensions.minTouchTarget));
      });

      testWidgets('FilledButton style has minimum touch target',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: FilledButton(
                    style: AccessibleButtonStyles.filledButton(context),
                    onPressed: () {},
                    child: const Text('Test'),
                  ),
                );
              },
            ),
          ),
        );

        final filledButton =
            tester.widget<FilledButton>(find.byType(FilledButton));
        final style = filledButton.style!;
        final minimumSize = style.minimumSize!.resolve({});

        expect(minimumSize!.width, equals(AppDimensions.minTouchTarget));
        expect(minimumSize.height, equals(AppDimensions.minTouchTarget));
      });
    });

    testWidgets('IconButton in Container meets minimum size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              constraints: const BoxConstraints(
                minWidth: AppDimensions.minTouchTarget,
                minHeight: AppDimensions.minTouchTarget,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final Container container = tester.widget(containerFinder);
      expect(
        container.constraints!.minWidth,
        greaterThanOrEqualTo(AppDimensions.minTouchTarget),
      );
      expect(
        container.constraints!.minHeight,
        greaterThanOrEqualTo(AppDimensions.minTouchTarget),
      );
    });

    testWidgets('FloatingActionButton meets minimum size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: SizedBox(
              width: AppDimensions.minTouchTarget + 12,
              height: AppDimensions.minTouchTarget + 12,
              child: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      );

      final sizedBoxFinder = find.ancestor(
        of: find.byType(FloatingActionButton),
        matching: find.byType(SizedBox),
      );

      expect(sizedBoxFinder, findsOneWidget);

      final SizedBox sizedBox = tester.widget(sizedBoxFinder);
      expect(
        sizedBox.width,
        greaterThanOrEqualTo(AppDimensions.minTouchTarget),
      );
      expect(
        sizedBox.height,
        greaterThanOrEqualTo(AppDimensions.minTouchTarget),
      );
    });

    testWidgets('InkWell with Container meets minimum height',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InkWell(
              onTap: () {},
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppDimensions.minTouchTarget,
                ),
                padding: const EdgeInsets.all(16),
                child: const Text('Tap me'),
              ),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final Container container = tester.widget(containerFinder);
      expect(
        container.constraints!.minHeight,
        greaterThanOrEqualTo(AppDimensions.minTouchTarget),
      );
    });
  });

  group('Common Interactive Elements', () {
    testWidgets('Standard ElevatedButton meets minimum size',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  AppDimensions.minTouchTarget,
                  AppDimensions.minTouchTarget,
                ),
              ),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final minimumSize = button.style!.minimumSize!.resolve({});

      expect(minimumSize!.width, equals(AppDimensions.minTouchTarget));
      expect(minimumSize.height, equals(AppDimensions.minTouchTarget));
    });

    testWidgets('Standard TextButton meets minimum size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: const Size(
                  AppDimensions.minTouchTarget,
                  AppDimensions.minTouchTarget,
                ),
              ),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      final button = tester.widget<TextButton>(find.byType(TextButton));
      final minimumSize = button.style!.minimumSize!.resolve({});

      expect(minimumSize!.width, equals(AppDimensions.minTouchTarget));
      expect(minimumSize.height, equals(AppDimensions.minTouchTarget));
    });

    testWidgets('GestureDetector with Container meets minimum size',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () {},
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: AppDimensions.minTouchTarget,
                  minHeight: AppDimensions.minTouchTarget,
                ),
                child: const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      final Container container = tester.widget(containerFinder);

      expect(
        container.constraints!.minWidth,
        greaterThanOrEqualTo(AppDimensions.minTouchTarget),
      );
      expect(
        container.constraints!.minHeight,
        greaterThanOrEqualTo(AppDimensions.minTouchTarget),
      );
    });
  });
}
