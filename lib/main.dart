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
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await HiveService.initialize();

  // Initialize widget service for home screen widget (WIDGET-001)
  final widgetService = WidgetService();
  await widgetService.initialize();

  // Create widget data sync for WIDGET-009
  final widgetDataSync = WidgetDataSync(widgetService: widgetService);

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

  // Load initial data
  await Future.wait([
    affirmationProvider.loadAffirmations(),
    settingsProvider.loadSettings(),
  ]);

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
      child: const MyselfApp(),
    ),
  );
}
