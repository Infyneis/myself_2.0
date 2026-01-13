/// Mock repositories for testing.
library;

import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart';
import 'package:myself_2_0/features/settings/data/settings_repository.dart';
import 'package:myself_2_0/widgets/native_widget/widget_data_sync.dart';

/// Mock implementation of SettingsRepository for testing.
class MockSettingsRepository implements SettingsRepository {
  Settings settings = Settings.defaultSettings;
  bool updateLanguageCalled = false;
  bool shouldFailOnLanguageUpdate = false;

  void resetCalls() {
    updateLanguageCalled = false;
    shouldFailOnLanguageUpdate = false;
  }

  @override
  Future<Settings> getSettings() async {
    return settings;
  }

  @override
  Future<void> saveSettings(Settings newSettings) async {
    settings = newSettings;
  }

  @override
  Future<void> updateThemeMode(ThemeMode mode) async {
    settings = settings.copyWith(themeMode: mode);
  }

  @override
  Future<void> updateRefreshMode(RefreshMode mode) async {
    settings = settings.copyWith(refreshMode: mode);
  }

  @override
  Future<void> updateLanguage(String language) async {
    updateLanguageCalled = true;
    if (shouldFailOnLanguageUpdate) {
      throw Exception('Failed to update language');
    }
    settings = settings.copyWith(language: language);
  }

  @override
  Future<void> updateFontSizeMultiplier(double multiplier) async {
    settings = settings.copyWith(fontSizeMultiplier: multiplier);
  }

  @override
  Future<void> updateWidgetRotationEnabled(bool enabled) async {
    settings = settings.copyWith(widgetRotationEnabled: enabled);
  }

  @override
  Future<void> updateBreathingAnimationEnabled(bool enabled) async {
    settings = settings.copyWith(breathingAnimationEnabled: enabled);
  }

  @override
  Future<void> updateHasCompletedOnboarding(bool completed) async {
    settings = settings.copyWith(hasCompletedOnboarding: completed);
  }

  @override
  Future<void> resetToDefaults() async {
    settings = Settings.defaultSettings;
  }
}

/// Mock implementation of AffirmationRepository for testing.
class MockAffirmationRepository implements AffirmationRepository {
  final List<Affirmation> _affirmations = [];

  @override
  Future<List<Affirmation>> getAll() async {
    return List.unmodifiable(_affirmations);
  }

  @override
  Future<List<Affirmation>> getActive() async {
    return _affirmations.where((a) => a.isActive).toList();
  }

  @override
  Future<Affirmation?> getById(String id) async {
    try {
      return _affirmations.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Affirmation> create(Affirmation affirmation) async {
    _affirmations.add(affirmation);
    return affirmation;
  }

  @override
  Future<Affirmation> update(Affirmation affirmation) async {
    final index = _affirmations.indexWhere((a) => a.id == affirmation.id);
    if (index != -1) {
      _affirmations[index] = affirmation;
    }
    return affirmation;
  }

  @override
  Future<bool> delete(String id) async {
    final sizeBefore = _affirmations.length;
    _affirmations.removeWhere((a) => a.id == id);
    return _affirmations.length < sizeBefore;
  }

  @override
  Future<void> deleteAll() async {
    _affirmations.clear();
  }

  @override
  Future<int> count() async {
    return _affirmations.length;
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    final orderedAffirmations = <Affirmation>[];
    for (final id in orderedIds) {
      final affirmation = _affirmations.firstWhere((a) => a.id == id);
      orderedAffirmations.add(affirmation);
    }
    _affirmations.clear();
    _affirmations.addAll(orderedAffirmations);
  }
}

/// Mock implementation of WidgetDataSync for testing.
class MockWidgetDataSync implements WidgetDataSync {
  bool syncAffirmationCalled = false;
  bool syncSettingsCalled = false;
  Affirmation? lastSyncedAffirmation;
  Settings? lastSyncedSettings;

  void reset() {
    syncAffirmationCalled = false;
    syncSettingsCalled = false;
    lastSyncedAffirmation = null;
    lastSyncedSettings = null;
  }

  @override
  Future<bool> syncCurrentAffirmation(Affirmation? affirmation) async {
    syncAffirmationCalled = true;
    lastSyncedAffirmation = affirmation;
    return true;
  }

  @override
  Future<bool> syncSettings(Settings settings) async {
    syncSettingsCalled = true;
    lastSyncedSettings = settings;
    return true;
  }

  @override
  Future<bool> syncAffirmationsList(List<Affirmation> affirmations) async {
    syncAffirmationCalled = true;
    return true;
  }

  @override
  Future<bool> syncAllData({
    Affirmation? currentAffirmation,
    required List<Affirmation> allAffirmations,
    required Settings settings,
  }) async {
    syncAffirmationCalled = true;
    syncSettingsCalled = true;
    lastSyncedAffirmation = currentAffirmation;
    lastSyncedSettings = settings;
    return true;
  }

  @override
  Future<bool> clearAllData() async {
    lastSyncedAffirmation = null;
    lastSyncedSettings = null;
    return true;
  }

  @override
  Future<bool> onAffirmationCreated({
    required Affirmation newAffirmation,
    required List<Affirmation> allAffirmations,
    bool setAsCurrent = false,
  }) async {
    syncAffirmationCalled = true;
    if (setAsCurrent) {
      lastSyncedAffirmation = newAffirmation;
    }
    return true;
  }

  @override
  Future<bool> onAffirmationUpdated({
    required Affirmation updatedAffirmation,
    required List<Affirmation> allAffirmations,
    required String? currentAffirmationId,
  }) async {
    syncAffirmationCalled = true;
    if (currentAffirmationId == updatedAffirmation.id) {
      lastSyncedAffirmation = updatedAffirmation;
    }
    return true;
  }

  @override
  Future<bool> onAffirmationDeleted({
    required String deletedId,
    required List<Affirmation> allAffirmations,
    required String? currentAffirmationId,
  }) async {
    syncAffirmationCalled = true;
    if (currentAffirmationId == deletedId) {
      lastSyncedAffirmation = null;
    }
    return true;
  }

  @override
  Future<bool> onSettingsUpdated(Settings settings) async {
    syncSettingsCalled = true;
    lastSyncedSettings = settings;
    return true;
  }
}
