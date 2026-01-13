/// Settings screen.
///
/// Screen for managing application settings.
/// Based on REQUIREMENTS.md FR-022 through FR-026.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/dimensions.dart';
import '../../data/settings_model.dart' as settings_model;
import '../providers/settings_provider.dart';

/// Settings screen widget.
///
/// Displays options for:
/// - Theme toggle (light/dark/system) - UI-002
/// - Refresh interval selection
/// - Language selection
/// - Font size adjustment
/// - Widget rotation toggle
///
/// Note: Full implementation will be completed in UI-011.
class SettingsScreen extends StatelessWidget {
  /// Creates a SettingsScreen widget.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            children: [
              // Theme Section
              _buildSectionHeader(context, 'Appearance'),
              const SizedBox(height: AppDimensions.spacingS),
              _buildThemeSelector(context, settingsProvider),
              const SizedBox(height: AppDimensions.spacingL),

              // Placeholder for other settings
              _buildSectionHeader(context, 'Widget Settings'),
              const SizedBox(height: AppDimensions.spacingS),
              _buildPlaceholderTile(
                context,
                'Refresh Mode',
                'Coming soon in UI-011',
              ),
              const SizedBox(height: AppDimensions.spacingL),

              _buildSectionHeader(context, 'Preferences'),
              const SizedBox(height: AppDimensions.spacingS),
              _buildPlaceholderTile(
                context,
                'Language',
                'Coming soon in UI-011',
              ),
              _buildPlaceholderTile(
                context,
                'Font Size',
                'Coming soon in UI-011',
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a section header.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  /// Builds the theme selector card.
  Widget _buildThemeSelector(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'Choose your preferred theme',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            _buildThemeOption(
              context,
              settingsProvider,
              settings_model.ThemeMode.light,
              'Light',
              'Bright and clear',
              Icons.light_mode,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildThemeOption(
              context,
              settingsProvider,
              settings_model.ThemeMode.dark,
              'Dark',
              'Easy on the eyes',
              Icons.dark_mode,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildThemeOption(
              context,
              settingsProvider,
              settings_model.ThemeMode.system,
              'System',
              'Matches your device',
              Icons.brightness_auto,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single theme option.
  Widget _buildThemeOption(
    BuildContext context,
    SettingsProvider settingsProvider,
    settings_model.ThemeMode themeMode,
    String label,
    String description,
    IconData icon,
  ) {
    final isSelected = settingsProvider.themeMode == themeMode;

    return InkWell(
      onTap: () async {
        await settingsProvider.setThemeMode(themeMode);
      },
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a placeholder settings tile.
  Widget _buildPlaceholderTile(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        enabled: false,
      ),
    );
  }
}
