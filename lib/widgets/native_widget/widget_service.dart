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

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/utils/performance_monitor.dart';
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
  ///
  /// ## Performance (PERF-002)
  /// This method is optimized to complete within 500ms:
  /// - Batches all data saves together to minimize I/O operations
  /// - Uses Future.wait() for parallel operations where possible
  /// - Monitors execution time in debug mode
  Future<bool> updateWidget({
    required String affirmationText,
    required String affirmationId,
  }) async {
    final monitor = kDebugMode ? PerformanceMonitor.start() : null;

    try {
      monitor?.logCheckpoint('Start updateWidget');

      // Batch save operations to reduce I/O overhead
      final textKey = Platform.isIOS
          ? IosWidgetConfig.affirmationTextKey
          : AndroidWidgetConfig.affirmationTextKey;
      final idKey = Platform.isIOS
          ? IosWidgetConfig.affirmationIdKey
          : AndroidWidgetConfig.affirmationIdKey;
      final updateKey = Platform.isIOS
          ? IosWidgetConfig.lastUpdateKey
          : AndroidWidgetConfig.lastUpdateKey;

      // Execute all saves in parallel for better performance
      await Future.wait([
        HomeWidget.saveWidgetData<String>(textKey, affirmationText),
        HomeWidget.saveWidgetData<String>(idKey, affirmationId),
        HomeWidget.saveWidgetData<String>(
          updateKey,
          DateTime.now().toIso8601String(),
        ),
      ]);

      monitor?.logCheckpoint('Data saved');

      // Trigger widget update
      final result = await _updateNativeWidget();

      monitor?.stop();
      monitor?.logWidgetUpdateSummary(operation: 'updateWidget');

      return result;
    } catch (e) {
      // Log error but don't throw - widget functionality is optional
      // ignore: avoid_print
      print('Warning: Failed to update widget: $e');

      monitor?.stop();
      if (kDebugMode && monitor != null) {
        debugPrint('Widget update failed after ${monitor.elapsedMs}ms');
      }

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
  ///
  /// ## Performance (PERF-002)
  /// Optimized to complete within 500ms using parallel save operations.
  Future<bool> shareSettings({
    required String themeMode,
    required bool widgetRotationEnabled,
    required double fontSizeMultiplier,
    String refreshMode = 'onUnlock',
  }) async {
    final monitor = kDebugMode ? PerformanceMonitor.start() : null;

    try {
      monitor?.logCheckpoint('Start shareSettings');

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

      // Execute all saves in parallel for better performance
      await Future.wait([
        HomeWidget.saveWidgetData<String>(themeModeKey, themeMode),
        HomeWidget.saveWidgetData<bool>(rotationKey, widgetRotationEnabled),
        HomeWidget.saveWidgetData<double>(fontSizeKey, fontSizeMultiplier),
        HomeWidget.saveWidgetData<String>(refreshModeKey, refreshMode),
      ]);

      monitor?.logCheckpoint('Settings saved');

      // Trigger widget update to reflect new settings
      final result = await _updateNativeWidget();

      monitor?.stop();
      monitor?.logWidgetUpdateSummary(operation: 'shareSettings');

      return result;
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Failed to share settings with widget: $e');

      monitor?.stop();
      if (kDebugMode && monitor != null) {
        debugPrint('Share settings failed after ${monitor.elapsedMs}ms');
      }

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
  ///
  /// ## Performance (PERF-002)
  /// Optimized to complete within 500ms using parallel save operations.
  Future<bool> shareAffirmationsList(
    List<Map<String, dynamic>> affirmations,
  ) async {
    final monitor = kDebugMode ? PerformanceMonitor.start() : null;

    try {
      monitor?.logCheckpoint('Start shareAffirmationsList');

      final listKey = Platform.isIOS
          ? IosWidgetConfig.affirmationsListKey
          : AndroidWidgetConfig.affirmationsListKey;
      final countKey = Platform.isIOS
          ? IosWidgetConfig.affirmationsCountKey
          : AndroidWidgetConfig.affirmationsCountKey;
      final hasAffirmationsKey = Platform.isIOS
          ? IosWidgetConfig.hasAffirmationsKey
          : AndroidWidgetConfig.hasAffirmationsKey;

      // Serialize affirmations list to JSON string (pre-compute)
      final jsonString = jsonEncode(affirmations);
      final count = affirmations.length;
      final hasAffirmations = affirmations.isNotEmpty;

      monitor?.logCheckpoint('JSON serialized');

      // Execute all saves in parallel for better performance
      await Future.wait([
        HomeWidget.saveWidgetData<String>(listKey, jsonString),
        HomeWidget.saveWidgetData<int>(countKey, count),
        HomeWidget.saveWidgetData<bool>(hasAffirmationsKey, hasAffirmations),
      ]);

      monitor?.logCheckpoint('List data saved');

      // Trigger widget update
      final result = await _updateNativeWidget();

      monitor?.stop();
      monitor?.logWidgetUpdateSummary(operation: 'shareAffirmationsList');

      return result;
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Failed to share affirmations list with widget: $e');

      monitor?.stop();
      if (kDebugMode && monitor != null) {
        debugPrint('Share affirmations list failed after ${monitor.elapsedMs}ms');
      }

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
  ///
  /// ## Performance (PERF-002)
  /// This method is heavily optimized to complete within 500ms:
  /// - All data saves are batched into a single Future.wait() call
  /// - No intermediate widget updates (only one update at the end)
  /// - Pre-computes all values before any I/O operations
  /// - Uses parallel execution for maximum throughput
  Future<bool> shareAllWidgetData({
    String? affirmationText,
    String? affirmationId,
    required String themeMode,
    required bool widgetRotationEnabled,
    required double fontSizeMultiplier,
    String refreshMode = 'onUnlock',
    List<Map<String, dynamic>>? affirmationsList,
  }) async {
    final monitor = kDebugMode ? PerformanceMonitor.start() : null;

    try {
      monitor?.logCheckpoint('Start shareAllWidgetData');

      // Pre-compute all keys to avoid platform checks during I/O
      final textKey = Platform.isIOS
          ? IosWidgetConfig.affirmationTextKey
          : AndroidWidgetConfig.affirmationTextKey;
      final idKey = Platform.isIOS
          ? IosWidgetConfig.affirmationIdKey
          : AndroidWidgetConfig.affirmationIdKey;
      final updateKey = Platform.isIOS
          ? IosWidgetConfig.lastUpdateKey
          : AndroidWidgetConfig.lastUpdateKey;
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
      final listKey = Platform.isIOS
          ? IosWidgetConfig.affirmationsListKey
          : AndroidWidgetConfig.affirmationsListKey;
      final countKey = Platform.isIOS
          ? IosWidgetConfig.affirmationsCountKey
          : AndroidWidgetConfig.affirmationsCountKey;
      final hasAffirmationsKey = Platform.isIOS
          ? IosWidgetConfig.hasAffirmationsKey
          : AndroidWidgetConfig.hasAffirmationsKey;

      // Pre-compute all values
      final now = DateTime.now().toIso8601String();
      final jsonString = affirmationsList != null
          ? jsonEncode(affirmationsList)
          : null;
      final count = affirmationsList?.length ?? 0;
      final hasAffirmations = affirmationsList?.isNotEmpty ?? false;

      monitor?.logCheckpoint('Values pre-computed');

      // Batch ALL saves into a single parallel operation
      // This is the key optimization - no intermediate widget updates
      final futures = <Future<void>>[
        // Current affirmation data
        if (affirmationText != null && affirmationId != null) ...[
          HomeWidget.saveWidgetData<String>(textKey, affirmationText),
          HomeWidget.saveWidgetData<String>(idKey, affirmationId),
          HomeWidget.saveWidgetData<String>(updateKey, now),
        ] else ...[
          HomeWidget.saveWidgetData<String?>(textKey, null),
          HomeWidget.saveWidgetData<String?>(idKey, null),
        ],
        // Settings data
        HomeWidget.saveWidgetData<String>(themeModeKey, themeMode),
        HomeWidget.saveWidgetData<bool>(rotationKey, widgetRotationEnabled),
        HomeWidget.saveWidgetData<double>(fontSizeKey, fontSizeMultiplier),
        HomeWidget.saveWidgetData<String>(refreshModeKey, refreshMode),
        // List data
        if (affirmationsList != null && jsonString != null) ...[
          HomeWidget.saveWidgetData<String>(listKey, jsonString),
          HomeWidget.saveWidgetData<int>(countKey, count),
          HomeWidget.saveWidgetData<bool>(hasAffirmationsKey, hasAffirmations),
        ],
      ];

      await Future.wait(futures);

      monitor?.logCheckpoint('All data saved');

      // Single widget update at the end
      final result = await _updateNativeWidget();

      monitor?.stop();
      monitor?.logWidgetUpdateSummary(operation: 'shareAllWidgetData');

      return result;
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Failed to share all widget data: $e');

      monitor?.stop();
      if (kDebugMode && monitor != null) {
        debugPrint('Share all widget data failed after ${monitor.elapsedMs}ms');
      }

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
