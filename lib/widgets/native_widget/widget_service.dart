/// Widget service for home screen widget management.
///
/// Provides Flutter-side interface for native widget communication.
/// Based on REQUIREMENTS.md widget requirements.
library;

import 'dart:io';

import 'package:home_widget/home_widget.dart';

import 'android/android_widget_config.dart';
import 'ios/ios_widget_config.dart';

/// Service for managing home screen widget data.
///
/// Uses the home_widget package to communicate with native widgets
/// on both iOS and Android.
///
/// Implements WIDGET-001: Platform channel integration for widget communication.
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
