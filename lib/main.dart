/// Myself 2.0 - Personal Affirmation App
///
/// Transform through repetition and intention — see who you want to become,
/// become who you see.
///
/// This is the main entry point for the application.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/storage/hive_service.dart';
import 'core/utils/performance_monitor.dart';
import 'core/utils/memory_optimizer.dart';
import 'features/affirmations/data/repositories/affirmation_repository.dart';
import 'features/affirmations/data/repositories/hive_affirmation_repository.dart';
import 'features/affirmations/domain/usecases/get_random_affirmation.dart';
import 'features/affirmations/presentation/providers/affirmation_provider.dart';
import 'features/settings/data/hive_settings_repository.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'widgets/native_widget/widget_service.dart';
import 'widgets/native_widget/widget_data_sync.dart';

/// Main entry point for Myself 2.0.
///
/// Performance optimization (PERF-001):
/// - Critical services initialized synchronously/in parallel
/// - Non-critical operations deferred until after first frame
/// - Target: Cold start < 2 seconds
///
/// Memory optimization (PERF-003):
/// - Image cache limited to 50 images / 10MB
/// - Lazy box loading for Hive
/// - Memory-efficient list builders
/// - Target: Memory footprint < 50MB
void main() async {
  // Start performance monitoring for PERF-001
  final perfMonitor = PerformanceMonitor.start();

  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  perfMonitor.logCheckpoint('Flutter binding initialized');

  // PERF-003: Configure memory-efficient image cache
  MemoryOptimizer.configureImageCache();
  perfMonitor.logCheckpoint('Memory optimizer configured');

  // Initialize Hive for local storage (critical - must complete before app runs)
  await HiveService.initialize();
  perfMonitor.logCheckpoint('Hive initialized (lazy box opening)');

  // Create widget service (lazy initialization - actual setup happens on demand)
  final widgetService = WidgetService();

  // Create widget data sync for WIDGET-009
  final widgetDataSync = WidgetDataSync(widgetService: widgetService);
  perfMonitor.logCheckpoint('Services created');

  // Create repositories
  final affirmationRepository = HiveAffirmationRepository();
  final settingsRepository = HiveSettingsRepository();

  // Create use cases
  final getRandomAffirmation = GetRandomAffirmation(
    repository: affirmationRepository,
  );

  // Create providers
  final affirmationProvider = AffirmationProvider(
    repository: affirmationRepository,
    getRandomAffirmationUseCase: getRandomAffirmation,
    widgetDataSync: widgetDataSync,
  );

  final settingsProvider = SettingsProvider(
    repository: settingsRepository,
    widgetDataSync: widgetDataSync,
  );
  perfMonitor.logCheckpoint('Providers created');

  // Load only critical settings synchronously (theme mode, onboarding status)
  // This is optimized to load minimal data needed for first frame
  await settingsProvider.loadSettings();
  perfMonitor.logCheckpoint('Settings loaded');

  // Run the app immediately - don't wait for affirmations to load
  runApp(
    MultiProvider(
      providers: [
        // Provide repositories for potential injection elsewhere
        Provider<AffirmationRepository>.value(value: affirmationRepository),
        Provider<SettingsRepository>.value(value: settingsRepository),

        // Provide widget service for home screen widget
        Provider<WidgetService>.value(value: widgetService),

        // Provide the main state management providers
        ChangeNotifierProvider<AffirmationProvider>.value(
          value: affirmationProvider,
        ),
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
        ),
      ],
      child: MyselfApp(
        // Pass initialization callbacks for deferred operations
        onPostFrameCallback: () async {
          // Defer non-critical operations until after first frame
          // This ensures the UI appears as quickly as possible
          await _initializeNonCriticalServices(
            widgetService: widgetService,
            affirmationProvider: affirmationProvider,
            perfMonitor: perfMonitor,
          );
        },
      ),
    ),
  );

  perfMonitor.logCheckpoint('App running (first frame pending)');
}

/// Initializes non-critical services after the first frame is rendered.
///
/// This function is called after the first frame to ensure the UI
/// appears as quickly as possible. Non-critical operations include:
/// - Widget service initialization (only needed when widget is used)
/// - Loading affirmations (shown with loading state initially)
Future<void> _initializeNonCriticalServices({
  required WidgetService widgetService,
  required AffirmationProvider affirmationProvider,
  required PerformanceMonitor perfMonitor,
}) async {
  try {
    perfMonitor.logCheckpoint('First frame rendered - starting deferred init');

    // Run non-critical initialization in parallel
    await Future.wait([
      // Initialize widget service (WIDGET-001) - lazy initialization
      widgetService.initialize(),

      // Load affirmations - UI shows loading state until ready
      affirmationProvider.loadAffirmations(),
    ]);

    perfMonitor.logCheckpoint('Deferred initialization complete');
    perfMonitor.logSummary();
  } catch (e) {
    // Log errors but don't crash - app can still function
    // ignore: avoid_print
    print('Warning: Non-critical initialization failed: $e');
    perfMonitor.logSummary();
  }
}
