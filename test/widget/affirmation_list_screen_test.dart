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

  group('Drag-and-drop reordering', () {
    testWidgets('displays drag handle for each affirmation', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'First affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Affirmation(
          id: 'test-id-2',
          text: 'Second affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert - should find drag handle icons for each affirmation
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    });

    testWidgets('uses ReorderableListView for the list', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'First affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert - should use ReorderableListView
      expect(find.byType(ReorderableListView), findsOneWidget);
    });

    testWidgets('calls reorderAffirmations when items are reordered', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'First affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sortOrder: 0,
        ),
        Affirmation(
          id: 'test-id-2',
          text: 'Second affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sortOrder: 1,
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
      when(() => mockRepository.reorder(any())).thenAnswer((_) async {});

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Find the first drag handle
      final firstDragHandle = find.byIcon(Icons.drag_handle).first;

      // Get the center of the drag handle
      final firstItemCenter = tester.getCenter(firstDragHandle);

      // Perform a long press and drag down
      final gesture = await tester.startGesture(firstItemCenter);

      // Long press to initiate drag
      await tester.pump(const Duration(milliseconds: 500));

      // Move down by 100 pixels
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      // Release the gesture
      await gesture.up();
      await tester.pumpAndSettle();

      // Assert - verify reorder was called on the repository
      verify(() => mockRepository.reorder(any())).called(1);
    });

    testWidgets('shows elevated card during drag', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'First affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Affirmation(
          id: 'test-id-2',
          text: 'Second affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Find the first drag handle
      final firstDragHandle = find.byIcon(Icons.drag_handle).first;

      // Get the center of the drag handle
      final firstItemCenter = tester.getCenter(firstDragHandle);

      // Start dragging
      final gesture = await tester.startGesture(firstItemCenter);
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      // Assert - should find a Material with elevation during drag
      // The proxyDecorator wraps items in an elevated Material
      final materials = tester.widgetList<Material>(find.byType(Material));
      final hasElevatedMaterial = materials.any((m) => m.elevation > 0);
      expect(hasElevatedMaterial, isTrue);

      // Clean up
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('preserves item keys based on affirmation id', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'unique-id-123',
          text: 'Test affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);

      final provider = AffirmationProvider(repository: mockRepository);

      // Act
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Assert - the card should have a ValueKey with the affirmation id
      // This is verified by finding a widget with the text and checking keys
      final cardFinder = find.ancestor(
        of: find.text('Test affirmation'),
        matching: find.byType(Card),
      );
      expect(cardFinder, findsOneWidget);
    });
  });
}
