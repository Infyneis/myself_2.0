/// Tests for language selection with immediate UI update (L10N-004).
///
/// Verifies that:
/// - Language can be changed in settings
/// - UI updates immediately when language changes
/// - Language selection persists across app restarts
/// - All supported languages (French, English) work correctly
library;

import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';
import 'package:myself_2_0/features/settings/presentation/screens/settings_screen.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/generated/l10n/app_localizations.dart';

import '../mocks/mock_repositories.dart';

void main() {
  group('Language Selection (L10N-004)', () {
    late MockSettingsRepository mockSettingsRepository;
    late MockAffirmationRepository mockAffirmationRepository;
    late MockWidgetDataSync mockWidgetDataSync;
    late SettingsProvider settingsProvider;
    late AffirmationProvider affirmationProvider;

    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
      mockAffirmationRepository = MockAffirmationRepository();
      mockWidgetDataSync = MockWidgetDataSync();

      settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
        widgetDataSync: mockWidgetDataSync,
      );

      affirmationProvider = AffirmationProvider(
        repository: mockAffirmationRepository,
        getRandomAffirmationUseCase: null,
        widgetDataSync: mockWidgetDataSync,
      );
    });

    /// Helper to build the test widget with providers.
    /// Must call settingsProvider.loadSettings() before using.
    Widget buildTestWidget({
      required Settings initialSettings,
      Widget? home,
    }) {
      // Set the initial settings
      mockSettingsRepository.settings = initialSettings;
      settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
        widgetDataSync: mockWidgetDataSync,
      );
      // Note: Caller must call settingsProvider.loadSettings() before pumpWidget

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
          ChangeNotifierProvider<AffirmationProvider>.value(
            value: affirmationProvider,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          locale: initialSettings.language != 'system'
              ? Locale(initialSettings.language)
              : null,
          home: home ?? const SettingsScreen(),
        ),
      );
    }

    testWidgets('Language selector shows current language', (tester) async {
      // Arrange: Start with French
      final widget = buildTestWidget(
        initialSettings: const Settings(
          language: 'fr',
          hasCompletedOnboarding: true,
        ),
      );
      await settingsProvider.loadSettings();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert: Both language options should be visible
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Assert: French should be selected (check via provider state)
      expect(settingsProvider.language, equals('fr'));

      // Assert: There should be exactly one check_circle icon (for the selected language)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Can change language from French to English', (tester) async {
      // Arrange: Start with French
      final widget = buildTestWidget(
        initialSettings: const Settings(
          language: 'fr',
          hasCompletedOnboarding: true,
        ),
      );
      await settingsProvider.loadSettings();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Act: Tap on English option
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Assert: English should now be selected
      expect(settingsProvider.language, equals('en'));

      // Assert: Repository should have been called to persist the change
      expect(mockSettingsRepository.updateLanguageCalled, isTrue);
      expect(mockSettingsRepository.settings.language, equals('en'));
    });

    testWidgets('Can change language from English to French', (tester) async {
      // Arrange: Start with English
      final widget = buildTestWidget(
        initialSettings: const Settings(
          language: 'en',
          hasCompletedOnboarding: true,
        ),
      );
      await settingsProvider.loadSettings();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Act: Tap on French option
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();

      // Assert: French should now be selected
      expect(settingsProvider.language, equals('fr'));

      // Assert: Repository should have been called to persist the change
      expect(mockSettingsRepository.updateLanguageCalled, isTrue);
      expect(mockSettingsRepository.settings.language, equals('fr'));
    });

    testWidgets('UI updates immediately when language changes to French',
        (tester) async {
      // Arrange: Start with English
      final widget = buildTestWidget(
        initialSettings: const Settings(
          language: 'en',
          hasCompletedOnboarding: true,
        ),
      );
      await settingsProvider.loadSettings();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert: Verify English text is displayed
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);

      // Act: Change to French
      await tester.tap(find.text('Français'));
      await tester.pump(); // Start the animation
      await tester.pumpAndSettle(); // Wait for all animations to complete

      // Assert: Verify French text is now displayed (immediate update)
      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Langue'), findsOneWidget);
      expect(find.text('Apparence'), findsOneWidget);
    });

    testWidgets('UI updates immediately when language changes to English',
        (tester) async {
      // Arrange: Start with French
      final widget = buildTestWidget(
        initialSettings: const Settings(
          language: 'fr',
          hasCompletedOnboarding: true,
        ),
      );
      await settingsProvider.loadSettings();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert: Verify French text is displayed
      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Langue'), findsOneWidget);
      expect(find.text('Apparence'), findsOneWidget);

      // Act: Change to English
      await tester.tap(find.text('English'));
      await tester.pump(); // Start the animation
      await tester.pumpAndSettle(); // Wait for all animations to complete

      // Assert: Verify English text is now displayed (immediate update)
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('Language persists when navigating away and back',
        (tester) async {
      // Arrange: Build a full app with navigation
      // Load settings first to initialize the provider
      await settingsProvider.loadSettings();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
            ],
            home: Builder(
              builder: (context) {
                final language = context.watch<SettingsProvider>().language;
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Current language: $language'),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        child: const Text('Go to Settings'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Initial language is French (default)
      expect(find.text('Current language: fr'), findsOneWidget);

      // Act: Navigate to settings
      await tester.tap(find.text('Go to Settings'));
      await tester.pumpAndSettle();

      // Act: Change language to English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Act: Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Assert: Language should still be English
      expect(find.text('Current language: en'), findsOneWidget);
    });

    testWidgets('All UI elements update when language changes', (tester) async {
      // Arrange: Start with French
      final widget = buildTestWidget(
        initialSettings: const Settings(
          language: 'fr',
          hasCompletedOnboarding: true,
        ),
      );
      await settingsProvider.loadSettings();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert: Verify multiple French UI elements
      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Apparence'), findsOneWidget);
      expect(find.text('Préférences'), findsOneWidget);
      expect(find.text('Paramètres du widget'), findsOneWidget);
      expect(find.text('Mode de rafraîchissement'), findsOneWidget);
      expect(find.text('Taille de police'), findsOneWidget);

      // Act: Change to English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Assert: Verify all elements updated to English
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Widget Settings'), findsOneWidget);
      expect(find.text('Refresh Mode'), findsOneWidget);
      expect(find.text('Font Size'), findsOneWidget);
    });

    testWidgets('Language change notifies listeners', (tester) async {
      // Arrange
      final widget = buildTestWidget(
        initialSettings: const Settings(
          language: 'fr',
          hasCompletedOnboarding: true,
        ),
      );
      await settingsProvider.loadSettings();

      int notificationCount = 0;
      settingsProvider.addListener(() {
        notificationCount++;
      });

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final initialCount = notificationCount;

      // Act: Change language
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Assert: Provider should have notified listeners
      expect(notificationCount, greaterThan(initialCount));
    });

    testWidgets('Accessibility labels work in both languages', (tester) async {
      // Arrange: Start with French
      final widget = buildTestWidget(
        initialSettings: const Settings(
          language: 'fr',
          hasCompletedOnboarding: true,
        ),
      );
      await settingsProvider.loadSettings();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert: Find French language option with accessibility semantics
      final frenchWidget = find.ancestor(
        of: find.text('Français'),
        matching: find.byType(Semantics),
      );
      expect(frenchWidget, findsWidgets);

      // Act: Change to English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Assert: Find English language option with updated semantics
      final englishWidget = find.ancestor(
        of: find.text('English'),
        matching: find.byType(Semantics),
      );
      expect(englishWidget, findsWidgets);
    });

    testWidgets('Language selection works with different initial settings',
        (tester) async {
      // Test with different theme modes to ensure language works independently
      for (final themeMode in ThemeMode.values) {
        // Reset the repository settings to French for each iteration
        mockSettingsRepository.settings = Settings(
          language: 'fr',
          themeMode: themeMode,
          hasCompletedOnboarding: true,
        );
        mockSettingsRepository.resetCalls();

        // Create a new provider for each iteration
        settingsProvider = SettingsProvider(
          repository: mockSettingsRepository,
          widgetDataSync: mockWidgetDataSync,
        );
        await settingsProvider.loadSettings();

        final widget = MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            ChangeNotifierProvider<AffirmationProvider>.value(
              value: affirmationProvider,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
            ],
            locale: const Locale('fr'),
            home: const SettingsScreen(),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Change to English
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();

        // Verify language changed
        expect(settingsProvider.language, equals('en'));
      }
    });

    testWidgets('Error handling when language change fails', (tester) async {
      // Arrange: Reset repository settings to French and set up failure
      mockSettingsRepository.settings = const Settings(
        language: 'fr',
        hasCompletedOnboarding: true,
      );
      mockSettingsRepository.resetCalls();
      mockSettingsRepository.shouldFailOnLanguageUpdate = true;

      // Create a fresh provider for this test
      settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
        widgetDataSync: mockWidgetDataSync,
      );
      await settingsProvider.loadSettings();

      final widget = MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
          ChangeNotifierProvider<AffirmationProvider>.value(
            value: affirmationProvider,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          locale: const Locale('fr'),
          home: const SettingsScreen(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Act: Try to change language
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Assert: Language should remain French due to error
      expect(settingsProvider.language, equals('fr'));

      // Assert: Error should be set in provider
      expect(settingsProvider.error, isNotNull);
      expect(settingsProvider.error, contains('Failed to update language'));
    });
  });

}
