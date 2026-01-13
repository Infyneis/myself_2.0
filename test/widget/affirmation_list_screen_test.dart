/// Widget tests for AffirmationListScreen.
///
/// Tests the affirmation list screen functionality including:
/// - Scrollable list display
/// - Empty state handling
/// - Edit/delete actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/features/affirmations/presentation/screens/affirmation_list_screen.dart';
import 'package:myself_2_0/features/affirmations/presentation/widgets/empty_affirmations_state.dart';

// Mocks
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

void main() {
  late MockAffirmationRepository mockRepository;

  setUp(() {
    mockRepository = MockAffirmationRepository();
  });

  Widget createTestWidget(AffirmationProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<AffirmationProvider>.value(
        value: provider,
        child: const AffirmationListScreen(),
      ),
    );
  }

  group('AffirmationListScreen', () {
    testWidgets('shows empty state when no affirmations exist', (tester) async {
      // Arrange
      when(() => mockRepository.getAll()).thenAnswer((_) async => []);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EmptyAffirmationsState), findsOneWidget);
      expect(find.text('No Affirmations Yet'), findsOneWidget);
      expect(find.text('Create Your First Affirmation'), findsOneWidget);
    });

    testWidgets('shows list of affirmations when they exist', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'I am confident and capable',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Affirmation(
          id: 'test-id-2',
          text: 'I embrace challenges with grace',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EmptyAffirmationsState), findsNothing);
      expect(find.text('I am confident and capable'), findsOneWidget);
      expect(find.text('I embrace challenges with grace'), findsOneWidget);
    });

    testWidgets('shows FAB when affirmations exist', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'I am confident and capable',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('hides FAB when no affirmations exist', (tester) async {
      // Arrange
      when(() => mockRepository.getAll()).thenAnswer((_) async => []);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert
      // FAB should be a SizedBox.shrink when empty
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsNothing);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      // Arrange - use a completer to control when loading finishes
      when(() => mockRepository.getAll()).thenAnswer((_) async {
        // Simulate slow loading
        await Future<void>.delayed(const Duration(seconds: 1));
        return [];
      });

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      // Pump once to trigger initState and postFrameCallback
      await tester.pump();

      // Assert - should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Now should show empty state
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays edit buttons for each affirmation', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'I am confident and capable',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('app bar shows correct title', (tester) async {
      // Arrange
      when(() => mockRepository.getAll()).thenAnswer((_) async => []);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('My Affirmations'), findsOneWidget);
    });
  });

  group('EmptyAffirmationsState', () {
    testWidgets('displays correct message and button', (tester) async {
      // Arrange
      var buttonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyAffirmationsState(
              onAddAffirmation: () => buttonPressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No Affirmations Yet'), findsOneWidget);
      expect(
        find.textContaining('Start your journey of self-affirmation'),
        findsOneWidget,
      );
      expect(find.text('Create Your First Affirmation'), findsOneWidget);

      // Tap the button
      await tester.tap(find.text('Create Your First Affirmation'));
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('has self improvement icon', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyAffirmationsState(
              onAddAffirmation: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.self_improvement_outlined), findsOneWidget);
    });
  });
}
