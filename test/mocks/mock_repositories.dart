/// Mock repositories for testing.
library;

import 'package:myself_2_0/features/settings/data/settings_model.dart';
import 'package:myself_2_0/features/settings/data/settings_repository.dart';

/// Mock implementation of SettingsRepository for testing.
class MockSettingsRepository implements SettingsRepository {
  Settings _settings = Settings.defaultSettings;

  @override
  Future<Settings> getSettings() async {
    return _settings;
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    _settings = settings;
  }

  @override
  Future<void> updateThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
  }

  @override
  Future<void> updateRefreshMode(RefreshMode mode) async {
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
  Future<void> updateHasCompletedOnboarding(bool completed) async {
    _settings = _settings.copyWith(hasCompletedOnboarding: completed);
  }

  @override
  Future<void> resetToDefaults() async {
    _settings = Settings.defaultSettings;
  }
}
