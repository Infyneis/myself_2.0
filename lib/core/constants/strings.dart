/// App string constants.
///
/// Note: User-facing strings should use localization (l10n).
/// This file contains only non-translatable technical strings.
library;

/// Application string constants for Myself 2.0.
class AppStrings {
  AppStrings._();

  /// Application name
  static const String appName = 'Myself 2.0';

  /// Application bundle identifier
  static const String bundleId = 'com.infyneis.myself_2_0';

  // Storage keys
  /// Key for affirmations storage in Hive
  static const String affirmationsBoxName = 'affirmations';

  /// Key for settings storage in Hive
  static const String settingsBoxName = 'settings';

  /// Key for last displayed affirmation ID
  static const String lastDisplayedIdKey = 'lastDisplayedId';

  /// Key for onboarding completed flag
  static const String onboardingCompletedKey = 'onboardingCompleted';

  // Widget keys
  /// App group ID for iOS widget data sharing
  static const String appGroupId = 'group.com.infyneis.myself_2_0';

  /// Widget ID for home_widget package
  static const String homeWidgetName = 'MyselfWidget';
}
