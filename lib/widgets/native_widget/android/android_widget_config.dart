/// Android widget configuration.
///
/// Configuration and utilities specific to Android AppWidget.
/// Based on REQUIREMENTS.md Section 9.4.
library;

/// Configuration for Android home screen widget.
///
/// Note: The actual Android widget (Kotlin) will be
/// implemented in WIDGET-005 and WIDGET-006.
class AndroidWidgetConfig {
  AndroidWidgetConfig._();

  /// Widget provider class name.
  static const String widgetProvider = 'MyselfWidgetProvider';

  /// Small widget size (2x2)
  static const String sizeSmall = 'small';

  /// Medium widget size (4x2)
  static const String sizeMedium = 'medium';

  /// Large widget size (4x4)
  static const String sizeLarge = 'large';

  /// Shared preferences keys for affirmation data

  /// Key for storing the affirmation text.
  static const String affirmationTextKey = 'affirmation_text';

  /// Key for storing the affirmation ID.
  static const String affirmationIdKey = 'affirmation_id';

  /// Key for storing the last update timestamp.
  static const String lastUpdateKey = 'last_update';

  /// Shared preferences keys for settings data

  /// Key for storing the theme mode setting.
  static const String themeModeKey = 'theme_mode';

  /// Key for storing whether widget rotation is enabled.
  static const String widgetRotationEnabledKey = 'widget_rotation_enabled';

  /// Key for storing the font size multiplier.
  static const String fontSizeMultiplierKey = 'font_size_multiplier';

  /// Key for storing the refresh mode setting.
  static const String refreshModeKey = 'refresh_mode';

  /// Shared preferences keys for multiple affirmations (for larger widgets)

  /// Key for storing the list of affirmations.
  static const String affirmationsListKey = 'affirmations_list';

  /// Key for storing the count of affirmations.
  static const String affirmationsCountKey = 'affirmations_count';

  /// Shared preferences key for placeholder state
  static const String hasAffirmationsKey = 'has_affirmations';

  /// Broadcast action for widget update
  static const String updateAction =
      'com.infyneis.myself_2_0.WIDGET_UPDATE';
}
