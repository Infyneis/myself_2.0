/// Widget data synchronization helper.
///
/// Provides convenient methods to sync app data with native widgets.
/// Implements WIDGET-002: Data sharing between Flutter app and native widgets.
library;

import '../../features/affirmations/data/models/affirmation.dart';
import '../../features/settings/data/settings_model.dart';
import 'widget_service.dart';

/// Helper class for synchronizing app data with native widgets.
///
/// This class provides high-level methods to sync affirmations and settings
/// with the native widgets, abstracting the details of data serialization
/// and platform-specific storage.
///
/// Example usage:
/// ```dart
/// final sync = WidgetDataSync(widgetService: WidgetService());
///
/// // Sync current affirmation
/// await sync.syncCurrentAffirmation(affirmation);
///
/// // Sync settings
/// await sync.syncSettings(settings);
///
/// // Sync all data
/// await sync.syncAllData(
///   currentAffirmation: affirmation,
///   allAffirmations: affirmations,
///   settings: settings,
/// );
/// ```
class WidgetDataSync {
  /// Creates a WidgetDataSync instance.
  const WidgetDataSync({
    required WidgetService widgetService,
  }) : _widgetService = widgetService;

  final WidgetService _widgetService;

  /// Syncs the current affirmation with the widget.
  ///
  /// This updates the affirmation displayed on the widget.
  ///
  /// Returns true if sync was successful, false otherwise.
  Future<bool> syncCurrentAffirmation(Affirmation? affirmation) async {
    if (affirmation == null) {
      return await _widgetService.clearWidget();
    }

    return await _widgetService.updateWidget(
      affirmationText: affirmation.text,
      affirmationId: affirmation.id,
    );
  }

  /// Syncs settings with the widget.
  ///
  /// This updates the widget's appearance and behavior based on user settings.
  ///
  /// Returns true if sync was successful, false otherwise.
  Future<bool> syncSettings(Settings settings) async {
    return await _widgetService.shareSettings(
      themeMode: settings.themeMode.name,
      widgetRotationEnabled: settings.widgetRotationEnabled,
      fontSizeMultiplier: settings.fontSizeMultiplier,
      refreshMode: settings.refreshMode.name,
    );
  }

  /// Syncs a list of affirmations with the widget.
  ///
  /// This is useful for widgets that can display multiple affirmations
  /// or select randomly from a pool.
  ///
  /// Only active affirmations are synced.
  ///
  /// Returns true if sync was successful, false otherwise.
  Future<bool> syncAffirmationsList(List<Affirmation> affirmations) async {
    final activeAffirmations = affirmations
        .where((a) => a.isActive)
        .map((a) => {
              'id': a.id,
              'text': a.text,
              'displayCount': a.displayCount,
              'isActive': a.isActive,
            })
        .toList();

    return await _widgetService.shareAffirmationsList(activeAffirmations);
  }

  /// Syncs all data (current affirmation, settings, and affirmations list) with the widget.
  ///
  /// This is a comprehensive sync operation that updates all widget data.
  /// Useful for:
  /// - Initial widget setup
  /// - After significant data changes
  /// - After app updates or migrations
  ///
  /// Returns true if all syncs were successful, false otherwise.
  Future<bool> syncAllData({
    Affirmation? currentAffirmation,
    required List<Affirmation> allAffirmations,
    required Settings settings,
  }) async {
    final activeAffirmations = allAffirmations
        .where((a) => a.isActive)
        .map((a) => {
              'id': a.id,
              'text': a.text,
              'displayCount': a.displayCount,
              'isActive': a.isActive,
            })
        .toList();

    return await _widgetService.shareAllWidgetData(
      affirmationText: currentAffirmation?.text,
      affirmationId: currentAffirmation?.id,
      themeMode: settings.themeMode.name,
      widgetRotationEnabled: settings.widgetRotationEnabled,
      fontSizeMultiplier: settings.fontSizeMultiplier,
      refreshMode: settings.refreshMode.name,
      affirmationsList: activeAffirmations,
    );
  }

  /// Clears all widget data.
  ///
  /// Useful for:
  /// - User logout
  /// - Data reset
  /// - Widget removal
  ///
  /// Returns true if clear was successful, false otherwise.
  Future<bool> clearAllData() async {
    return await _widgetService.clearAllWidgetData();
  }

  /// Syncs when an affirmation is created.
  ///
  /// Updates the affirmations list and optionally sets as current affirmation.
  Future<bool> onAffirmationCreated({
    required Affirmation newAffirmation,
    required List<Affirmation> allAffirmations,
    bool setAsCurrent = false,
  }) async {
    // Sync the list
    await syncAffirmationsList(allAffirmations);

    // Optionally set as current
    if (setAsCurrent) {
      await syncCurrentAffirmation(newAffirmation);
    }

    return true;
  }

  /// Syncs when an affirmation is updated.
  ///
  /// Updates the affirmations list and current affirmation if needed.
  Future<bool> onAffirmationUpdated({
    required Affirmation updatedAffirmation,
    required List<Affirmation> allAffirmations,
    required String? currentAffirmationId,
  }) async {
    // Sync the list
    await syncAffirmationsList(allAffirmations);

    // Update current affirmation if it's the one that was updated
    if (currentAffirmationId == updatedAffirmation.id) {
      await syncCurrentAffirmation(updatedAffirmation);
    }

    return true;
  }

  /// Syncs when an affirmation is deleted.
  ///
  /// Updates the affirmations list and clears current if it was deleted.
  Future<bool> onAffirmationDeleted({
    required String deletedId,
    required List<Affirmation> allAffirmations,
    required String? currentAffirmationId,
  }) async {
    // Sync the list
    await syncAffirmationsList(allAffirmations);

    // Clear current affirmation if it was deleted
    if (currentAffirmationId == deletedId) {
      await _widgetService.clearWidget();
    }

    return true;
  }

  /// Syncs when settings are updated.
  Future<bool> onSettingsUpdated(Settings settings) async {
    return await syncSettings(settings);
  }
}
