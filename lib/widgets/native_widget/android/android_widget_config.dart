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

  /// Shared preferences keys
  static const String affirmationTextKey = 'affirmation_text';
  static const String affirmationIdKey = 'affirmation_id';
  static const String lastUpdateKey = 'last_update';

  /// Broadcast action for widget update
  static const String updateAction =
      'com.infyneis.myself_2_0.WIDGET_UPDATE';
}
