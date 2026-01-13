/// Widget tests for HomeScreen.
///
/// Tests the home screen functionality including:
/// - Initial loading and rendering
/// - Empty state display
/// - Affirmation display
/// - Navigation interactions
/// - Tap and swipe gestures
/// - Error state handling
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/features/affirmations/presentation/screens/home_screen.dart';
import 'package:myself_2_0/features/affirmations/presentation/screens/affirmation_list_screen.dart';
import 'package:myself_2_0/features/affirmations/presentation/widgets/empty_affirmations_state.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart';
import 'package:myself_2_0/features/settings/data/settings_repository.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';
import 'package:myself_2_0/features/settings/presentation/screens/settings_screen.dart';
import 'package:myself_2_0/generated/l10n/app_localizations.dart';

// Mocks
class MockAffirmationRepository extends Mock implements AffirmationRepository {}
class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockAffirmationRepository mockAffirmationRepository;
  late MockSettingsRepository mockSettingsRepository;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(Settings.defaultSettings);
  });

  setUp(() {
    mockAffirmationRepository = MockAffirmationRepository();
    mockSettingsRepository = MockSettingsRepository();

    // Default settings repository behavior
    when(() => mockSettingsRepository.getSettings())
        .thenAnswer((_) async => Settings.defaultSettings);
    when(() => mockSettingsRepository.saveSettings(any()))
        .thenAnswer((_) async {});
  });

  Widget createTestWidget(
    AffirmationProvider affirmationProvider,
    SettingsProvider settingsProvider,
  ) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AffirmationProvider>.value(
            value: affirmationProvider,
          ),
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen - Initial Rendering', () {
    testWidgets('displays app title in app bar', (tester) async {
      // Arrange
      when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async => []);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();

      // Assert
      expect(find.text('Myself 2.0'), findsOneWidget);
    });

    testWidgets('displays list and settings buttons in app bar', (tester) async {
      // Arrange
      when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async => []);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();

      // Assert - find both icons in app bar
      expect(find.byIcon(Icons.list_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });

    testWidgets('shows loading indicator while fetching affirmations', (tester) async {
      // Arrange - simulate slow loading
      when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return [];
      });

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      // Pump once to trigger initState and postFrameCallback
      await tester.pump();

      // Assert - should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('HomeScreen - Empty State', () {
    testWidgets('shows empty state when no affirmations exist', (tester) async {
      // Arrange
      when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async => []);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(EmptyAffirmationsState), findsOneWidget);
    });
  });

  group('HomeScreen - Affirmation Display', () {
    testWidgets('displays affirmation when one exists', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'I am confident and capable',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockAffirmationRepository.getAll())
          .thenAnswer((_) async => affirmations);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(EmptyAffirmationsState), findsNothing);
      expect(find.text('I am confident and capable'), findsOneWidget);
    });

    testWidgets('displays refresh button with affirmation', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'I am confident and capable',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockAffirmationRepository.getAll())
          .thenAnswer((_) async => affirmations);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - find refresh icon button
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('affirmation is displayed in a card', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'I am confident and capable',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockAffirmationRepository.getAll())
          .thenAnswer((_) async => affirmations);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - affirmation should be inside a Card widget
      final cardFinder = find.ancestor(
        of: find.text('I am confident and capable'),
        matching: find.byType(Card),
      );
      expect(cardFinder, findsOneWidget);
    });
  });

  group('HomeScreen - Navigation', () {
    testWidgets('navigates to affirmation list when list button tapped', (tester) async {
      // Arrange
      when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async => []);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();

      // Tap the list icon button
      await tester.tap(find.byIcon(Icons.list_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - should navigate to affirmation list screen
      expect(find.byType(AffirmationListScreen), findsOneWidget);
    });

    testWidgets('navigates to settings when settings button tapped', (tester) async {
      // Arrange
      when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async => []);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();

      // Tap the settings icon button
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - should navigate to settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('HomeScreen - Refresh Interactions', () {
    testWidgets('refresh button is tappable', (tester) async {
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

      when(() => mockAffirmationRepository.getAll())
          .thenAnswer((_) async => affirmations);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the refresh button
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();

      // Assert - should still show an affirmation
      expect(
        find.text('I am confident and capable').evaluate().isNotEmpty ||
        find.text('I embrace challenges with grace').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('card responds to tap gestures', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'I am confident and capable',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockAffirmationRepository.getAll())
          .thenAnswer((_) async => affirmations);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the GestureDetector wrapping the affirmation display
      final gestureDetector = find.byType(GestureDetector).first;

      // Tap the card area
      await tester.tap(gestureDetector);
      await tester.pump();

      // Assert - should still show the affirmation
      expect(find.text('I am confident and capable'), findsOneWidget);
    });

    testWidgets('card responds to horizontal swipe gestures', (tester) async {
      // Arrange
      final affirmations = [
        Affirmation(
          id: 'test-id-1',
          text: 'I am confident and capable',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockAffirmationRepository.getAll())
          .thenAnswer((_) async => affirmations);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the GestureDetector
      final gestureDetector = find.byType(GestureDetector).first;

      // Perform a horizontal drag (swipe left)
      await tester.drag(gestureDetector, const Offset(-200.0, 0.0));
      await tester.pump();

      // Assert - should still show the affirmation
      expect(find.text('I am confident and capable'), findsOneWidget);
    });
  });

  group('HomeScreen - Error State', () {
    testWidgets('displays error state when loading fails', (tester) async {
      // Arrange
      when(() => mockAffirmationRepository.getAll())
          .thenThrow(Exception('Failed to load affirmations'));

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('retry button reloads affirmations after error', (tester) async {
      // Arrange
      var callCount = 0;
      when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Failed to load affirmations');
        }
        return [
          Affirmation(
            id: 'test-id-1',
            text: 'I am confident and capable',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      });

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify error is shown
      expect(find.text('Something went wrong'), findsOneWidget);

      // Find and tap retry button
      final retryButton = find.byType(ElevatedButton);
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - should now show the affirmation
      expect(find.text('I am confident and capable'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });
  });

  group('HomeScreen - Accessibility', () {
    testWidgets('has semantic labels for app bar buttons', (tester) async {
      // Arrange
      when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async => []);

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();

      // Assert - find tooltips/semantics
      final listButton = find.byIcon(Icons.list_rounded);
      final settingsButton = find.byIcon(Icons.settings_rounded);

      expect(listButton, findsOneWidget);
      expect(settingsButton, findsOneWidget);

      // Verify tooltips are present
      final listIconButton = tester.widget<IconButton>(
        find.ancestor(of: listButton, matching: find.byType(IconButton)),
      );
      final settingsIconButton = tester.widget<IconButton>(
        find.ancestor(of: settingsButton, matching: find.byType(IconButton)),
      );

      expect(listIconButton.tooltip, 'My Affirmations');
      expect(settingsIconButton.tooltip, 'Settings');
    });

    testWidgets('has semantic labels for loading state', (tester) async {
      // Arrange - simulate slow loading
      when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return [];
      });

      final affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
      );
      final settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        affirmationProvider,
        settingsProvider,
      ));
      await tester.pump();

      // Assert - find Semantics widget with 'Loading affirmations' label
      final loadingSemantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Loading affirmations',
      );
      expect(loadingSemantics, findsOneWidget);
    });
  });
}
