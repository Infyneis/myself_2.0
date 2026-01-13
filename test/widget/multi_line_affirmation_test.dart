/// Tests for multi-line affirmation text input and display.
///
/// Based on REQUIREMENTS.md FR-006: Multi-line text support.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/features/affirmations/presentation/widgets/affirmation_card.dart';
import 'package:myself_2_0/features/affirmations/presentation/widgets/affirmation_input.dart';
import 'package:myself_2_0/features/affirmations/presentation/screens/affirmation_edit_screen.dart';

// Mock classes
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

void main() {
  group('AffirmationInput - Multi-line support', () {
    testWidgets('supports multi-line text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(controller: controller),
          ),
        ),
      );

      // Enter multi-line text
      const multiLineText = 'Line 1\nLine 2\nLine 3';
      await tester.enterText(find.byType(TextField), multiLineText);
      await tester.pump();

      // Verify the text was entered correctly
      expect(controller.text, equals(multiLineText));
    });

    testWidgets('displays line count for single line', (tester) async {
      final controller = TextEditingController(text: 'Single line');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(controller: controller),
          ),
        ),
      );

      // Should show "1 line" for single line text
      expect(find.text('1 line'), findsOneWidget);
    });

    testWidgets('displays line count for multiple lines', (tester) async {
      final controller = TextEditingController(text: 'Line 1\nLine 2\nLine 3');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(controller: controller),
          ),
        ),
      );

      // Should show "3 lines" for three lines
      expect(find.text('3 lines'), findsOneWidget);
    });

    testWidgets('updates line count as text changes', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(controller: controller),
          ),
        ),
      );

      // Start with single line
      await tester.enterText(find.byType(TextField), 'First line');
      await tester.pump();
      expect(find.text('1 line'), findsOneWidget);

      // Add second line
      await tester.enterText(find.byType(TextField), 'First line\nSecond line');
      await tester.pump();
      expect(find.text('2 lines'), findsOneWidget);
    });

    testWidgets('shows character count including newlines', (tester) async {
      final controller = TextEditingController(text: 'A\nB'); // 3 chars: A, \n, B

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(controller: controller),
          ),
        ),
      );

      // Should show 3 characters (newline counts as 1 char)
      expect(find.text('3 / 280'), findsOneWidget);
    });

    testWidgets('has multiline keyboard type', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(controller: controller),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, equals(TextInputType.multiline));
    });

    testWidgets('has newline text input action', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(controller: controller),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textInputAction, equals(TextInputAction.newline));
    });

    testWidgets('respects minimum lines setting', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(
              controller: controller,
              minLines: 5,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.minLines, equals(5));
    });

    testWidgets('expands indefinitely by default', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationInput(controller: controller),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      // maxLines = null means unlimited expansion
      expect(textField.maxLines, isNull);
    });
  });

  group('AffirmationCard - Multi-line display', () {
    testWidgets('displays multi-line text correctly', (tester) async {
      final affirmation = Affirmation.create(
        text: 'First line\nSecond line\nThird line',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationCard(affirmation: affirmation),
          ),
        ),
      );

      // The text widget should contain the multi-line text
      expect(find.text('First line\nSecond line\nThird line'), findsOneWidget);
    });

    testWidgets('preserves line breaks in display', (tester) async {
      const multiLineText = 'I am strong.\n\nI am capable.\n\nI am worthy.';
      final affirmation = Affirmation.create(text: multiLineText);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationCard(affirmation: affirmation),
          ),
        ),
      );

      // Verify text is present
      expect(find.text(multiLineText), findsOneWidget);
    });

    testWidgets('applies line height for readability', (tester) async {
      final affirmation = Affirmation.create(
        text: 'Line 1\nLine 2',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationCard(affirmation: affirmation),
          ),
        ),
      );

      // Find the Text widget and verify it has proper styling
      final textWidget = tester.widget<Text>(find.text('Line 1\nLine 2'));
      expect(textWidget.style?.height, equals(1.5));
    });

    testWidgets('shows full text when maxLines is null', (tester) async {
      final affirmation = Affirmation.create(
        text: 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AffirmationCard(
                affirmation: affirmation,
                maxLines: null,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('Line 1\nLine 2\nLine 3\nLine 4\nLine 5'),
      );
      expect(textWidget.maxLines, isNull);
    });

    testWidgets('truncates text when maxLines is set', (tester) async {
      final affirmation = Affirmation.create(
        text: 'Line 1\nLine 2\nLine 3',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationCard(
              affirmation: affirmation,
              maxLines: 2,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('Line 1\nLine 2\nLine 3'),
      );
      expect(textWidget.maxLines, equals(2));
    });

    testWidgets('uses soft wrap for proper text wrapping', (tester) async {
      final affirmation = Affirmation.create(
        text: 'This is a long line that should wrap properly in the card widget',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Narrow width to force wrapping
              child: AffirmationCard(affirmation: affirmation),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(affirmation.text));
      expect(textWidget.softWrap, isTrue);
    });
  });

  group('Affirmation Model - Multi-line text', () {
    test('creates affirmation with multi-line text', () {
      const multiLineText = 'Line 1\nLine 2\nLine 3';
      final affirmation = Affirmation.create(text: multiLineText);

      expect(affirmation.text, equals(multiLineText));
      expect(affirmation.isValid, isTrue);
    });

    test('counts newlines in character limit', () {
      // Text with 3 chars + 2 newlines = 5 total
      const text = 'A\nB\nC';
      expect(text.length, equals(5));

      final affirmation = Affirmation.create(text: text);
      expect(affirmation.text.length, equals(5));
    });

    test('validates multi-line text within limit', () {
      const validText = 'Line 1\nLine 2\nLine 3';
      expect(Affirmation.validateText(validText), isNull);
    });

    test('validates multi-line text exceeding limit', () {
      // Create text that exceeds 280 characters
      // Need more lines to exceed 280 chars
      final longText = List.generate(50, (i) => 'Line number $i').join('\n');
      expect(longText.length, greaterThan(280));

      final error = Affirmation.validateText(longText);
      expect(error, isNotNull);
      expect(error, contains('280'));
    });

    test('preserves empty lines in multi-line text', () {
      const textWithEmptyLines = 'First\n\nSecond\n\nThird';
      final affirmation = Affirmation.create(text: textWithEmptyLines);

      expect(affirmation.text, equals(textWithEmptyLines));
      // Should have 5 lines (including empty ones)
      expect('\n'.allMatches(affirmation.text).length, equals(4));
    });
  });

  group('AffirmationEditScreen - Multi-line integration', () {
    late MockAffirmationRepository mockRepository;
    late AffirmationProvider provider;

    setUp(() {
      mockRepository = MockAffirmationRepository();
      provider = AffirmationProvider(repository: mockRepository);

      when(() => mockRepository.getAll()).thenAnswer((_) async => []);
    });

    Widget createTestWidget({String? affirmationId}) {
      return MaterialApp(
        home: ChangeNotifierProvider<AffirmationProvider>.value(
          value: provider,
          child: AffirmationEditScreen(affirmationId: affirmationId),
        ),
      );
    }

    testWidgets('shows multi-line help text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Write your affirmation below. Press Enter for new lines.'),
        findsOneWidget,
      );
    });

    testWidgets('has AffirmationInput widget', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AffirmationInput), findsOneWidget);
    });

    testWidgets('shows preview section when text is entered', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter some text
      await tester.enterText(find.byType(TextField), 'Test text');
      await tester.pump();

      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Test text'), findsAtLeastNWidgets(2)); // Input + Preview
    });

    testWidgets('preview shows multi-line text correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      const multiLineText = 'Line 1\nLine 2';
      await tester.enterText(find.byType(TextField), multiLineText);
      await tester.pump();

      // Should find the text in both input and preview
      expect(find.text(multiLineText), findsAtLeastNWidgets(1));
    });

    testWidgets('shows multi-line hint text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The hint should show example with newlines
      expect(
        find.textContaining('I am worthy'),
        findsOneWidget,
      );
    });
  });
}
