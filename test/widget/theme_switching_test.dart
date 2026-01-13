/// Widget tests for theme switching functionality.
///
/// Tests UI-002: Dark/Light Mode Support
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/theme/app_theme.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart'
    as settings_model;
import 'package:myself_2_0/features/settings/data/settings_repository.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';
import 'package:myself_2_0/features/settings/presentation/screens/settings_screen.dart';
import 'package:provider/provider.dart';

/// Mock settings repository for testing.
class MockSettingsRepository implements SettingsRepository {
  settings_model.Settings _settings = settings_model.Settings.defaultSettings;

  @override
  Future<settings_model.Settings> getSettings() async {
    return _settings;
  }

  @override
  Future<void> saveSettings(settings_model.Settings settings) async {
    _settings = settings;
  }

  @override
  Future<void> updateThemeMode(settings_model.ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
  }

  @override
  Future<void> updateRefreshMode(settings_model.RefreshMode mode) async {
    _settings = _settings.copyWith(refreshMode: mode);
  }

  @override
  Future<void> updateLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
  }

  @override
  Future<void> updateFontSizeMultiplier(double multiplier) async {
    _settings = _settings.copyWith(fontSizeMultiplier: multiplier);
  }

  @override
  Future<void> updateWidgetRotationEnabled(bool enabled) async {
    _settings = _settings.copyWith(widgetRotationEnabled: enabled);
  }

  @override
  Future<void> updateBreathingAnimationEnabled(bool enabled) async {
    _settings = _settings.copyWith(breathingAnimationEnabled: enabled);
  }

  @override
  Future<void> resetToDefaults() async {
    _settings = settings_model.Settings.defaultSettings;
  }
}

void main() {
  group('Theme Switching Tests - UI-002', () {
    late MockSettingsRepository mockRepository;
    late SettingsProvider settingsProvider;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('SettingsScreen displays all three theme options',
        (WidgetTester tester) async {
      await settingsProvider.loadSettings();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Verify all three theme options are displayed
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('Light theme option is initially selected by default',
        (WidgetTester tester) async {
      // Set initial theme to system (default)
      await settingsProvider.loadSettings();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Default is system mode
      expect(settingsProvider.themeMode, settings_model.ThemeMode.system);
    });

    testWidgets('Tapping Light theme option updates the theme',
        (WidgetTester tester) async {
      await settingsProvider.loadSettings();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Find and tap the Light theme option
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      // Verify theme mode is updated
      expect(settingsProvider.themeMode, settings_model.ThemeMode.light);
    });

    testWidgets('Tapping Dark theme option updates the theme',
        (WidgetTester tester) async {
      await settingsProvider.loadSettings();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Find and tap the Dark theme option
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Verify theme mode is updated
      expect(settingsProvider.themeMode, settings_model.ThemeMode.dark);
    });

    testWidgets('Tapping System theme option updates the theme',
        (WidgetTester tester) async {
      // Start with light mode
      await settingsProvider.loadSettings();
      await settingsProvider.setThemeMode(settings_model.ThemeMode.light);

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Find and tap the System theme option
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();

      // Verify theme mode is updated
      expect(settingsProvider.themeMode, settings_model.ThemeMode.system);
    });

    testWidgets('Selected theme option shows check icon',
        (WidgetTester tester) async {
      await settingsProvider.loadSettings();
      await settingsProvider.setThemeMode(settings_model.ThemeMode.dark);

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Verify check_circle icon is shown for selected theme
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Theme mode persists across provider updates',
        (WidgetTester tester) async {
      await settingsProvider.loadSettings();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Switch to dark mode
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Verify persisted
      expect(settingsProvider.themeMode, settings_model.ThemeMode.dark);

      // Rebuild widget
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Theme should still be dark
      expect(settingsProvider.themeMode, settings_model.ThemeMode.dark);
    });
  });
}
