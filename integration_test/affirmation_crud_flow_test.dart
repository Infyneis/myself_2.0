/// Integration test for TEST-009: Affirmation CRUD Flow
///
/// This test verifies the complete user flows for creating, editing, and
/// deleting affirmations through the UI. It tests all user interactions
/// from navigation to data persistence.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myself_2_0/app.dart';
import 'package:myself_2_0/core/storage/hive_service.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/hive_affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/get_random_affirmation.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/features/affirmations/presentation/screens/affirmation_edit_screen.dart';
import 'package:myself_2_0/features/affirmations/presentation/screens/affirmation_list_screen.dart';
import 'package:myself_2_0/features/settings/data/hive_settings_repository.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';
import 'package:myself_2_0/widgets/native_widget/widget_data_sync.dart';
import 'package:myself_2_0/widgets/native_widget/widget_service.dart';
import 'package:provider/provider.dart';

/// TEST-009: Integration test for full create, edit, delete user flows
///
/// Tests the complete CRUD (Create, Read, Update, Delete) flows:
/// 1. Create affirmation flow - from list screen to add new affirmation
/// 2. Edit affirmation flow - from list screen to edit existing affirmation
/// 3. Delete affirmation flow - delete with confirmation dialog
/// 4. Navigation and state persistence
/// 5. Validation and error handling
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TEST-009: Affirmation CRUD Integration Tests', () {
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

      // Load settings and complete onboarding
      await settingsProvider.loadSettings();
      if (!settingsProvider.hasCompletedOnboarding) {
        await settingsProvider.completeOnboarding();
      }

      // Initialize widget service
      await widgetService.initialize();

      // Load affirmations
      await affirmationProvider.loadAffirmations();
    });

    tearDown(() async {
      // Clean up after each test
      await HiveService.close();
    });

    testWidgets('Complete CREATE flow - add new affirmation from list screen',
        (WidgetTester tester) async {
      // GIVEN: App is launched with no affirmations
      expect(affirmationProvider.affirmations.isEmpty, isTrue,
          reason: 'Should start with no affirmations');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to affirmation list screen
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // Verify we're on the list screen (empty state)
      expect(find.byType(AffirmationListScreen), findsOneWidget,
          reason: 'Should be on affirmation list screen');

      // WHEN: User taps "Create Your First Affirmation" button
      final createButton = find.text('Create Your First Affirmation');
      expect(createButton, findsOneWidget,
          reason: 'Empty state should show create button');

      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // THEN: Edit screen should be displayed
      expect(find.byType(AffirmationEditScreen), findsOneWidget,
          reason: 'Should navigate to edit screen');
      expect(find.byType(TextField), findsOneWidget,
          reason: 'Text input should be visible');

      // WHEN: User enters affirmation text
      const newAffirmation = 'I am capable of achieving great things!';
      await tester.enterText(find.byType(TextField), newAffirmation);
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text(newAffirmation), findsOneWidget,
          reason: 'Entered text should be visible');

      // WHEN: User taps save button
      final saveButton = find.text('Save');
      expect(saveButton, findsOneWidget,
          reason: 'Save button should be visible');

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // THEN: Should navigate back to list screen
      expect(find.byType(AffirmationEditScreen), findsNothing,
          reason: 'Edit screen should be dismissed');
      expect(find.byType(AffirmationListScreen), findsOneWidget,
          reason: 'Should be back on list screen');

      // THEN: Affirmation should be displayed in the list
      expect(find.text(newAffirmation), findsOneWidget,
          reason: 'New affirmation should appear in list');

      // THEN: Affirmation should be persisted
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.length, equals(1),
          reason: 'One affirmation should be saved');
      expect(affirmationProvider.affirmations.first.text, equals(newAffirmation),
          reason: 'Saved affirmation should match entered text');
    });

    testWidgets('CREATE flow with FAB - add affirmation using FloatingActionButton',
        (WidgetTester tester) async {
      // GIVEN: App has one existing affirmation
      await affirmationProvider.createAffirmationFromText(text: 'Existing affirmation');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to list screen
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // WHEN: User taps FloatingActionButton
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget,
          reason: 'FAB should be visible when affirmations exist');

      await tester.tap(fab);
      await tester.pumpAndSettle();

      // THEN: Edit screen should open
      expect(find.byType(AffirmationEditScreen), findsOneWidget);

      // Create new affirmation
      const secondAffirmation = 'I embrace growth and learning!';
      await tester.enterText(find.byType(TextField), secondAffirmation);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // THEN: Both affirmations should be in the list
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.length, equals(2),
          reason: 'Two affirmations should exist');
      expect(
        affirmationProvider.affirmations.any((a) => a.text == secondAffirmation),
        isTrue,
        reason: 'New affirmation should be in the list',
      );
    });

    testWidgets('Complete EDIT flow - modify existing affirmation',
        (WidgetTester tester) async {
      // GIVEN: App has one affirmation
      const originalText = 'I am worthy of success';
      await affirmationProvider.createAffirmationFromText(text: originalText);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to list screen
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // Verify original affirmation is displayed
      expect(find.text(originalText), findsOneWidget,
          reason: 'Original affirmation should be visible');

      // WHEN: User taps edit button on the affirmation card
      final editButton = find.byIcon(Icons.edit_outlined);
      expect(editButton, findsOneWidget,
          reason: 'Edit button should be visible on card');

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // THEN: Edit screen should open with existing text
      expect(find.byType(AffirmationEditScreen), findsOneWidget,
          reason: 'Edit screen should be displayed');
      expect(find.text(originalText), findsAtLeastNWidgets(1),
          reason: 'Original text should be in the text field');

      // Verify the screen shows "Edit Affirmation" title
      expect(find.text('Edit Affirmation'), findsOneWidget,
          reason: 'Edit mode title should be shown');

      // WHEN: User modifies the text
      const updatedText = 'I am worthy of success and happiness';

      // Clear the text field and enter new text
      await tester.enterText(find.byType(TextField), updatedText);
      await tester.pumpAndSettle();

      // WHEN: User taps save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // THEN: Should navigate back to list
      expect(find.byType(AffirmationEditScreen), findsNothing,
          reason: 'Edit screen should close');
      expect(find.byType(AffirmationListScreen), findsOneWidget,
          reason: 'Should be on list screen');

      // THEN: Updated text should be displayed
      expect(find.text(updatedText), findsOneWidget,
          reason: 'Updated affirmation should be visible');
      expect(find.text(originalText), findsNothing,
          reason: 'Original text should not be visible');

      // THEN: Changes should be persisted
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.length, equals(1),
          reason: 'Should still have one affirmation');
      expect(affirmationProvider.affirmations.first.text, equals(updatedText),
          reason: 'Persisted affirmation should have updated text');
    });

    testWidgets('EDIT flow - tap card to edit affirmation',
        (WidgetTester tester) async {
      // GIVEN: App has one affirmation
      await affirmationProvider.createAffirmationFromText(text: 'Test affirmation');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to list screen
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // WHEN: User taps on the affirmation card itself (not the edit button)
      final card = find.byType(Card);
      expect(card, findsOneWidget);

      await tester.tap(card);
      await tester.pumpAndSettle();

      // THEN: Edit screen should open
      expect(find.byType(AffirmationEditScreen), findsOneWidget,
          reason: 'Tapping card should open edit screen');
    });

    testWidgets('Complete DELETE flow - delete affirmation with confirmation',
        (WidgetTester tester) async {
      // GIVEN: App has multiple affirmations
      await affirmationProvider.createAffirmationFromText(text: 'First affirmation');
      await affirmationProvider.createAffirmationFromText(text: 'Second affirmation');
      await affirmationProvider.createAffirmationFromText(text: 'Third affirmation');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to list screen
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // Verify all three affirmations are displayed
      expect(find.text('First affirmation'), findsOneWidget);
      expect(find.text('Second affirmation'), findsOneWidget);
      expect(find.text('Third affirmation'), findsOneWidget);

      // WHEN: User taps delete button on the second affirmation
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsNWidgets(3),
          reason: 'Each affirmation should have a delete button');

      // Tap the second delete button (middle affirmation)
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      // THEN: Confirmation dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget,
          reason: 'Confirmation dialog should be shown');
      expect(find.text('Delete Affirmation'), findsOneWidget,
          reason: 'Dialog title should be visible');

      // Verify dialog content
      expect(
        find.textContaining('delete', findRichText: true),
        findsWidgets,
        reason: 'Confirmation message should be shown',
      );

      // Dialog should have Cancel and Delete buttons
      final cancelButton = find.widgetWithText(TextButton, 'Cancel');
      final confirmDeleteButton = find.widgetWithText(TextButton, 'Delete');
      expect(cancelButton, findsOneWidget,
          reason: 'Cancel button should be in dialog');
      expect(confirmDeleteButton, findsOneWidget,
          reason: 'Delete button should be in dialog');

      // WHEN: User confirms deletion
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();

      // THEN: Dialog should close
      expect(find.byType(AlertDialog), findsNothing,
          reason: 'Dialog should be dismissed');

      // THEN: Affirmation should be removed from list
      expect(find.text('First affirmation'), findsOneWidget,
          reason: 'First affirmation should remain');
      expect(find.text('Second affirmation'), findsNothing,
          reason: 'Second affirmation should be deleted');
      expect(find.text('Third affirmation'), findsOneWidget,
          reason: 'Third affirmation should remain');

      // THEN: Deletion should be persisted
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.length, equals(2),
          reason: 'Two affirmations should remain');
      expect(
        affirmationProvider.affirmations.any((a) => a.text == 'Second affirmation'),
        isFalse,
        reason: 'Deleted affirmation should not exist',
      );

      // Success snackbar should appear
      expect(
        find.textContaining('deleted', findRichText: true),
        findsOneWidget,
        reason: 'Success message should be shown',
      );
    });

    testWidgets('DELETE flow - cancel deletion',
        (WidgetTester tester) async {
      // GIVEN: App has one affirmation
      const affirmationText = 'Important affirmation';
      await affirmationProvider.createAffirmationFromText(text: affirmationText);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to list screen
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // WHEN: User taps delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);

      // WHEN: User cancels deletion
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // THEN: Dialog should close
      expect(find.byType(AlertDialog), findsNothing,
          reason: 'Dialog should be dismissed');

      // THEN: Affirmation should still be in the list
      expect(find.text(affirmationText), findsOneWidget,
          reason: 'Affirmation should not be deleted');

      // THEN: Affirmation should still be persisted
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.length, equals(1),
          reason: 'Affirmation should still exist');
    });

    testWidgets('DELETE flow - delete last affirmation shows empty state',
        (WidgetTester tester) async {
      // GIVEN: App has one affirmation
      await affirmationProvider.createAffirmationFromText(text: 'Last affirmation');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to list screen
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // Delete the affirmation
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      // THEN: Empty state should be displayed
      expect(find.text('Create Your First Affirmation'), findsOneWidget,
          reason: 'Empty state should appear after deleting last affirmation');

      // No affirmations should remain
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.isEmpty, isTrue,
          reason: 'No affirmations should exist');
    });

    testWidgets('CREATE validation - empty text shows error',
        (WidgetTester tester) async {
      // GIVEN: User is on create screen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Your First Affirmation'));
      await tester.pumpAndSettle();

      // WHEN: User tries to save without entering text
      await tester.tap(find.text('Save'));
      await tester.pump();

      // THEN: Error message should be displayed
      await tester.pump(); // Pump for snackbar
      expect(
        find.textContaining('empty', findRichText: true),
        findsOneWidget,
        reason: 'Empty validation error should be shown',
      );

      // THEN: No affirmation should be created
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.isEmpty, isTrue,
          reason: 'No affirmation should be created with empty text');
    });

    testWidgets('CREATE validation - text too long shows error',
        (WidgetTester tester) async {
      // GIVEN: User is on create screen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Your First Affirmation'));
      await tester.pumpAndSettle();

      // WHEN: User enters text exceeding 280 characters
      final longText = 'I am ' * 60; // This will be >280 characters
      await tester.enterText(find.byType(TextField), longText);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();

      // THEN: Error message should be displayed
      await tester.pump(); // Pump for snackbar
      expect(
        find.textContaining('long', findRichText: true),
        findsOneWidget,
        reason: 'Length validation error should be shown',
      );

      // THEN: No affirmation should be created
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.isEmpty, isTrue,
          reason: 'No affirmation should be created with too long text');
    });

    testWidgets('EDIT - unsaved changes warning on back button',
        (WidgetTester tester) async {
      // GIVEN: User is editing an affirmation
      await affirmationProvider.createAffirmationFromText(text: 'Original text');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // WHEN: User modifies the text
      await tester.enterText(find.byType(TextField), 'Modified text');
      await tester.pumpAndSettle();

      // WHEN: User taps back button without saving
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // THEN: Unsaved changes dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget,
          reason: 'Unsaved changes dialog should be shown');
      expect(find.text('Unsaved Changes'), findsOneWidget,
          reason: 'Dialog title should be visible');

      // Dialog should have Cancel and Leave buttons
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Leave'), findsOneWidget);

      // WHEN: User chooses to leave
      await tester.tap(find.widgetWithText(TextButton, 'Leave'));
      await tester.pumpAndSettle();

      // THEN: Should navigate back without saving
      expect(find.byType(AffirmationEditScreen), findsNothing,
          reason: 'Edit screen should close');
      expect(find.byType(AffirmationListScreen), findsOneWidget,
          reason: 'Should be on list screen');

      // THEN: Changes should not be persisted
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.first.text, equals('Original text'),
          reason: 'Original text should be preserved');
    });

    testWidgets('EDIT - cancel unsaved changes dialog',
        (WidgetTester tester) async {
      // GIVEN: User is editing an affirmation
      await affirmationProvider.createAffirmationFromText(text: 'Original text');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // Modify text
      await tester.enterText(find.byType(TextField), 'Modified text');
      await tester.pumpAndSettle();

      // Try to go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // WHEN: User cancels the dialog
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // THEN: Dialog should close
      expect(find.byType(AlertDialog), findsNothing,
          reason: 'Dialog should close');

      // THEN: Should remain on edit screen
      expect(find.byType(AffirmationEditScreen), findsOneWidget,
          reason: 'Should stay on edit screen');

      // Text field should still have modified text
      expect(find.text('Modified text'), findsAtLeastNWidgets(1),
          reason: 'Modified text should still be in text field');
    });

    testWidgets('Multi-line affirmation create, edit, and display',
        (WidgetTester tester) async {
      // GIVEN: User creates a multi-line affirmation
      const multiLineText = 'I am worthy of love\nI am capable\nI am enough';

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Your First Affirmation'));
      await tester.pumpAndSettle();

      // WHEN: User enters multi-line text
      await tester.enterText(find.byType(TextField), multiLineText);
      await tester.pumpAndSettle();

      // Verify preview shows multi-line text
      expect(find.text(multiLineText), findsAtLeastNWidgets(1),
          reason: 'Multi-line text should be visible');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // THEN: Multi-line text should display correctly in the list
      expect(find.text(multiLineText), findsOneWidget,
          reason: 'Multi-line affirmation should be in list');

      // THEN: Should be persisted correctly
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.first.text, equals(multiLineText),
          reason: 'Multi-line text should be persisted correctly');
    });

    testWidgets('Complete CRUD cycle - create, edit, then delete',
        (WidgetTester tester) async {
      // This test verifies the complete lifecycle of an affirmation
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // STEP 1: CREATE
      await tester.tap(find.text('Create Your First Affirmation'));
      await tester.pumpAndSettle();

      const originalText = 'I am on a journey of growth';
      await tester.enterText(find.byType(TextField), originalText);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify creation
      expect(find.text(originalText), findsOneWidget);
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.length, equals(1));

      // STEP 2: EDIT
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      const updatedText = 'I am on a journey of continuous growth';
      await tester.enterText(find.byType(TextField), updatedText);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify edit
      expect(find.text(updatedText), findsOneWidget);
      expect(find.text(originalText), findsNothing);
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.first.text, equals(updatedText));

      // STEP 3: DELETE
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      // Verify deletion
      expect(find.text(updatedText), findsNothing);
      expect(find.text('Create Your First Affirmation'), findsOneWidget,
          reason: 'Empty state should appear');
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.isEmpty, isTrue);
    });

    testWidgets('Multiple affirmations - CRUD operations maintain list integrity',
        (WidgetTester tester) async {
      // GIVEN: Multiple affirmations exist
      await affirmationProvider.createAffirmationFromText(text: 'First');
      await affirmationProvider.createAffirmationFromText(text: 'Second');
      await affirmationProvider.createAffirmationFromText(text: 'Third');
      await affirmationProvider.createAffirmationFromText(text: 'Fourth');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // All affirmations should be visible
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      expect(find.text('Fourth'), findsOneWidget);

      // Edit the second one
      await tester.tap(find.byIcon(Icons.edit_outlined).at(1));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Second Modified');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify edit didn't affect others
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second Modified'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      expect(find.text('Fourth'), findsOneWidget);

      // Delete the third one
      await tester.tap(find.byIcon(Icons.delete_outline).at(2));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      // Verify deletion and list integrity
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second Modified'), findsOneWidget);
      expect(find.text('Third'), findsNothing);
      expect(find.text('Fourth'), findsOneWidget);

      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.length, equals(3));
    });

    testWidgets('Refresh indicator reloads affirmations',
        (WidgetTester tester) async {
      // GIVEN: App has affirmations
      await affirmationProvider.createAffirmationFromText(text: 'Test affirmation');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            Provider<WidgetService>.value(value: widgetService),
          ],
          child: const MyselfApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // WHEN: User pulls to refresh
      await tester.drag(find.text('Test affirmation'), const Offset(0, 300));
      await tester.pumpAndSettle();

      // THEN: Affirmations should reload (no error)
      expect(find.text('Test affirmation'), findsOneWidget,
          reason: 'Affirmation should still be visible after refresh');
    });
  });

  group('TEST-009: CRUD Data Persistence', () {
    testWidgets('Created affirmations persist across app restarts',
        (WidgetTester tester) async {
      // GIVEN: Fresh Hive instance
      await HiveService.initialize();

      final widgetService = WidgetService();
      final widgetDataSync = WidgetDataSync(widgetService: widgetService);
      final affirmationRepository = HiveAffirmationRepository();
      final settingsRepository = HiveSettingsRepository();

      await affirmationRepository.deleteAll();

      final getRandomAffirmation = GetRandomAffirmation(
        repository: affirmationRepository,
      );

      final affirmationProvider = AffirmationProvider(
        repository: affirmationRepository,
        getRandomAffirmationUseCase: getRandomAffirmation,
        widgetDataSync: widgetDataSync,
      );

      final settingsProvider = SettingsProvider(
        repository: settingsRepository,
        widgetDataSync: widgetDataSync,
      );

      await settingsProvider.loadSettings();
      await settingsProvider.completeOnboarding();
      await widgetService.initialize();

      // Create affirmations
      const testAffirmation = 'Persistent affirmation';
      await affirmationProvider.createAffirmationFromText(text: testAffirmation);

      // WHEN: App "restarts" (new provider instance)
      final newAffirmationProvider = AffirmationProvider(
        repository: affirmationRepository,
        getRandomAffirmationUseCase: getRandomAffirmation,
        widgetDataSync: widgetDataSync,
      );

      await newAffirmationProvider.loadAffirmations();

      // THEN: Affirmation should still exist
      expect(newAffirmationProvider.affirmations.length, equals(1),
          reason: 'Created affirmation should persist');
      expect(newAffirmationProvider.affirmations.first.text, equals(testAffirmation),
          reason: 'Persisted affirmation should match');

      // Clean up
      await HiveService.close();
    });

    testWidgets('Edited affirmations persist across app restarts',
        (WidgetTester tester) async {
      // GIVEN: Affirmation exists and is edited
      await HiveService.initialize();

      final widgetService = WidgetService();
      final widgetDataSync = WidgetDataSync(widgetService: widgetService);
      final affirmationRepository = HiveAffirmationRepository();
      final settingsRepository = HiveSettingsRepository();

      await affirmationRepository.deleteAll();

      final getRandomAffirmation = GetRandomAffirmation(
        repository: affirmationRepository,
      );

      final affirmationProvider = AffirmationProvider(
        repository: affirmationRepository,
        getRandomAffirmationUseCase: getRandomAffirmation,
        widgetDataSync: widgetDataSync,
      );

      final settingsProvider = SettingsProvider(
        repository: settingsRepository,
        widgetDataSync: widgetDataSync,
      );

      await settingsProvider.loadSettings();
      await widgetService.initialize();

      // Create and edit
      await affirmationProvider.createAffirmationFromText(text: 'Original');
      final affirmationId = affirmationProvider.affirmations.first.id;

      const editedText = 'Edited and persisted';
      final updatedAffirmation = affirmationProvider.affirmations.first
          .copyWith(text: editedText);
      await affirmationProvider.updateAffirmation(updatedAffirmation);

      // WHEN: App "restarts"
      final newAffirmationProvider = AffirmationProvider(
        repository: affirmationRepository,
        getRandomAffirmationUseCase: getRandomAffirmation,
        widgetDataSync: widgetDataSync,
      );

      await newAffirmationProvider.loadAffirmations();

      // THEN: Edited version should persist
      final persistedAffirmation = newAffirmationProvider.affirmations
          .firstWhere((a) => a.id == affirmationId);
      expect(persistedAffirmation.text, equals(editedText),
          reason: 'Edited affirmation should persist');

      // Clean up
      await HiveService.close();
    });

    testWidgets('Deleted affirmations persist deletion across app restarts',
        (WidgetTester tester) async {
      // GIVEN: Multiple affirmations exist, one is deleted
      await HiveService.initialize();

      final widgetService = WidgetService();
      final widgetDataSync = WidgetDataSync(widgetService: widgetService);
      final affirmationRepository = HiveAffirmationRepository();
      final settingsRepository = HiveSettingsRepository();

      await affirmationRepository.deleteAll();

      final getRandomAffirmation = GetRandomAffirmation(
        repository: affirmationRepository,
      );

      final affirmationProvider = AffirmationProvider(
        repository: affirmationRepository,
        getRandomAffirmationUseCase: getRandomAffirmation,
        widgetDataSync: widgetDataSync,
      );

      final settingsProvider = SettingsProvider(
        repository: settingsRepository,
        widgetDataSync: widgetDataSync,
      );

      await settingsProvider.loadSettings();
      await widgetService.initialize();

      // Create multiple affirmations
      await affirmationProvider.createAffirmationFromText(text: 'Keep this one');
      await affirmationProvider.createAffirmationFromText(text: 'Delete this one');

      final toDelete = affirmationProvider.affirmations
          .firstWhere((a) => a.text == 'Delete this one');

      // Delete one
      await affirmationProvider.deleteAffirmation(toDelete.id);

      // WHEN: App "restarts"
      final newAffirmationProvider = AffirmationProvider(
        repository: affirmationRepository,
        getRandomAffirmationUseCase: getRandomAffirmation,
        widgetDataSync: widgetDataSync,
      );

      await newAffirmationProvider.loadAffirmations();

      // THEN: Deletion should persist
      expect(newAffirmationProvider.affirmations.length, equals(1),
          reason: 'Only one affirmation should remain');
      expect(
        newAffirmationProvider.affirmations.any((a) => a.text == 'Delete this one'),
        isFalse,
        reason: 'Deleted affirmation should not exist',
      );
      expect(
        newAffirmationProvider.affirmations.any((a) => a.text == 'Keep this one'),
        isTrue,
        reason: 'Remaining affirmation should exist',
      );

      // Clean up
      await HiveService.close();
    });
  });
}
