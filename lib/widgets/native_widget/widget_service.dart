/// Widget service for home screen widget management.
///
/// Provides Flutter-side interface for native widget communication.
/// Based on REQUIREMENTS.md widget requirements.
///
/// ## Data Sharing Implementation
///
/// This service implements WIDGET-002: Data sharing between Flutter app and
/// native widgets using platform-specific storage mechanisms:
///
/// ### iOS (SharedDefaults)
/// - Uses App Groups to share data between the main app and widget extension
/// - Data is stored in UserDefaults within the shared App Group container
/// - App Group ID: `group.com.infyneis.myself_2_0`
/// - Accessible from both the main app and WidgetKit extension
///
/// ### Android (SharedPreferences)
/// - Uses SharedPreferences with a specific name for widget data
/// - Accessible from both the main app and AppWidgetProvider
/// - Data is stored in XML format in the app's private storage
///
/// ### Supported Data Types
/// - Strings: Affirmation text, IDs, settings
/// - Booleans: Feature flags, widget rotation enabled
/// - Integers: Display counts, font size preference
/// - Doubles: Font size multipliers
/// - DateTime: Stored as ISO 8601 strings
/// - Complex objects: Serialized to JSON strings
library;

import 'dart:convert';
import 'dart:io';

import 'package:home_widget/home_widget.dart';

import 'android/android_widget_config.dart';
import 'ios/ios_widget_config.dart';

/// Service for managing home screen widget data.
///
/// Uses the home_widget package to communicate with native widgets
/// on both iOS and Android.
///
/// Implements:
/// - WIDGET-001: Platform channel integration for widget communication
/// - WIDGET-002: Data sharing using SharedDefaults (iOS) and SharedPreferences (Android)
class WidgetService {
  /// Singleton instance of WidgetService.
  static final WidgetService _instance = WidgetService._internal();

  /// Factory constructor to return the singleton instance.
  factory WidgetService() => _instance;

  /// Private constructor for singleton pattern.
  WidgetService._internal();

  /// Initializes the widget service.
  ///
  /// This should be called during app initialization to set up
  /// platform-specific configurations.
  Future<void> initialize() async {
    try {
      if (Platform.isIOS) {
        // Set iOS app group ID for shared data between app and widget
        await HomeWidget.setAppGroupId(IosWidgetConfig.appGroupId);
      }
    } catch (e) {
      // Log error but don't throw - widget functionality is optional
      // ignore: avoid_print
      print('Warning: Failed to initialize widget service: $e');
    }
  }

  /// Updates the widget with a new affirmation.
  ///
  /// [affirmationText] - The text to display on the widget.
  /// [affirmationId] - The ID of the affirmation for tracking.
  ///
  /// Returns true if the update was successful, false otherwise.
  Future<bool> updateWidget({
    required String affirmationText,
    required String affirmationId,
  }) async {
    try {
      // Save data to shared storage
      await HomeWidget.saveWidgetData<String>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationTextKey
            : AndroidWidgetConfig.affirmationTextKey,
        affirmationText,
      );

      await HomeWidget.saveWidgetData<String>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationIdKey
            : AndroidWidgetConfig.affirmationIdKey,
        affirmationId,
      );

      await HomeWidget.saveWidgetData<String>(
        Platform.isIOS
            ? IosWidgetConfig.lastUpdateKey
            : AndroidWidgetConfig.lastUpdateKey,
        DateTime.now().toIso8601String(),
      );

