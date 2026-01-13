/// Main application widget for Myself 2.0.
///
/// Configures the application with theme, routing, and providers.
library;

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/affirmations/presentation/screens/home_screen.dart';

/// Main application widget.
///
/// Provides:
/// - Theme configuration (light/dark/system)
/// - Localization setup
/// - Provider configuration
/// - Navigation routing
///
/// Note: Full provider setup will be completed in INFRA-004.
/// Localization will be completed in L10N-001.
class MyselfApp extends StatelessWidget {
  /// Creates the main application widget.
  const MyselfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myself 2.0',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Home screen
      home: const HomeScreen(),
    );
  }
}
