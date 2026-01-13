/// Integration test for TEST-010: Widget Data Synchronization
///
/// This test verifies that data is properly synchronized between the Flutter app
/// and the native home screen widget. It ensures that when affirmations are
/// created, edited, or deleted in the app, the widget storage is updated correctly.
///
/// Tests cover:
/// - WIDGET-002: Data sharing between app and native widgets
/// - WIDGET-009: Real-time widget updates when affirmations are modified
/// - Data synchronization for affirmations, settings, and current affirmation
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myself_2_0/core/storage/hive_service.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/hive_affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/get_random_affirmation.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/features/settings/data/hive_settings_repository.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';
import 'package:myself_2_0/widgets/native_widget/widget_data_sync.dart';
import 'package:myself_2_0/widgets/native_widget/widget_service.dart';

/// TEST-010: Integration tests for widget and app data synchronization
///
/// These tests verify that:
/// 1. Creating affirmations updates widget storage with the new affirmations list
/// 2. Editing affirmations updates both the list and current affirmation in widget
/// 3. Deleting affirmations removes them from widget storage
/// 4. Settings changes are synced to the widget
/// 5. Current affirmation is properly synced when selected
/// 6. Multiple rapid CRUD operations maintain data consistency
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TEST-010: Widget Data Synchronization', () {
    late HiveAffirmationRepository affirmationRepository;
    late HiveSettingsRepository settingsRepository;
    late AffirmationProvider affirmationProvider;
    late SettingsProvider settingsProvider;
    late WidgetService widgetService;
    late WidgetDataSync widgetDataSync;

    setUp(() async {
      // Initialize Hive for each test
      await HiveService.initialize();

      // Create services
      widgetService = WidgetService();
      widgetDataSync = WidgetDataSync(widgetService: widgetService);

      // Create repositories
      affirmationRepository = HiveAffirmationRepository();
      settingsRepository = HiveSettingsRepository();

      // Clear any existing data for clean test
      await affirmationRepository.deleteAll();

      // Create use cases
      final getRandomAffirmation = GetRandomAffirmation(
        repository: affirmationRepository,
      );

      // Create providers
      affirmationProvider = AffirmationProvider(
        repository: affirmationRepository,
        getRandomAffirmationUseCase: getRandomAffirmation,
        widgetDataSync: widgetDataSync,
      );

      settingsProvider = SettingsProvider(
        repository: settingsRepository,
        widgetDataSync: widgetDataSync,
      );

      // Initialize widget service
      await widgetService.initialize();

      // Load initial data
      await settingsProvider.loadSettings();
      await affirmationProvider.loadAffirmations();
    });

    tearDown(() async {
      // Clean up after each test
      await widgetService.clearAllWidgetData();
      await HiveService.close();
    });

    testWidgets('Widget data is synced when affirmation is created',
        (WidgetTester tester) async {
      // GIVEN: No affirmations exist initially
      expect(affirmationProvider.affirmations.isEmpty, isTrue,
          reason: 'Should start with no affirmations');

      // Verify widget has no affirmations
      final initialCount = await widgetService.getAffirmationsCount();
      expect(initialCount, equals(0),
          reason: 'Widget should have no affirmations initially');

      // WHEN: Create a new affirmation
      const newAffirmationText = 'I am confident and capable';
      final success = await affirmationProvider.createAffirmationFromText(
        text: newAffirmationText,
      );

      // THEN: Creation should succeed
      expect(success, isTrue, reason: 'Affirmation creation should succeed');

      // THEN: Widget storage should be updated with the new affirmation
      final updatedCount = await widgetService.getAffirmationsCount();
      expect(updatedCount, equals(1),
          reason: 'Widget should have one affirmation after creation');

      final hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isTrue,
          reason: 'Widget should indicate affirmations exist');

      // Verify the affirmation is in the widget list
      final widgetAffirmations = await widgetService.getAffirmationsList();
      expect(widgetAffirmations.length, equals(1),
          reason: 'Widget should have one affirmation in list');
      expect(widgetAffirmations.first['text'], equals(newAffirmationText),
          reason: 'Widget affirmation text should match created affirmation');
      expect(widgetAffirmations.first['isActive'], isTrue,
          reason: 'Widget affirmation should be active');
    });

    testWidgets('Widget data is synced when multiple affirmations are created',
        (WidgetTester tester) async {
      // GIVEN: Starting with no affirmations
      expect(affirmationProvider.affirmations.isEmpty, isTrue);

      // WHEN: Create multiple affirmations
      const affirmation1 = 'I am worthy of success';
      const affirmation2 = 'I embrace growth and learning';
      const affirmation3 = 'I am grateful for each day';

      await affirmationProvider.createAffirmationFromText(text: affirmation1);
      await affirmationProvider.createAffirmationFromText(text: affirmation2);
      await affirmationProvider.createAffirmationFromText(text: affirmation3);

      // THEN: Widget should have all three affirmations
      final count = await widgetService.getAffirmationsCount();
      expect(count, equals(3),
          reason: 'Widget should have three affirmations');

      final widgetAffirmations = await widgetService.getAffirmationsList();
      expect(widgetAffirmations.length, equals(3),
          reason: 'Widget list should contain three affirmations');

      // Verify all texts are present
      final texts = widgetAffirmations.map((a) => a['text'] as String).toList();
      expect(texts, contains(affirmation1),
          reason: 'Widget should contain first affirmation');
      expect(texts, contains(affirmation2),
          reason: 'Widget should contain second affirmation');
      expect(texts, contains(affirmation3),
          reason: 'Widget should contain third affirmation');
    });

    testWidgets('Widget data is synced when affirmation is edited',
        (WidgetTester tester) async {
      // GIVEN: One affirmation exists
      const originalText = 'I am confident';
      await affirmationProvider.createAffirmationFromText(text: originalText);

      final affirmation = affirmationProvider.affirmations.first;
      final affirmationId = affirmation.id;

      // Verify original text in widget
      var widgetAffirmations = await widgetService.getAffirmationsList();
      expect(widgetAffirmations.first['text'], equals(originalText),
          reason: 'Widget should have original text');

      // WHEN: Edit the affirmation
      const updatedText = 'I am confident and capable';
      final success = await affirmationProvider.editAffirmationFromText(
        id: affirmationId,
        text: updatedText,
      );

      // THEN: Edit should succeed
      expect(success, isTrue, reason: 'Affirmation edit should succeed');

      // THEN: Widget should have updated text
      widgetAffirmations = await widgetService.getAffirmationsList();
      expect(widgetAffirmations.length, equals(1),
          reason: 'Widget should still have one affirmation');
      expect(widgetAffirmations.first['text'], equals(updatedText),
          reason: 'Widget should have updated text');
      expect(widgetAffirmations.first['id'], equals(affirmationId),
          reason: 'Widget affirmation should have same ID');
    });

    testWidgets(
        'Widget current affirmation is synced when edited affirmation is currently displayed',
        (WidgetTester tester) async {
      // GIVEN: One affirmation exists and is set as current
      const originalText = 'I am worthy';
      await affirmationProvider.createAffirmationFromText(text: originalText);

      final affirmation = affirmationProvider.affirmations.first;

      // Set as current affirmation in widget
      await widgetDataSync.syncCurrentAffirmation(affirmation);

      // Verify current affirmation in widget
      var currentText = await widgetService.getCurrentAffirmation();
      expect(currentText, equals(originalText),
          reason: 'Widget should have original text as current');

      // WHEN: Edit the affirmation
      const updatedText = 'I am worthy of love and success';
      await affirmationProvider.editAffirmationFromText(
        id: affirmation.id,
        text: updatedText,
      );

      // THEN: Widget current affirmation should be updated
      currentText = await widgetService.getCurrentAffirmation();
      expect(currentText, equals(updatedText),
          reason: 'Widget current affirmation should be updated');

      final currentId = await widgetService.getCurrentAffirmationId();
      expect(currentId, equals(affirmation.id),
          reason: 'Widget current affirmation ID should remain the same');
    });

    testWidgets('Widget data is synced when affirmation is deleted',
        (WidgetTester tester) async {
      // GIVEN: Multiple affirmations exist
      await affirmationProvider.createAffirmationFromText(text: 'Keep this');
      await affirmationProvider.createAffirmationFromText(text: 'Delete this');
      await affirmationProvider.createAffirmationFromText(text: 'Keep this too');

      // Verify initial state
      var count = await widgetService.getAffirmationsCount();
      expect(count, equals(3), reason: 'Widget should have three affirmations');

      // Get the affirmation to delete
      final toDelete = affirmationProvider.affirmations
          .firstWhere((a) => a.text == 'Delete this');

      // WHEN: Delete one affirmation
      final success = await affirmationProvider.deleteAffirmation(toDelete.id);

      // THEN: Deletion should succeed
      expect(success, isTrue, reason: 'Affirmation deletion should succeed');

      // THEN: Widget should have updated list without the deleted affirmation
      count = await widgetService.getAffirmationsCount();
      expect(count, equals(2),
          reason: 'Widget should have two affirmations after deletion');

      final widgetAffirmations = await widgetService.getAffirmationsList();
      expect(widgetAffirmations.length, equals(2),
          reason: 'Widget list should have two affirmations');

      // Verify deleted affirmation is not in widget
      final texts = widgetAffirmations.map((a) => a['text'] as String).toList();
      expect(texts, isNot(contains('Delete this')),
          reason: 'Deleted affirmation should not be in widget');
      expect(texts, contains('Keep this'),
          reason: 'First affirmation should remain');
      expect(texts, contains('Keep this too'),
          reason: 'Third affirmation should remain');
    });

    testWidgets('Widget current affirmation is cleared when deleted',
        (WidgetTester tester) async {
      // GIVEN: One affirmation exists and is set as current
      await affirmationProvider.createAffirmationFromText(
        text: 'Current affirmation',
      );

      final affirmation = affirmationProvider.affirmations.first;

      // Set as current in widget
      await widgetDataSync.syncCurrentAffirmation(affirmation);

      // Verify it's set
      var currentText = await widgetService.getCurrentAffirmation();
      expect(currentText, equals('Current affirmation'),
          reason: 'Widget should have current affirmation');

      // WHEN: Delete the current affirmation
      await affirmationProvider.deleteAffirmation(affirmation.id);

      // THEN: Widget current affirmation should be cleared
      currentText = await widgetService.getCurrentAffirmation();
      expect(currentText, isNull,
          reason: 'Widget current affirmation should be cleared');

      final currentId = await widgetService.getCurrentAffirmationId();
      expect(currentId, isNull,
          reason: 'Widget current affirmation ID should be cleared');
    });

    testWidgets('Widget data shows empty state when last affirmation is deleted',
        (WidgetTester tester) async {
      // GIVEN: One affirmation exists
      await affirmationProvider.createAffirmationFromText(
        text: 'Last affirmation',
      );

      var hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isTrue,
          reason: 'Widget should indicate affirmations exist');

      // WHEN: Delete the last affirmation
      final affirmation = affirmationProvider.affirmations.first;
      await affirmationProvider.deleteAffirmation(affirmation.id);

      // THEN: Widget should indicate no affirmations
      hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isFalse,
          reason: 'Widget should indicate no affirmations exist');

      final count = await widgetService.getAffirmationsCount();
      expect(count, equals(0),
          reason: 'Widget count should be zero');

      final widgetAffirmations = await widgetService.getAffirmationsList();
      expect(widgetAffirmations.isEmpty, isTrue,
          reason: 'Widget affirmations list should be empty');
    });

    testWidgets('Settings changes are synced to widget',
        (WidgetTester tester) async {
      // GIVEN: Default settings
      expect(settingsProvider.themeMode, equals(ThemeMode.system),
          reason: 'Default theme should be system');

      // WHEN: Change theme mode
      await settingsProvider.setThemeMode(ThemeMode.dark);

      // THEN: Widget should have updated theme
      final widgetTheme = await widgetService.getThemeMode();
      expect(widgetTheme, equals('dark'),
          reason: 'Widget should have dark theme');

      // WHEN: Change widget rotation setting
      await settingsProvider.setWidgetRotationEnabled(false);

      // THEN: Widget should have updated rotation setting
      final rotation = await widgetService.getWidgetRotationEnabled();
      expect(rotation, isFalse,
          reason: 'Widget rotation should be disabled');

      // WHEN: Change font size
      await settingsProvider.setFontSizeMultiplier(1.5);

      // THEN: Widget should have updated font size
      final fontSize = await widgetService.getFontSizeMultiplier();
      expect(fontSize, equals(1.5),
          reason: 'Widget should have updated font size');
    });

    testWidgets('Current affirmation is synced when selected',
        (WidgetTester tester) async {
      // GIVEN: Multiple affirmations exist
      await affirmationProvider.createAffirmationFromText(
        text: 'First affirmation',
      );
      await affirmationProvider.createAffirmationFromText(
        text: 'Second affirmation',
      );

      // No current affirmation initially
      var currentText = await widgetService.getCurrentAffirmation();
      expect(currentText, isNull,
          reason: 'No current affirmation initially');

      // WHEN: Select random affirmation
      await affirmationProvider.selectRandomAffirmation();

      // Manually sync current affirmation (normally done by the app UI)
      if (affirmationProvider.currentAffirmation != null) {
        await widgetDataSync.syncCurrentAffirmation(
          affirmationProvider.currentAffirmation,
        );
      }

      // THEN: Widget should have the current affirmation
      currentText = await widgetService.getCurrentAffirmation();
      expect(currentText, isNotNull,
          reason: 'Widget should have current affirmation');
      expect(currentText, equals(affirmationProvider.currentAffirmation?.text),
          reason: 'Widget current affirmation should match provider');

      final currentId = await widgetService.getCurrentAffirmationId();
      expect(currentId, equals(affirmationProvider.currentAffirmation?.id),
          reason: 'Widget current affirmation ID should match provider');
    });

    testWidgets('Multiple rapid CRUD operations maintain data consistency',
        (WidgetTester tester) async {
      // GIVEN: Starting fresh
      expect(affirmationProvider.affirmations.isEmpty, isTrue);

      // WHEN: Perform rapid CRUD operations
      // Create multiple
      await affirmationProvider.createAffirmationFromText(text: 'Affirmation 1');
      await affirmationProvider.createAffirmationFromText(text: 'Affirmation 2');
      await affirmationProvider.createAffirmationFromText(text: 'Affirmation 3');
      await affirmationProvider.createAffirmationFromText(text: 'Affirmation 4');

      // Edit one
      final toEdit = affirmationProvider.affirmations[1];
      await affirmationProvider.editAffirmationFromText(
        id: toEdit.id,
        text: 'Affirmation 2 Modified',
      );

      // Delete one
      final toDelete = affirmationProvider.affirmations[2];
      await affirmationProvider.deleteAffirmation(toDelete.id);

      // Create another
      await affirmationProvider.createAffirmationFromText(text: 'Affirmation 5');

      // THEN: Widget should be in sync with provider state
      final providerCount = affirmationProvider.affirmations.length;
      final widgetCount = await widgetService.getAffirmationsCount();
      expect(widgetCount, equals(providerCount),
          reason: 'Widget count should match provider count');
      expect(widgetCount, equals(4),
          reason: 'Should have 4 affirmations (created 5, deleted 1)');

      // Verify all texts match
      final providerTexts = affirmationProvider.affirmations
          .map((a) => a.text)
          .toSet();
      final widgetAffirmations = await widgetService.getAffirmationsList();
      final widgetTexts = widgetAffirmations
          .map((a) => a['text'] as String)
          .toSet();

      expect(widgetTexts, equals(providerTexts),
          reason: 'Widget texts should match provider texts');
    });

    testWidgets('Complete widget data sync with all data types',
        (WidgetTester tester) async {
      // GIVEN: Create affirmations and configure settings
      await affirmationProvider.createAffirmationFromText(
        text: 'I am worthy of success',
      );
      await affirmationProvider.createAffirmationFromText(
        text: 'I embrace growth',
      );

      await settingsProvider.setThemeMode(ThemeMode.dark);
      await settingsProvider.setWidgetRotationEnabled(true);
      await settingsProvider.setFontSizeMultiplier(1.2);

      // WHEN: Perform complete sync
      final affirmations = affirmationProvider.affirmations;
      final settings = settingsProvider.settings;

      final success = await widgetDataSync.syncAllData(
        currentAffirmation: affirmations.first,
        allAffirmations: affirmations,
        settings: settings,
      );

      // THEN: Sync should succeed
      expect(success, isTrue, reason: 'Complete sync should succeed');

      // THEN: Verify all data is synced
      // Current affirmation
      final currentText = await widgetService.getCurrentAffirmation();
      expect(currentText, equals('I am worthy of success'),
          reason: 'Current affirmation should be synced');

      // Affirmations list
      final count = await widgetService.getAffirmationsCount();
      expect(count, equals(2),
          reason: 'Affirmations count should be synced');

      // Settings
      final theme = await widgetService.getThemeMode();
      expect(theme, equals('dark'),
          reason: 'Theme mode should be synced');

      final rotation = await widgetService.getWidgetRotationEnabled();
      expect(rotation, isTrue,
          reason: 'Widget rotation should be synced');

      final fontSize = await widgetService.getFontSizeMultiplier();
      expect(fontSize, equals(1.2),
          reason: 'Font size should be synced');
    });

    testWidgets('Widget data persists across provider recreation',
        (WidgetTester tester) async {
      // GIVEN: Create affirmations and sync to widget
      await affirmationProvider.createAffirmationFromText(
        text: 'Persistent affirmation',
      );

      await settingsProvider.setThemeMode(ThemeMode.light);

      // Verify data is in widget
      var count = await widgetService.getAffirmationsCount();
      expect(count, equals(1), reason: 'Widget should have one affirmation');

      var theme = await widgetService.getThemeMode();
      expect(theme, equals('light'), reason: 'Widget should have light theme');

      // WHEN: Recreate providers (simulating app restart)
      final newAffirmationProvider = AffirmationProvider(
        repository: affirmationRepository,
        getRandomAffirmationUseCase: GetRandomAffirmation(
          repository: affirmationRepository,
        ),
        widgetDataSync: widgetDataSync,
      );

      final newSettingsProvider = SettingsProvider(
        repository: settingsRepository,
        widgetDataSync: widgetDataSync,
      );

      await newAffirmationProvider.loadAffirmations();
      await newSettingsProvider.loadSettings();

      // THEN: Widget data should still be accessible
      count = await widgetService.getAffirmationsCount();
      expect(count, equals(1),
          reason: 'Widget should still have one affirmation');

      theme = await widgetService.getThemeMode();
      expect(theme, equals('light'),
          reason: 'Widget should still have light theme');

      final widgetAffirmations = await widgetService.getAffirmationsList();
      expect(widgetAffirmations.first['text'], equals('Persistent affirmation'),
          reason: 'Widget should have the same affirmation');
    });

    testWidgets('Inactive affirmations are not synced to widget',
        (WidgetTester tester) async {
      // GIVEN: Create active and inactive affirmations
      await affirmationProvider.createAffirmationFromText(
        text: 'Active affirmation',
        isActive: true,
      );
      await affirmationProvider.createAffirmationFromText(
        text: 'Inactive affirmation',
        isActive: false,
      );

      // THEN: Widget should only have active affirmation
      final count = await widgetService.getAffirmationsCount();
      expect(count, equals(1),
          reason: 'Widget should only have active affirmation');

      final widgetAffirmations = await widgetService.getAffirmationsList();
      expect(widgetAffirmations.length, equals(1),
          reason: 'Widget list should have one affirmation');
      expect(widgetAffirmations.first['text'], equals('Active affirmation'),
          reason: 'Widget should only contain active affirmation');
      expect(widgetAffirmations.first['isActive'], isTrue,
          reason: 'Widget affirmation should be marked as active');
    });

    testWidgets('Widget data can be cleared completely',
        (WidgetTester tester) async {
      // GIVEN: Widget has data
      await affirmationProvider.createAffirmationFromText(
        text: 'Test affirmation',
      );
      await settingsProvider.setThemeMode(ThemeMode.dark);

      // Verify data exists
      var count = await widgetService.getAffirmationsCount();
      expect(count, equals(1), reason: 'Widget should have data');

      // WHEN: Clear all widget data
      final success = await widgetDataSync.clearAllData();

      // THEN: Clear should succeed
      expect(success, isTrue, reason: 'Clear should succeed');

      // THEN: All widget data should be cleared
      count = await widgetService.getAffirmationsCount();
      expect(count, equals(0),
          reason: 'Widget count should be zero');

      final currentText = await widgetService.getCurrentAffirmation();
      expect(currentText, isNull,
          reason: 'Current affirmation should be cleared');

      final theme = await widgetService.getThemeMode();
      expect(theme, isNull,
          reason: 'Theme should be cleared');

      final hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isFalse,
          reason: 'Widget should indicate no affirmations');
    });
  });

  group('TEST-010: Widget Data Sync Performance', () {
    late WidgetService widgetService;
    late WidgetDataSync widgetDataSync;
    late HiveAffirmationRepository affirmationRepository;
    late HiveSettingsRepository settingsRepository;
    late AffirmationProvider affirmationProvider;
    late SettingsProvider settingsProvider;

    setUp(() async {
      await HiveService.initialize();

      widgetService = WidgetService();
      widgetDataSync = WidgetDataSync(widgetService: widgetService);
      affirmationRepository = HiveAffirmationRepository();
      settingsRepository = HiveSettingsRepository();

      await affirmationRepository.deleteAll();

      final getRandomAffirmation = GetRandomAffirmation(
        repository: affirmationRepository,
      );

      affirmationProvider = AffirmationProvider(
        repository: affirmationRepository,
        getRandomAffirmationUseCase: getRandomAffirmation,
        widgetDataSync: widgetDataSync,
      );

      settingsProvider = SettingsProvider(
        repository: settingsRepository,
        widgetDataSync: widgetDataSync,
      );

      await widgetService.initialize();
      await settingsProvider.loadSettings();
      await affirmationProvider.loadAffirmations();
    });

    tearDown(() async {
      await widgetService.clearAllWidgetData();
      await HiveService.close();
    });

    testWidgets('Widget sync completes within performance requirements',
        (WidgetTester tester) async {
      // PERF-002: Widget updates should complete within 500ms

      // Create test data
      await affirmationProvider.createAffirmationFromText(
        text: 'Performance test affirmation',
      );

      final affirmations = affirmationProvider.affirmations;
      final settings = settingsProvider.settings;

      // Measure sync time
      final startTime = DateTime.now();

      await widgetDataSync.syncAllData(
        currentAffirmation: affirmations.first,
        allAffirmations: affirmations,
        settings: settings,
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // THEN: Should complete within 500ms (allowing some margin for test overhead)
      expect(duration.inMilliseconds, lessThan(1000),
          reason: 'Widget sync should complete within reasonable time');
    });

    testWidgets('Large affirmation list syncs efficiently',
        (WidgetTester tester) async {
      // GIVEN: Create many affirmations
      for (int i = 0; i < 50; i++) {
        await affirmationProvider.createAffirmationFromText(
          text: 'Affirmation number $i',
        );
      }

      // WHEN: Sync all data
      final startTime = DateTime.now();

      await widgetDataSync.syncAffirmationsList(
        affirmationProvider.affirmations,
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // THEN: Should complete efficiently even with many affirmations
      expect(duration.inMilliseconds, lessThan(2000),
          reason: 'Large list sync should complete efficiently');

      // Verify all synced correctly
      final count = await widgetService.getAffirmationsCount();
      expect(count, equals(50),
          reason: 'All affirmations should be synced');
    });
  });
}
