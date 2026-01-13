/// Tests for AffirmationInput widget.
///
/// Tests multi-line support, character limit, validation, and visual feedback.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/constants/dimensions.dart';
import 'package:myself_2_0/features/affirmations/presentation/widgets/affirmation_input.dart';

void main() {
  group('AffirmationInput Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with default configuration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('0 / 280'), findsOneWidget);
      expect(find.text('1 line'), findsOneWidget);
    });

    testWidgets('displays hint text when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
              hintText: 'Test hint',
            ),
          ),
        ),
      );

      expect(find.text('Test hint'), findsOneWidget);
    });

    testWidgets('displays default hint text when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Enter your affirmation...'), findsOneWidget);
    });

    testWidgets('updates character counter when text is entered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      // Enter some text
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      expect(find.text('5 / 280'), findsOneWidget);
    });

    testWidgets('updates line counter for multi-line text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      // Enter multi-line text
      await tester.enterText(find.byType(TextField), 'Line 1\nLine 2\nLine 3');
      await tester.pump();

      expect(find.text('3 lines'), findsOneWidget);
    });

    testWidgets('respects character limit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
              maxLength: 10,
            ),
          ),
        ),
      );

      // Try to enter more than limit
      await tester.enterText(find.byType(TextField), 'This is more than ten characters');
      await tester.pump();

      // Check that text is limited
      expect(controller.text.length, lessThanOrEqualTo(10));
      expect(find.textContaining('/ 10'), findsOneWidget);
    });

    testWidgets('shows warning state when near character limit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
              maxLength: 10,
            ),
          ),
        ),
      );

      // Enter text near limit (over 90%)
      await tester.enterText(find.byType(TextField), 'Twelve ch');
      await tester.pump();

      // Verify character counter shows near limit
      expect(find.text('9 / 10'), findsOneWidget);
    });

    testWidgets('shows error state when at character limit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
              maxLength: 10,
            ),
          ),
        ),
      );

      // Enter text at limit
      await tester.enterText(find.byType(TextField), 'Ten chars!');
      await tester.pump();

      // Verify character counter shows at limit
      expect(find.text('10 / 10'), findsOneWidget);
    });

    testWidgets('calls onChanged callback when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      expect(changedValue, equals('Test'));
    });

    testWidgets('supports multi-line input with proper keyboard type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, equals(TextInputType.multiline));
    });

    testWidgets('uses newline text input action by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textInputAction, equals(TextInputAction.newline));
    });

    testWidgets('respects custom minLines and maxLines', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
              minLines: 5,
              maxLines: 10,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.minLines, equals(5));
      expect(textField.maxLines, equals(10));
    });

    testWidgets('autofocuses when autofocus is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
              autofocus: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
    });

    testWidgets('has proper accessibility semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      // Verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);

      // Check that TextField has accessibility features enabled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enableInteractiveSelection, isTrue);
    });

    testWidgets('uses default maxLength of 280 characters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('0 / ${AppDimensions.maxAffirmationLength}'), findsOneWidget);
    });

    testWidgets('handles custom FocusNode', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        ),
      );

      expect(focusNode.hasFocus, isFalse);

      // Request focus
      focusNode.requestFocus();
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);

      focusNode.dispose();
    });

    testWidgets('shows line count as singular for single line', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Single line');
      await tester.pump();

      expect(find.text('1 line'), findsOneWidget);
    });

    testWidgets('shows line count as plural for multiple lines', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Line 1\nLine 2');
      await tester.pump();

      expect(find.text('2 lines'), findsOneWidget);
    });

    testWidgets('enables smart quotes and dashes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.smartQuotesType, equals(SmartQuotesType.enabled));
      expect(textField.smartDashesType, equals(SmartDashesType.enabled));
    });

    testWidgets('has interactive selection enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enableInteractiveSelection, isTrue);
    });
  });
}
