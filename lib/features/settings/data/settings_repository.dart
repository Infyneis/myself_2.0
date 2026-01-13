/// Settings repository interface.
///
/// Defines the contract for settings persistence.
/// Based on REQUIREMENTS.md FR-022 through FR-026.
library;

import 'settings_model.dart';

/// Repository interface for settings operations.
///
/// This abstract class defines the contract that any settings
/// storage implementation must follow.
abstract class SettingsRepository {
  /// Retrieves the current settings.
  Future<Settings> getSettings();

  /// Saves the settings.
  Future<void> saveSettings(Settings settings);

  /// Updates the theme mode.
  Future<void> updateThemeMode(ThemeMode themeMode);

  /// Updates the refresh mode.
  Future<void> updateRefreshMode(RefreshMode refreshMode);

  /// Updates the language.
  Future<void> updateLanguage(String language);

  /// Updates the font size multiplier.
  Future<void> updateFontSizeMultiplier(double multiplier);

  /// Updates the widget rotation setting.
  Future<void> updateWidgetRotationEnabled(bool enabled);

  /// Updates the breathing animation setting.
  Future<void> updateBreathingAnimationEnabled(bool enabled);

  /// Resets settings to defaults.
  Future<void> resetToDefaults();
}
