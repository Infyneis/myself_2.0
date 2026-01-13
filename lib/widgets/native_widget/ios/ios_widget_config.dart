/// iOS widget configuration.
///
/// Configuration and utilities specific to iOS WidgetKit.
/// Based on REQUIREMENTS.md Section 9.4.
library;

/// Configuration for iOS home screen widget.
///
/// Note: The actual iOS widget extension (Swift/SwiftUI) will be
/// implemented in WIDGET-003 and WIDGET-004.
class IosWidgetConfig {
  IosWidgetConfig._();

  /// App Group ID for shared data between app and widget extension.
  static const String appGroupId = 'group.com.infyneis.myself_2_0';

  /// Widget kind identifier for WidgetKit.
  static const String widgetKind = 'MyselfWidget';

  /// Small widget size (2x2)
  static const String sizeSmall = 'small';

  /// Medium widget size (4x2)
  static const String sizeMedium = 'medium';

  /// Large widget size (4x4)
  static const String sizeLarge = 'large';

  /// Shared defaults keys for affirmation data

  /// Key for storing the affirmation text in shared defaults.
  static const String affirmationTextKey = 'affirmation_text';

  /// Key for storing the affirmation ID in shared defaults.
  static const String affirmationIdKey = 'affirmation_id';

  /// Key for storing the last update timestamp in shared defaults.
  static const String lastUpdateKey = 'last_update';

  /// Shared defaults keys for settings data

  /// Key for storing the theme mode setting in shared defaults.
  static const String themeModeKey = 'theme_mode';

  /// Key for storing whether widget rotation is enabled in shared defaults.
  static const String widgetRotationEnabledKey = 'widget_rotation_enabled';

  /// Key for storing the font size multiplier in shared defaults.
  static const String fontSizeMultiplierKey = 'font_size_multiplier';

  /// Key for storing the refresh mode setting in shared defaults.
  static const String refreshModeKey = 'refresh_mode';

  /// Shared defaults keys for multiple affirmations (for larger widgets)

  /// Key for storing the list of affirmations in shared defaults.
  static const String affirmationsListKey = 'affirmations_list';

  /// Key for storing the count of affirmations in shared defaults.
  static const String affirmationsCountKey = 'affirmations_count';

  /// Shared defaults key for placeholder state
  static const String hasAffirmationsKey = 'has_affirmations';
}