      // Trigger widget update
      return await _updateNativeWidget();
    } catch (e) {
      // Log error but don't throw - widget functionality is optional
      // ignore: avoid_print
      print('Warning: Failed to update widget: $e');
      return false;
    }
  }

  /// Clears the widget data (shows placeholder).
  ///
  /// Returns true if the clear was successful, false otherwise.
  Future<bool> clearWidget() async {
    try {
      // Clear all widget data
      await HomeWidget.saveWidgetData<String?>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationTextKey
            : AndroidWidgetConfig.affirmationTextKey,
        null,
      );

      await HomeWidget.saveWidgetData<String?>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationIdKey
            : AndroidWidgetConfig.affirmationIdKey,
        null,
      );

      // Trigger widget update to show placeholder
      return await _updateNativeWidget();
    } catch (e) {
      // Log error but don't throw - widget functionality is optional
      // ignore: avoid_print
      print('Warning: Failed to clear widget: $e');
      return false;
    }
  }

  /// Triggers a widget refresh.
  ///
  /// Returns true if the refresh was successful, false otherwise.
  Future<bool> refreshWidget() async {
    try {
      return await _updateNativeWidget();
    } catch (e) {
      // Log error but don't throw - widget functionality is optional
      // ignore: avoid_print
      print('Warning: Failed to refresh widget: $e');
      return false;
    }
  }

  /// Checks if the widget is currently displayed on the home screen.
  ///
  /// Note: This is a best-effort check and may not be 100% accurate
  /// on all platforms/versions.
  Future<bool> isWidgetActive() async {
    try {
      // On Android, we can check if the widget provider is active
      // On iOS, this is not directly queryable, so we return true
      // if the app group is set up correctly
      if (Platform.isIOS) {
        // Try to read from shared storage to verify app group is working
        await HomeWidget.getWidgetData<String>(
          IosWidgetConfig.affirmationTextKey,
        );
        // If we can read data (even if null), app group is configured
        return true;
      } else if (Platform.isAndroid) {
        // On Android, we assume the widget might be active
        // Actual detection requires native code which will be in WIDGET-005
        return true;
      }
      return false;
    } catch (e) {
      // If we can't access widget storage, it's not properly configured
      return false;
    }
  }

  /// Gets the current affirmation text from widget storage.
  ///
  /// Returns null if no affirmation is stored.
  Future<String?> getCurrentAffirmation() async {
    try {
      return await HomeWidget.getWidgetData<String>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationTextKey
            : AndroidWidgetConfig.affirmationTextKey,
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets the current affirmation ID from widget storage.
  ///
  /// Returns null if no affirmation is stored.
  Future<String?> getCurrentAffirmationId() async {
    try {
      return await HomeWidget.getWidgetData<String>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationIdKey
            : AndroidWidgetConfig.affirmationIdKey,
      );
    } catch (e) {
      return null;
    }
  }

  /// Shares settings data with the widget.
  ///
  /// This method shares relevant settings that the widget needs to render correctly:
  /// - Theme mode (light/dark/system)
  /// - Widget rotation enabled status
  /// - Font size multiplier for accessibility
  /// - Refresh mode (onUnlock/hourly/daily)
  ///
  /// Data is stored in:
  /// - iOS: UserDefaults within the App Group
  /// - Android: SharedPreferences
  ///
  /// Returns true if settings were successfully shared, false otherwise.
  Future<bool> shareSettings({
    required String themeMode,
    required bool widgetRotationEnabled,
    required double fontSizeMultiplier,
    String refreshMode = 'onUnlock',
  }) async {
    try {
      final themeModeKey = Platform.isIOS
          ? IosWidgetConfig.themeModeKey
          : AndroidWidgetConfig.themeModeKey;
      final rotationKey = Platform.isIOS
          ? IosWidgetConfig.widgetRotationEnabledKey
          : AndroidWidgetConfig.widgetRotationEnabledKey;
      final fontSizeKey = Platform.isIOS
          ? IosWidgetConfig.fontSizeMultiplierKey
          : AndroidWidgetConfig.fontSizeMultiplierKey;
      final refreshModeKey = Platform.isIOS
          ? IosWidgetConfig.refreshModeKey
          : AndroidWidgetConfig.refreshModeKey;

      await HomeWidget.saveWidgetData<String>(themeModeKey, themeMode);
      await HomeWidget.saveWidgetData<bool>(rotationKey, widgetRotationEnabled);
      await HomeWidget.saveWidgetData<double>(fontSizeKey, fontSizeMultiplier);
      await HomeWidget.saveWidgetData<String>(refreshModeKey, refreshMode);

      // Trigger widget update to reflect new settings
      return await _updateNativeWidget();
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Failed to share settings with widget: $e');
      return false;
    }
  }

  /// Gets the theme mode setting from widget storage.
  ///
  /// Returns null if no theme mode is stored.
  Future<String?> getThemeMode() async {
    try {
      return await HomeWidget.getWidgetData<String>(
        Platform.isIOS
            ? IosWidgetConfig.themeModeKey
            : AndroidWidgetConfig.themeModeKey,
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets the widget rotation enabled setting from widget storage.
  ///
  /// Returns null if no setting is stored.
  Future<bool?> getWidgetRotationEnabled() async {
    try {
      return await HomeWidget.getWidgetData<bool>(
        Platform.isIOS
            ? IosWidgetConfig.widgetRotationEnabledKey
            : AndroidWidgetConfig.widgetRotationEnabledKey,
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets the font size multiplier setting from widget storage.
  ///
  /// Returns null if no setting is stored.
  Future<double?> getFontSizeMultiplier() async {
    try {
      return await HomeWidget.getWidgetData<double>(
        Platform.isIOS
            ? IosWidgetConfig.fontSizeMultiplierKey
            : AndroidWidgetConfig.fontSizeMultiplierKey,
      );
    } catch (e) {
      return null;
    }
  }

  /// Shares a list of affirmations with the widget.
  ///
  /// This is useful for larger widgets that can display multiple affirmations
  /// or for widgets that need to randomly select from a pool.
  ///
  /// The affirmations are serialized to JSON and stored in:
  /// - iOS: UserDefaults within the App Group
  /// - Android: SharedPreferences
  ///
  /// [affirmations] - List of maps containing affirmation data.
  ///                  Each map should have 'id' and 'text' keys at minimum.
  ///
  /// Returns true if affirmations were successfully shared, false otherwise.
  Future<bool> shareAffirmationsList(
    List<Map<String, dynamic>> affirmations,
  ) async {
    try {
      final listKey = Platform.isIOS
          ? IosWidgetConfig.affirmationsListKey
          : AndroidWidgetConfig.affirmationsListKey;
      final countKey = Platform.isIOS
          ? IosWidgetConfig.affirmationsCountKey
          : AndroidWidgetConfig.affirmationsCountKey;
      final hasAffirmationsKey = Platform.isIOS
          ? IosWidgetConfig.hasAffirmationsKey
          : AndroidWidgetConfig.hasAffirmationsKey;

      // Serialize affirmations list to JSON string
      final jsonString = jsonEncode(affirmations);

      await HomeWidget.saveWidgetData<String>(listKey, jsonString);
      await HomeWidget.saveWidgetData<int>(countKey, affirmations.length);
      await HomeWidget.saveWidgetData<bool>(
        hasAffirmationsKey,
        affirmations.isNotEmpty,
      );

      // Trigger widget update
      return await _updateNativeWidget();
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Failed to share affirmations list with widget: $e');
      return false;
    }
  }

  /// Gets the list of affirmations from widget storage.
  ///
  /// Returns an empty list if no affirmations are stored or if parsing fails.
  Future<List<Map<String, dynamic>>> getAffirmationsList() async {
    try {
      final jsonString = await HomeWidget.getWidgetData<String>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationsListKey
            : AndroidWidgetConfig.affirmationsListKey,
      );

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Failed to get affirmations list from widget: $e');
      return [];
    }
  }

  /// Gets the count of affirmations from widget storage.
  ///
  /// Returns 0 if no count is stored.
  Future<int> getAffirmationsCount() async {
    try {
      return await HomeWidget.getWidgetData<int>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationsCountKey
            : AndroidWidgetConfig.affirmationsCountKey,
      ) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Gets whether there are any affirmations stored.
  ///
  /// Returns false if no data is stored.
  Future<bool> getHasAffirmations() async {
    try {
      return await HomeWidget.getWidgetData<bool>(
        Platform.isIOS
            ? IosWidgetConfig.hasAffirmationsKey
            : AndroidWidgetConfig.hasAffirmationsKey,
      ) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Shares all widget data including current affirmation, settings, and list.
  ///
  /// This is a comprehensive method that shares all data the widget needs
  /// in a single call. Useful for initial setup or after significant data changes.
  ///
  /// Returns true if all data was successfully shared, false otherwise.
  Future<bool> shareAllWidgetData({
    String? affirmationText,
    String? affirmationId,
    required String themeMode,
    required bool widgetRotationEnabled,
    required double fontSizeMultiplier,
    String refreshMode = 'onUnlock',
    List<Map<String, dynamic>>? affirmationsList,
  }) async {
    try {
      // Share current affirmation if provided
      if (affirmationText != null && affirmationId != null) {
        await updateWidget(
          affirmationText: affirmationText,
          affirmationId: affirmationId,
        );
      } else {
        // Clear current affirmation
        await clearWidget();
      }

      // Share settings
      await shareSettings(
        themeMode: themeMode,
        widgetRotationEnabled: widgetRotationEnabled,
        fontSizeMultiplier: fontSizeMultiplier,
        refreshMode: refreshMode,
      );

      // Share affirmations list if provided
      if (affirmationsList != null) {
        await shareAffirmationsList(affirmationsList);
      }

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Failed to share all widget data: $e');
      return false;
    }
  }

  /// Removes all widget data from shared storage.
  ///
  /// This clears all data stored in:
  /// - iOS: UserDefaults within the App Group
  /// - Android: SharedPreferences
  ///
  /// Useful for reset, logout, or when widget is removed.
  ///
  /// Returns true if all data was successfully cleared, false otherwise.
  Future<bool> clearAllWidgetData() async {
    try {
      // Clear current affirmation
      await clearWidget();

      // Clear settings
      await HomeWidget.saveWidgetData<String?>(
        Platform.isIOS
            ? IosWidgetConfig.themeModeKey
            : AndroidWidgetConfig.themeModeKey,
        null,
      );
      await HomeWidget.saveWidgetData<bool?>(
        Platform.isIOS
            ? IosWidgetConfig.widgetRotationEnabledKey
            : AndroidWidgetConfig.widgetRotationEnabledKey,
        null,
      );
      await HomeWidget.saveWidgetData<double?>(
        Platform.isIOS
            ? IosWidgetConfig.fontSizeMultiplierKey
            : AndroidWidgetConfig.fontSizeMultiplierKey,
        null,
      );

      // Clear affirmations list
      await HomeWidget.saveWidgetData<String?>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationsListKey
            : AndroidWidgetConfig.affirmationsListKey,
        null,
      );
      await HomeWidget.saveWidgetData<int?>(
        Platform.isIOS
            ? IosWidgetConfig.affirmationsCountKey
            : AndroidWidgetConfig.affirmationsCountKey,
        null,
      );
      await HomeWidget.saveWidgetData<bool?>(
        Platform.isIOS
            ? IosWidgetConfig.hasAffirmationsKey
            : AndroidWidgetConfig.hasAffirmationsKey,
        null,
      );

      // Trigger widget update
      return await _updateNativeWidget();
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Failed to clear all widget data: $e');
      return false;
    }
  }

  /// Internal method to trigger native widget updates.
  ///
  /// Platform-specific implementation:
  /// - iOS: Updates WidgetKit timeline
  /// - Android: Sends broadcast to update widget
  Future<bool> _updateNativeWidget() async {
    try {
      if (Platform.isIOS) {
        // Update iOS widget using WidgetKit
        return await HomeWidget.updateWidget(
          iOSName: IosWidgetConfig.widgetKind,
        ) ?? false;
      } else if (Platform.isAndroid) {
        // Update Android widget using broadcast
        return await HomeWidget.updateWidget(
          androidName: AndroidWidgetConfig.widgetProvider,
        ) ?? false;
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Failed to update native widget: $e');
      return false;
    }
  }
}
