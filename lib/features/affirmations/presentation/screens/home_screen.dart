/// Home screen displaying a random affirmation.
///
/// Main screen of the app showing zen animation with current affirmation.
/// Based on REQUIREMENTS.md FR-014, FR-015, FR-016.
library;

import 'package:flutter/material.dart';

import '../../../settings/presentation/screens/settings_screen.dart';

/// Home screen widget.
///
/// Displays:
/// - A random affirmation with zen animation
/// - Swipe/tap to see another affirmation
/// - Navigation to affirmation list and settings
///
/// Note: Full implementation will be completed in UI-003.
class HomeScreen extends StatelessWidget {
  /// Creates a HomeScreen widget.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary implementation for testing theme switching (UI-002)
    // Full implementation will be completed in UI-003
    return Scaffold(
      appBar: AppBar(
        title: const Text('Myself 2.0'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Home Screen - Coming Soon',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'Tap the settings icon to test theme switching',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
