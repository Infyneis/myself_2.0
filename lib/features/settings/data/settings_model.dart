/// Settings data model.
///
/// Represents user preferences for the application.
/// Based on REQUIREMENTS.md Section 9.3.
library;

/// Enum representing theme mode options.
enum ThemeMode {
  /// Light theme
  light,

  /// Dark theme
  dark,

  /// Follow system theme
  system,
}

/// Enum representing widget refresh modes.
enum RefreshMode {
  /// Refresh on every phone unlock
  onUnlock,

  /// Refresh hourly
  hourly,

  /// Refresh daily
  daily,
}

/// Settings data model containing user preferences.
///
/// Note: Hive type adapter will be implemented in FUNC-010.
class Settings {
  /// Creates a Settings instance.
  const Settings({
    this.themeMode = ThemeMode.system,
    this.refreshMode = RefreshMode.onUnlock,
    this.language = 'fr',
    this.fontSizeMultiplier = 1.0,
    this.widgetRotationEnabled = true,
    this.breathingAnimationEnabled = true,
  });

  /// Current theme mode (light, dark, or system)
  final ThemeMode themeMode;

  /// Widget refresh mode
  final RefreshMode refreshMode;

  /// Current language code (fr or en)
  final String language;

  /// Font size multiplier for accessibility (0.8 - 1.4)
  final double fontSizeMultiplier;

  /// Whether widget affirmation rotation is enabled
  final bool widgetRotationEnabled;

  /// Whether breathing animation is enabled for affirmations
  final bool breathingAnimationEnabled;

  /// Creates a copy of settings with the given fields replaced.
  Settings copyWith({
    ThemeMode? themeMode,
    RefreshMode? refreshMode,
    String? language,
    double? fontSizeMultiplier,
    bool? widgetRotationEnabled,
    bool? breathingAnimationEnabled,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      refreshMode: refreshMode ?? this.refreshMode,
      language: language ?? this.language,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      widgetRotationEnabled:
          widgetRotationEnabled ?? this.widgetRotationEnabled,
      breathingAnimationEnabled:
          breathingAnimationEnabled ?? this.breathingAnimationEnabled,
    );
  }

  /// Default settings instance.
  static const Settings defaultSettings = Settings();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settings &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          refreshMode == other.refreshMode &&
          language == other.language &&
          fontSizeMultiplier == other.fontSizeMultiplier &&
          widgetRotationEnabled == other.widgetRotationEnabled &&
          breathingAnimationEnabled == other.breathingAnimationEnabled;

  @override
  int get hashCode =>
      themeMode.hashCode ^
      refreshMode.hashCode ^
      language.hashCode ^
      fontSizeMultiplier.hashCode ^
      widgetRotationEnabled.hashCode ^
      breathingAnimationEnabled.hashCode;

  @override
  String toString() {
    return 'Settings(themeMode: $themeMode, refreshMode: $refreshMode, '
        'language: $language, fontSizeMultiplier: $fontSizeMultiplier, '
        'widgetRotationEnabled: $widgetRotationEnabled, '
        'breathingAnimationEnabled: $breathingAnimationEnabled)';
  }
}
