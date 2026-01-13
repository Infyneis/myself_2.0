/// Main application widget for Myself 2.0.
///
/// Configures the application with theme, routing, and providers.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/affirmations/presentation/screens/home_screen.dart';
import 'features/settings/data/settings_model.dart' as settings_model;
import 'features/settings/presentation/providers/settings_provider.dart';

/// Main application widget.
///
/// Provides:
/// - Theme configuration (light/dark/system)
/// - Localization setup
/// - Provider configuration
/// - Navigation routing
class MyselfApp extends StatelessWidget {
  /// Creates the main application widget.
  const MyselfApp({super.key});

  /// Converts settings ThemeMode to Flutter ThemeMode.
  ThemeMode _convertThemeMode(settings_model.ThemeMode settingsThemeMode) {
    switch (settingsThemeMode) {
      case settings_model.ThemeMode.light:
        return ThemeMode.light;
      case settings_model.ThemeMode.dark:
        return ThemeMode.dark;
      case settings_model.ThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'Myself 2.0',
          debugShowCheckedModeBanner: false,

          // Theme configuration using SettingsProvider
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _convertThemeMode(settingsProvider.themeMode),

          // Home screen
          home: const HomeScreen(),
        );
      },
    );
  }
}
