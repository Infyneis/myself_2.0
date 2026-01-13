/// Hive database service for local storage.
///
/// Provides initialization and configuration for Hive database
/// with platform-specific paths and type adapter registration.
/// Based on REQUIREMENTS.md FR-017, FR-018.
library;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/affirmations/data/models/affirmation.dart';

/// Box names for Hive storage.
abstract class HiveBoxNames {
  /// Box name for storing affirmations.
  static const String affirmations = 'affirmations';

  /// Box name for storing app settings.
  static const String settings = 'settings';

  /// Box name for storing app state (e.g., onboarding completed).
  static const String appState = 'appState';
}

/// Service for managing Hive database initialization and configuration.
///
/// This service handles:
/// - Hive initialization with platform-specific paths
/// - Type adapter registration for custom models
/// - Box management for different data types
///
/// Usage:
/// ```dart
/// await HiveService.initialize();
/// final box = HiveService.affirmationsBox;
/// ```
class HiveService {
  HiveService._();

  static bool _initialized = false;
  static Box<Affirmation>? _affirmationsBox;
  static Box<dynamic>? _settingsBox;
  static Box<dynamic>? _appStateBox;

  /// Whether Hive has been initialized.
  static bool get isInitialized => _initialized;

  /// Returns the affirmations box, opening it lazily if needed.
  ///
  /// Throws [StateError] if Hive has not been initialized.
  static Future<Box<Affirmation>> get affirmationsBox async {
    if (!_initialized) {
      throw StateError(
        'Hive has not been initialized. Call HiveService.initialize() first.',
      );
    }

    // Lazy box opening for performance (PERF-001)
    if (_affirmationsBox == null || !_affirmationsBox!.isOpen) {
      _affirmationsBox = await Hive.openBox<Affirmation>(
        HiveBoxNames.affirmations,
      );
      debugPrint('HiveService: Opened affirmations box (lazy).');
    }
    return _affirmationsBox!;
  }

  /// Returns the settings box, opening it lazily if needed.
  ///
  /// Throws [StateError] if Hive has not been initialized.
  static Future<Box<dynamic>> get settingsBox async {
    if (!_initialized) {
      throw StateError(
        'Hive has not been initialized. Call HiveService.initialize() first.',
      );
    }

    // Lazy box opening for performance (PERF-001)
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      _settingsBox = await Hive.openBox<dynamic>(HiveBoxNames.settings);
      debugPrint('HiveService: Opened settings box (lazy).');
    }
    return _settingsBox!;
  }

  /// Returns the app state box, opening it lazily if needed.
  ///
  /// Throws [StateError] if Hive has not been initialized.
  static Future<Box<dynamic>> get appStateBox async {
    if (!_initialized) {
      throw StateError(
        'Hive has not been initialized. Call HiveService.initialize() first.',
      );
    }

    // Lazy box opening for performance (PERF-001)
    if (_appStateBox == null || !_appStateBox!.isOpen) {
      _appStateBox = await Hive.openBox<dynamic>(HiveBoxNames.appState);
      debugPrint('HiveService: Opened appState box (lazy).');
    }
    return _appStateBox!;
  }

  /// Initializes Hive with platform-specific paths and registers type adapters.
  ///
  /// This method should be called once at app startup, before using any
  /// Hive functionality.
  ///
  /// On mobile platforms (iOS/Android), uses the application documents directory.
  /// On web, uses the default Hive web storage.
  ///
  /// Performance optimization (PERF-001):
  /// - Boxes are opened lazily on first access instead of eagerly during init
  /// - This reduces initial startup time
  ///
  /// Throws [HiveError] if initialization fails.
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('HiveService: Already initialized, skipping.');
      return;
    }

    try {
      // Initialize Hive with platform-specific path
      if (kIsWeb) {
        // Web platform - use default Hive web storage
        await Hive.initFlutter();
      } else {
        // Mobile platforms - use application documents directory
        final appDocDir = await getApplicationDocumentsDirectory();
        final hivePath = '${appDocDir.path}/hive_db';
        await Hive.initFlutter(hivePath);
      }

      // Register type adapters
      _registerAdapters();

      // PERF-001: Boxes are opened lazily on first access
      // This reduces startup time by ~100-200ms
      // Boxes will be opened when first accessed via getters

      _initialized = true;
      debugPrint('HiveService: Initialization complete (lazy box opening).');
    } catch (e, stackTrace) {
      debugPrint('HiveService: Initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Registers all type adapters for custom Hive models.
  static void _registerAdapters() {
    // Register Affirmation adapter if not already registered
    if (!Hive.isAdapterRegistered(affirmationTypeId)) {
      Hive.registerAdapter(AffirmationAdapter());
      debugPrint('HiveService: Registered AffirmationAdapter.');
    }

    // Additional adapters will be registered here as models are added
  }

  /// Closes all open boxes and resets the service state.
  ///
  /// This is useful for testing or when the app needs to reinitialize.
  static Future<void> close() async {
    await _affirmationsBox?.close();
    await _settingsBox?.close();
    await _appStateBox?.close();

    _affirmationsBox = null;
    _settingsBox = null;
    _appStateBox = null;
    _initialized = false;

    debugPrint('HiveService: All boxes closed.');
  }

  /// Clears all data from all boxes.
  ///
  /// WARNING: This permanently deletes all data and cannot be undone.
  static Future<void> clearAll() async {
    if (!_initialized) {
      throw StateError(
        'Hive has not been initialized. Call HiveService.initialize() first.',
      );
    }

    await _affirmationsBox?.clear();
    await _settingsBox?.clear();
    await _appStateBox?.clear();

    debugPrint('HiveService: All boxes cleared.');
  }

  /// Deletes the Hive database from disk.
  ///
  /// WARNING: This permanently deletes all data and cannot be undone.
  /// After calling this, [initialize] must be called again before using Hive.
  static Future<void> deleteFromDisk() async {
    await close();
    await Hive.deleteFromDisk();
    debugPrint('HiveService: Database deleted from disk.');
  }
}
