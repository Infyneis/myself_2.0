/// Hive implementation of settings repository.
///
/// Provides concrete implementation of SettingsRepository using Hive
/// for local storage persistence.
/// Based on REQUIREMENTS.md FR-022 through FR-026.
library;

import 'package:hive/hive.dart';

import '../../../core/storage/hive_service.dart';
import 'settings_model.dart';
import 'settings_repository.dart';

/// Keys for settings storage.
abstract class SettingsKeys {
  /// Key for theme mode setting.
  static const String themeMode = 'themeMode';

  /// Key for refresh mode setting.
  static const String refreshMode = 'refreshMode';

  /// Key for language setting.
  static const String language = 'language';

  /// Key for font size multiplier setting.
  static const String fontSizeMultiplier = 'fontSizeMultiplier';

  /// Key for widget rotation enabled setting.
  static const String widgetRotationEnabled = 'widgetRotationEnabled';

  /// Key for breathing animation enabled setting.
  static const String breathingAnimationEnabled = 'breathingAnimationEnabled';

  /// Key for onboarding completion status.
  static const String hasCompletedOnboarding = 'hasCompletedOnboarding';
}

/// Hive-backed implementation of [SettingsRepository].
///
/// This implementation uses Hive for local storage and provides
/// all settings persistence operations.
class HiveSettingsRepository implements SettingsRepository {
  /// Creates a new HiveSettingsRepository.
  ///
  /// Optionally accepts a [Box] for testing purposes.
  /// If not provided, uses the default box from [HiveService].
  HiveSettingsRepository({Box<dynamic>? box}) : _box = box;

  final Box<dynamic>? _box;

  /// Gets the Hive box, either injected or from HiveService.
  /// Supports lazy box opening for PERF-001 optimization.
  Future<Box<dynamic>> get _settingsBox async =>
      _box ?? await HiveService.settingsBox;

  @override
  Future<Settings> getSettings() async {
    final box = await _settingsBox;
    final themeModeIndex = box.get(
      SettingsKeys.themeMode,
      defaultValue: ThemeMode.system.index,
    ) as int;

    final refreshModeIndex = box.get(
      SettingsKeys.refreshMode,
      defaultValue: RefreshMode.onUnlock.index,
    ) as int;

    final language = box.get(
      SettingsKeys.language,
      defaultValue: 'fr',
    ) as String;

    final fontSizeMultiplier = box.get(
      SettingsKeys.fontSizeMultiplier,
      defaultValue: 1.0,
    ) as double;

    final widgetRotationEnabled = box.get(
      SettingsKeys.widgetRotationEnabled,
      defaultValue: true,
    ) as bool;

    final breathingAnimationEnabled = box.get(
      SettingsKeys.breathingAnimationEnabled,
      defaultValue: true,
    ) as bool;

    final hasCompletedOnboarding = box.get(
      SettingsKeys.hasCompletedOnboarding,
      defaultValue: false,
    ) as bool;

    return Settings(
      themeMode: ThemeMode.values[themeModeIndex],
      refreshMode: RefreshMode.values[refreshModeIndex],
      language: language,
      fontSizeMultiplier: fontSizeMultiplier,
      widgetRotationEnabled: widgetRotationEnabled,
      breathingAnimationEnabled: breathingAnimationEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    final box = await _settingsBox;
    await box.put(SettingsKeys.themeMode, settings.themeMode.index);
    await box.put(SettingsKeys.refreshMode, settings.refreshMode.index);
    await box.put(SettingsKeys.language, settings.language);
    await box.put(
      SettingsKeys.fontSizeMultiplier,
      settings.fontSizeMultiplier,
    );
    await box.put(
      SettingsKeys.widgetRotationEnabled,
      settings.widgetRotationEnabled,
    );
    await box.put(
      SettingsKeys.breathingAnimationEnabled,
      settings.breathingAnimationEnabled,
    );
    await box.put(
      SettingsKeys.hasCompletedOnboarding,
      settings.hasCompletedOnboarding,
    );
  }

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final box = await _settingsBox;
    await box.put(SettingsKeys.themeMode, themeMode.index);
  }

  @override
  Future<void> updateRefreshMode(RefreshMode refreshMode) async {
    final box = await _settingsBox;
    await box.put(SettingsKeys.refreshMode, refreshMode.index);
  }

  @override
  Future<void> updateLanguage(String language) async {
    final box = await _settingsBox;
    await box.put(SettingsKeys.language, language);
  }

  @override
  Future<void> updateFontSizeMultiplier(double multiplier) async {
    final box = await _settingsBox;
    await box.put(SettingsKeys.fontSizeMultiplier, multiplier);
  }

  @override
  Future<void> updateWidgetRotationEnabled(bool enabled) async {
    final box = await _settingsBox;
    await box.put(SettingsKeys.widgetRotationEnabled, enabled);
  }

  @override
  Future<void> updateBreathingAnimationEnabled(bool enabled) async {
    final box = await _settingsBox;
    await box.put(SettingsKeys.breathingAnimationEnabled, enabled);
  }

  @override
  Future<void> updateHasCompletedOnboarding(bool completed) async {
    final box = await _settingsBox;
    await box.put(SettingsKeys.hasCompletedOnboarding, completed);
  }

  @override
  Future<void> resetToDefaults() async {
    await saveSettings(Settings.defaultSettings);
  }
}
