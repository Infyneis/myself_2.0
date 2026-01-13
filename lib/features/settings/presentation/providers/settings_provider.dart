/// Settings provider for state management.
///
/// Manages settings state using Provider pattern.
/// Based on REQUIREMENTS.md settings requirements.
library;

import 'package:flutter/foundation.dart';
import '../../data/settings_model.dart';
import '../../data/settings_repository.dart';

/// Provider for managing settings state.
///
/// Note: Full implementation will be completed in INFRA-004.
class SettingsProvider extends ChangeNotifier {
  /// Creates a SettingsProvider instance.
  SettingsProvider({
    required SettingsRepository repository,
  }) : _repository = repository;

  final SettingsRepository _repository;

  Settings _settings = Settings.defaultSettings;
  bool _isLoading = false;
  String? _error;

  /// Current settings.
  Settings get settings => _settings;

  /// Current theme mode.
  ThemeMode get themeMode => _settings.themeMode;

  /// Current refresh mode.
  RefreshMode get refreshMode => _settings.refreshMode;

  /// Current language.
  String get language => _settings.language;

  /// Current font size multiplier.
  double get fontSizeMultiplier => _settings.fontSizeMultiplier;

  /// Whether widget rotation is enabled.
  bool get widgetRotationEnabled => _settings.widgetRotationEnabled;

  /// Whether breathing animation is enabled.
  bool get breathingAnimationEnabled => _settings.breathingAnimationEnabled;

  /// Whether data is currently being loaded.
  bool get isLoading => _isLoading;

  /// Error message if any operation failed.
  String? get error => _error;

  /// Loads settings from storage.
  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      _settings = await _repository.getSettings();
      _error = null;
    } catch (e) {
      _error = 'Failed to load settings: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _repository.updateThemeMode(mode);
      _settings = _settings.copyWith(themeMode: mode);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update theme: $e';
      notifyListeners();
    }
  }

  /// Updates the refresh mode.
  Future<void> setRefreshMode(RefreshMode mode) async {
    try {
      await _repository.updateRefreshMode(mode);
      _settings = _settings.copyWith(refreshMode: mode);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update refresh mode: $e';
      notifyListeners();
    }
  }

  /// Updates the language.
  Future<void> setLanguage(String language) async {
    try {
      await _repository.updateLanguage(language);
      _settings = _settings.copyWith(language: language);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update language: $e';
      notifyListeners();
    }
  }

  /// Updates the font size multiplier.
  Future<void> setFontSizeMultiplier(double multiplier) async {
    try {
      await _repository.updateFontSizeMultiplier(multiplier);
      _settings = _settings.copyWith(fontSizeMultiplier: multiplier);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update font size: $e';
      notifyListeners();
    }
  }

  /// Updates the widget rotation setting.
  Future<void> setWidgetRotationEnabled(bool enabled) async {
    try {
      await _repository.updateWidgetRotationEnabled(enabled);
      _settings = _settings.copyWith(widgetRotationEnabled: enabled);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update widget rotation: $e';
      notifyListeners();
    }
  }

  /// Updates the breathing animation setting.
  Future<void> setBreathingAnimationEnabled(bool enabled) async {
    try {
      await _repository.updateBreathingAnimationEnabled(enabled);
      _settings = _settings.copyWith(breathingAnimationEnabled: enabled);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update breathing animation: $e';
      notifyListeners();
    }
  }

  /// Resets settings to defaults.
  Future<void> resetToDefaults() async {
    try {
      await _repository.resetToDefaults();
      _settings = Settings.defaultSettings;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reset settings: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
