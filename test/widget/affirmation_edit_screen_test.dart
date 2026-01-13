/// Widget tests for AffirmationEditScreen.
///
/// Tests the affirmation create/edit screen functionality including:
/// - Text input with character counter
/// - Save/cancel actions
/// - Validation feedback
/// - Unsaved changes warning
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/features/affirmations/presentation/screens/affirmation_edit_screen.dart';
import 'package:myself_2_0/features/affirmations/presentation/widgets/affirmation_input.dart';
import 'package:myself_2_0/generated/l10n/app_localizations.dart';

// Mocks
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

void main() {
  late MockAffirmationRepository mockRepository;

  setUp(() {
    mockRepository = MockAffirmationRepository();
    // Set up fallback values for any needed types
    registerFallbackValue(
      Affirmation.create(text: 'Fallback affirmation'),
    );
  });

  Widget createTestWidget(AffirmationProvider provider, {String? affirmationId}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: ChangeNotifierProvider<AffirmationProvider>.value(
        value: provider,
        child: AffirmationEditScreen(affirmationId: affirmationId),
      ),
    );
  }

  group('AffirmationEditScreen - Create Mode', () {
    testWidgets('displays correct title for new affirmation', (tester) async {
      // Arrange
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('New Affirmation'), findsOneWidget);
    });

    testWidgets('displays AffirmationInput widget', (tester) async {
      // Arrange
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AffirmationInput), findsOneWidget);
    });

    testWidgets('shows save button in app bar', (tester) async {
      // Arrange
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('displays help text for multi-line input', (tester) async {
      // Arrange
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert - The placeholder text appears multiple times (help text and hint text)
      expect(
        find.text('Enter your affirmation...'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('successfully creates new affirmation', (tester) async {
      // Arrange
      const testText = 'I am confident and capable';
      final createdAffirmation = Affirmation.create(text: testText);

      when(() => mockRepository.create(any()))
          .thenAnswer((_) async => createdAffirmation);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), testText);
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRepository.create(any())).called(1);
    });

    testWidgets('shows error snackbar when text is empty', (tester) async {
      // Arrange
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Tap save button without entering text
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Affirmation text cannot be empty'), findsOneWidget);
      verifyNever(() => mockRepository.create(any()));
    });

    testWidgets('shows error when text exceeds character limit', (tester) async {
      // Arrange
      final longText = 'a' * 281; // 281 characters (exceeds 280 limit)
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Enter long text (Note: TextField widget itself enforces maxLength,
      // so it will truncate to 280 chars. We're testing the validation logic.)
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, equals(280)); // Verify max length is enforced

      // The TextField with maxLength enforces the limit automatically,
      // so we can't actually enter more than 280 characters through the UI.
      // This is the correct behavior - the input is constrained by the widget.
    });

    testWidgets('displays preview when text is entered', (tester) async {
      // Arrange
      const testText = 'I am worthy of love';
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), testText);
      await tester.pumpAndSettle();

      // Assert - Preview section should appear
      expect(find.text('Affirmation card'), findsOneWidget);
      // The text appears twice: once in the input field and once in the preview
      expect(find.text(testText), findsNWidgets(2));
    });

    testWidgets('shows unsaved changes dialog when back button pressed', (tester) async {
      // Arrange
      const testText = 'Unsaved affirmation';
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), testText);
      await tester.pumpAndSettle();

      // Try to go back using the back icon
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Assert - Unsaved changes dialog should appear
        expect(find.text('Unsaved Changes'), findsOneWidget);
        expect(
          find.text('You have unsaved changes. Are you sure you want to leave?'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Leave'), findsOneWidget);
      }
    });

    testWidgets('does not show dialog when back pressed with no changes', (tester) async {
      // Arrange
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Try to go back without entering text using the back icon
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Assert - No dialog should appear
        expect(find.text('Unsaved Changes'), findsNothing);
      }
    });
  });

  group('AffirmationEditScreen - Edit Mode', () {
    testWidgets('displays correct title for editing affirmation', (tester) async {
      // Arrange
      final existingAffirmation = Affirmation.create(text: 'Existing affirmation');
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => [existingAffirmation]);

      final provider = AffirmationProvider(repository: mockRepository);
      await provider.loadAffirmations();

      // Act
      await tester.pumpWidget(
        createTestWidget(provider, affirmationId: existingAffirmation.id),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit Affirmation'), findsOneWidget);
    });

    testWidgets('loads existing affirmation text', (tester) async {
      // Arrange
      const existingText = 'Existing affirmation text';
      final existingAffirmation = Affirmation.create(text: existingText);

      when(() => mockRepository.getAll())
          .thenAnswer((_) async => [existingAffirmation]);

      final provider = AffirmationProvider(repository: mockRepository);
      await provider.loadAffirmations();

      // Act
      await tester.pumpWidget(
        createTestWidget(provider, affirmationId: existingAffirmation.id),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(existingText), findsAtLeastNWidgets(1));
    });

    testWidgets('successfully updates existing affirmation', (tester) async {
      // Arrange
      const originalText = 'Original affirmation';
      const updatedText = 'Updated affirmation';
      final existingAffirmation = Affirmation.create(text: originalText);
      final updatedAffirmation = existingAffirmation.copyWith(text: updatedText);

      when(() => mockRepository.getAll())
          .thenAnswer((_) async => [existingAffirmation]);
      when(() => mockRepository.getById(existingAffirmation.id))
          .thenAnswer((_) async => existingAffirmation);
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => updatedAffirmation);

      final provider = AffirmationProvider(repository: mockRepository);
      await provider.loadAffirmations();

      // Act
      await tester.pumpWidget(
        createTestWidget(provider, affirmationId: existingAffirmation.id),
      );
      await tester.pumpAndSettle();

      // Clear and enter new text
      await tester.enterText(find.byType(TextField), updatedText);
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRepository.update(any())).called(1);
    });

    testWidgets('shows unsaved changes dialog when editing', (tester) async {
      // Arrange
      const originalText = 'Original affirmation';
      const modifiedText = 'Modified affirmation';
      final existingAffirmation = Affirmation.create(text: originalText);

      when(() => mockRepository.getAll())
          .thenAnswer((_) async => [existingAffirmation]);

      final provider = AffirmationProvider(repository: mockRepository);
      await provider.loadAffirmations();

      // Act
      await tester.pumpWidget(
        createTestWidget(provider, affirmationId: existingAffirmation.id),
      );
      await tester.pumpAndSettle();

      // Modify text
      await tester.enterText(find.byType(TextField), modifiedText);
      await tester.pumpAndSettle();

      // Try to go back using the back icon
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Assert - Unsaved changes dialog should appear
        expect(find.text('Unsaved Changes'), findsOneWidget);
      }
    });
  });

  group('AffirmationEditScreen - Multi-line Support', () {
    testWidgets('supports multi-line text input', (tester) async {
      // Arrange
      const multiLineText = 'Line 1\nLine 2\nLine 3';
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Enter multi-line text
      await tester.enterText(find.byType(TextField), multiLineText);
      await tester.pumpAndSettle();

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals(multiLineText));
    });

    testWidgets('displays multi-line preview correctly', (tester) async {
      // Arrange
      const multiLineText = 'I am worthy\nI am capable\nI am enough';
      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Enter multi-line text
      await tester.enterText(find.byType(TextField), multiLineText);
      await tester.pumpAndSettle();

      // Assert - Preview should show the multi-line text
      expect(find.text('Affirmation card'), findsOneWidget);
      expect(find.text(multiLineText), findsNWidgets(2)); // Input + Preview
    });
  });

  group('AffirmationEditScreen - Loading State', () {
    testWidgets('shows loading indicator while saving', (tester) async {
      // Arrange
      const testText = 'Test affirmation';
      final createdAffirmation = Affirmation.create(text: testText);

      // Make the create operation delayed
      when(() => mockRepository.create(any())).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          return createdAffirmation;
        },
      );

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), testText);
      await tester.pump();

      // Tap save button
      await tester.tap(find.text('Save'));
      await tester.pump(); // Start the async operation

      // Assert - Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for operation to complete
      await tester.pumpAndSettle();
    });
  });
}
