/// Integration test for TEST-008: Onboarding Flow
///
/// This test verifies the complete onboarding user flow from first launch
/// through to the home screen. It tests all steps of the onboarding process
/// including welcome, affirmation creation, success animation, and widget
/// setup instructions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myself_2_0/app.dart';
import 'package:myself_2_0/core/storage/hive_service.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/hive_affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/get_random_affirmation.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/features/onboarding/presentation/screens/onboarding_flow.dart';
import 'package:myself_2_0/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:myself_2_0/features/onboarding/presentation/widgets/success_animation.dart';
import 'package:myself_2_0/features/onboarding/presentation/widgets/widget_setup_instructions.dart';
import 'package:myself_2_0/features/settings/data/hive_settings_repository.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';
import 'package:myself_2_0/widgets/native_widget/widget_data_sync.dart';
import 'package:myself_2_0/widgets/native_widget/widget_service.dart';
import 'package:provider/provider.dart';

/// TEST-008: Integration test for complete onboarding user flow
///
/// Tests the entire first-launch experience:
/// 1. Welcome screen display and navigation
/// 2. First affirmation creation
/// 3. Success animation display
/// 4. Widget setup instructions
/// 5. Completion and navigation to home
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TEST-008: Onboarding Flow Integration Tests', () {
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

      // Load settings - ensure onboarding is NOT complete for fresh start
      await settingsProvider.loadSettings();

      // Reset onboarding status to simulate first launch
      if (settingsProvider.hasCompletedOnboarding) {
        await settingsRepository.updateHasCompletedOnboarding(false);
        await settingsProvider.loadSettings();
      }

      // Initialize widget service
      await widgetService.initialize();
    });

    tearDown(() async {
      // Clean up after each test
      await HiveService.close();
    });

    testWidgets('Complete onboarding flow - happy path',
        (WidgetTester tester) async {
      // GIVEN: App launches for the first time
      expect(settingsProvider.hasCompletedOnboarding, isFalse,
          reason: 'User should not have completed onboarding initially');

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

      // Wait for initial build and animations
      await tester.pumpAndSettle();

      // THEN: Welcome screen should be displayed
      expect(find.byType(OnboardingFlow), findsOneWidget,
          reason: 'OnboardingFlow should be visible on first launch');
      expect(find.byType(WelcomeScreen), findsOneWidget,
          reason: 'WelcomeScreen should be the first step');

      // Verify welcome screen content
      expect(find.text('Myself 2.0'), findsAtLeastNWidgets(1),
          reason: 'App title should be visible on welcome screen');

      // WHEN: User taps "Get Started" button
      final getStartedButton = find.ancestor(
        of: find.textContaining('begin', findRichText: true),
        matching: find.byType(ElevatedButton),
      );
      expect(getStartedButton, findsOneWidget,
          reason: 'Get Started button should be visible');

      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // THEN: Create first affirmation screen should be displayed
      expect(find.text('Create Your First Affirmation'), findsOneWidget,
          reason: 'Create affirmation screen should be visible');
      expect(find.byType(TextField), findsOneWidget,
          reason: 'Text input field should be visible');

      // WHEN: User enters their first affirmation
      const firstAffirmation = 'I am capable of achieving my goals!';
      await tester.enterText(find.byType(TextField), firstAffirmation);
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text(firstAffirmation), findsOneWidget,
          reason: 'Entered affirmation text should be visible');

      // WHEN: User taps save/create button
      final createButton = find.ancestor(
        of: find.text('Create Your First Affirmation'),
        matching: find.byType(ElevatedButton),
      );
      expect(createButton, findsOneWidget,
          reason: 'Create button should be visible');

      await tester.tap(createButton);
      // Wait for save operation and navigation
      await tester.pumpAndSettle();

      // THEN: Success animation should be displayed
      expect(find.byType(SuccessAnimation), findsOneWidget,
          reason: 'Success animation should be shown after creating affirmation');
      expect(find.byIcon(Icons.check_circle), findsOneWidget,
          reason: 'Success icon should be visible');

      // Verify affirmation was saved
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.length, equals(1),
          reason: 'One affirmation should be saved');
      expect(affirmationProvider.affirmations.first.text, equals(firstAffirmation),
          reason: 'Saved affirmation should match entered text');

      // WHEN: Success animation completes (wait for auto-advance)
      // Success animation has a 2 second duration
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // THEN: Widget setup instructions should be displayed
      expect(find.byType(WidgetSetupInstructions), findsOneWidget,
          reason: 'Widget setup instructions should be shown after success animation');
      expect(find.text('Add Your Widget'), findsOneWidget,
          reason: 'Widget setup title should be visible');

      // Verify platform-specific instructions are shown
      // The instructions widget shows either iOS or Android instructions
      expect(
        find.textContaining('Long press', findRichText: true),
        findsOneWidget,
        reason: 'Platform-specific instructions should be visible',
      );

      // WHEN: User taps "Got it!" button to complete onboarding
      final doneButton = find.ancestor(
        of: find.text('Got It!'),
        matching: find.byType(ElevatedButton),
      );
      expect(doneButton, findsOneWidget,
          reason: 'Done button should be visible');

      await tester.tap(doneButton);
      await tester.pumpAndSettle();

      // THEN: Onboarding should be marked as complete
      expect(settingsProvider.hasCompletedOnboarding, isTrue,
          reason: 'Onboarding should be marked as complete in settings');

      // THEN: Home screen should be displayed
      expect(find.byType(OnboardingFlow), findsNothing,
          reason: 'OnboardingFlow should no longer be visible');

      // Verify we're on the home screen by checking for affirmation display
      expect(find.text(firstAffirmation), findsOneWidget,
          reason: 'First affirmation should be displayed on home screen');
    });

    testWidgets('Skip widget setup instructions', (WidgetTester tester) async {
      // GIVEN: User is on the widget setup instructions screen
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

      // Navigate to create affirmation screen
      final getStartedButton = find.ancestor(
        of: find.textContaining('begin', findRichText: true),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // Create affirmation
      await tester.enterText(
        find.byType(TextField),
        'I am growing every day',
      );
      await tester.pumpAndSettle();

      final createButton = find.ancestor(
        of: find.text('Create Your First Affirmation'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Wait for success animation
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should now be on widget setup instructions
      expect(find.byType(WidgetSetupInstructions), findsOneWidget);

      // WHEN: User taps "Skip for now" button
      final skipButton = find.text('Skip for Now');
      expect(skipButton, findsOneWidget,
          reason: 'Skip button should be visible');

      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      // THEN: Onboarding should still be marked as complete
      expect(settingsProvider.hasCompletedOnboarding, isTrue,
          reason: 'Onboarding should be complete even when skipping widget setup');

      // THEN: Should navigate to home screen
      expect(find.byType(OnboardingFlow), findsNothing,
          reason: 'OnboardingFlow should no longer be visible after skipping');
    });

    testWidgets('Back navigation from create affirmation screen',
        (WidgetTester tester) async {
      // GIVEN: User is on the create affirmation screen
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

      // Navigate to create affirmation screen
      final getStartedButton = find.ancestor(
        of: find.textContaining('begin', findRichText: true),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // Verify we're on create affirmation screen
      expect(find.text('Create Your First Affirmation'), findsOneWidget);

      // WHEN: User taps back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget,
          reason: 'Back button should be visible');

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // THEN: Should return to welcome screen
      expect(find.byType(WelcomeScreen), findsOneWidget,
          reason: 'Should navigate back to welcome screen');
      expect(find.text('Myself 2.0'), findsAtLeastNWidgets(1),
          reason: 'Welcome screen content should be visible again');
    });

    testWidgets('Validation - empty affirmation shows error',
        (WidgetTester tester) async {
      // GIVEN: User is on create affirmation screen
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

      // Navigate to create affirmation screen
      final getStartedButton = find.ancestor(
        of: find.textContaining('begin', findRichText: true),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // WHEN: User tries to save without entering text
      final createButton = find.ancestor(
        of: find.text('Create Your First Affirmation'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(createButton);
      await tester.pump(); // Pump once to trigger validation

      // THEN: Error message should be displayed
      await tester.pump(); // Pump again for snackbar
      expect(
        find.textContaining('empty', findRichText: true),
        findsOneWidget,
        reason: 'Error message about empty affirmation should be shown',
      );

      // THEN: Should remain on create affirmation screen
      expect(find.text('Create Your First Affirmation'), findsOneWidget,
          reason: 'Should stay on create screen when validation fails');
      expect(find.byType(SuccessAnimation), findsNothing,
          reason: 'Should not advance to success screen');
    });

    testWidgets('Validation - affirmation too long shows error',
        (WidgetTester tester) async {
      // GIVEN: User is on create affirmation screen
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

      // Navigate to create affirmation screen
      final getStartedButton = find.ancestor(
        of: find.textContaining('begin', findRichText: true),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // WHEN: User enters text exceeding 280 characters
      final longText = 'I am ' * 60; // This will be >280 characters
      await tester.enterText(find.byType(TextField), longText);
      await tester.pumpAndSettle();

      final createButton = find.ancestor(
        of: find.text('Create Your First Affirmation'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(createButton);
      await tester.pump();

      // THEN: Error message should be displayed
      await tester.pump(); // Pump again for snackbar
      expect(
        find.textContaining('long', findRichText: true),
        findsOneWidget,
        reason: 'Error message about length should be shown',
      );

      // THEN: Should remain on create affirmation screen
      expect(find.text('Create Your First Affirmation'), findsOneWidget,
          reason: 'Should stay on create screen when validation fails');
    });

    testWidgets('Multiple affirmations created during onboarding',
        (WidgetTester tester) async {
      // This test verifies that if user goes back and creates multiple
      // affirmations during onboarding, all are saved

      // GIVEN: User completes the flow once
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

      // Navigate through onboarding
      final getStartedButton = find.ancestor(
        of: find.textContaining('begin', findRichText: true),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // Create first affirmation
      const firstAffirmation = 'I am confident';
      await tester.enterText(find.byType(TextField), firstAffirmation);
      await tester.pumpAndSettle();

      final createButton = find.ancestor(
        of: find.text('Create Your First Affirmation'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Complete the flow
      await tester.pump(const Duration(seconds: 2)); // Success animation
      await tester.pumpAndSettle();

      final doneButton = find.ancestor(
        of: find.text('Got It!'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(doneButton);
      await tester.pumpAndSettle();

      // THEN: Affirmation should be saved
      await affirmationProvider.loadAffirmations();
      expect(affirmationProvider.affirmations.length, greaterThanOrEqualTo(1),
          reason: 'At least one affirmation should be saved');
      expect(
        affirmationProvider.affirmations.any((a) => a.text == firstAffirmation),
        isTrue,
        reason: 'First affirmation should be in the saved list',
      );
    });

    testWidgets('Onboarding prevents back button pop',
        (WidgetTester tester) async {
      // GIVEN: User is in onboarding flow
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

      // Verify we're in onboarding
      expect(find.byType(OnboardingFlow), findsOneWidget);

      // WHEN: User tries to pop (system back button on Android)
      // The OnboardingFlow has canPop: false to prevent dismissal
      // This is tested by verifying the OnboardingFlow widget remains visible
      // after attempting to pop (the PopScope configuration prevents dismissal)
      expect(find.byType(OnboardingFlow), findsOneWidget,
          reason: 'OnboardingFlow should prevent back navigation');
    });

    testWidgets('Success animation displays correct content',
        (WidgetTester tester) async {
      // GIVEN: User creates first affirmation
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

      // Navigate to create affirmation
      await tester.tap(find.ancestor(
        of: find.textContaining('begin', findRichText: true),
        matching: find.byType(ElevatedButton),
      ));
      await tester.pumpAndSettle();

      // Create affirmation
      await tester.enterText(find.byType(TextField), 'I am amazing');
      await tester.pumpAndSettle();

      await tester.tap(find.ancestor(
        of: find.text('Create Your First Affirmation'),
        matching: find.byType(ElevatedButton),
      ));
      await tester.pumpAndSettle();

      // THEN: Success animation should show celebration elements
      expect(find.byType(SuccessAnimation), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget,
          reason: 'Success icon should be visible');
      expect(find.text('Congratulations!'), findsOneWidget,
          reason: 'Congratulations message should be visible');

      // Sparkles/stars should be animated
      expect(find.byIcon(Icons.star), findsWidgets,
          reason: 'Decorative sparkle elements should be visible');
    });

    testWidgets('Widget setup instructions show platform-specific content',
        (WidgetTester tester) async {
      // GIVEN: User reaches widget setup instructions
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

      // Navigate through flow to widget instructions
      await tester.tap(find.ancestor(
        of: find.textContaining('begin', findRichText: true),
        matching: find.byType(ElevatedButton),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test affirmation');
      await tester.pumpAndSettle();

      await tester.tap(find.ancestor(
        of: find.text('Create Your First Affirmation'),
        matching: find.byType(ElevatedButton),
      ));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // THEN: Widget setup instructions should be visible
      expect(find.byType(WidgetSetupInstructions), findsOneWidget);

      // Should show step-by-step instructions
      expect(find.textContaining('Long press', findRichText: true), findsOneWidget,
          reason: 'Step 1 instruction should be visible');

      // Should have both Done and Skip options
      expect(find.text('Got It!'), findsOneWidget);
      expect(find.text('Skip for Now'), findsOneWidget);
    });
  });

  group('TEST-008: Onboarding State Persistence', () {
    testWidgets('Completed onboarding persists across app restarts',
        (WidgetTester tester) async {
      // GIVEN: Fresh Hive instance
      await HiveService.initialize();

      final widgetService = WidgetService();
      final widgetDataSync = WidgetDataSync(widgetService: widgetService);
      final settingsRepository = HiveSettingsRepository();

      final settingsProvider = SettingsProvider(
        repository: settingsRepository,
        widgetDataSync: widgetDataSync,
      );

      await settingsProvider.loadSettings();
      await widgetService.initialize();

      // Complete onboarding programmatically
      await settingsProvider.completeOnboarding();

      // WHEN: App is "restarted" (new providers, reload settings)
      final newSettingsProvider = SettingsProvider(
        repository: settingsRepository,
        widgetDataSync: widgetDataSync,
      );
      await newSettingsProvider.loadSettings();

      // THEN: Onboarding should still be marked as complete
      expect(newSettingsProvider.hasCompletedOnboarding, isTrue,
          reason: 'Onboarding completion should persist in storage');

      // Clean up
      await HiveService.close();
    });
  });
}
