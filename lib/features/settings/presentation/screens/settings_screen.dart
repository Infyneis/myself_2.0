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
/// - Refresh interval selection - FR-023
/// - Language selection - FR-024
/// - Font size adjustment - FR-026
/// - Widget rotation toggle - FR-022
///
/// Implements UI-011.
class SettingsScreen extends StatelessWidget {
  /// Creates a SettingsScreen widget.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'Settings',
          header: true,
          child: const Text('Settings'),
        ),
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
              const SizedBox(height: AppDimensions.spacingS),
              _buildFontSizeCard(context, settingsProvider),
              const SizedBox(height: AppDimensions.spacingL),

              // Widget Settings Section
              _buildSectionHeader(context, 'Widget Settings'),
              const SizedBox(height: AppDimensions.spacingS),
              _buildRefreshModeCard(context, settingsProvider),
              const SizedBox(height: AppDimensions.spacingS),
              _buildWidgetRotationCard(context, settingsProvider),
              const SizedBox(height: AppDimensions.spacingL),

              // Preferences Section
              _buildSectionHeader(context, 'Preferences'),
              const SizedBox(height: AppDimensions.spacingS),
              _buildLanguageCard(context, settingsProvider),
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
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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

    return Semantics(
      button: true,
      enabled: true,
      selected: isSelected,
      label: '$label theme',
      hint: description,
      onTap: () async {
        await settingsProvider.setThemeMode(themeMode);
      },
      child: InkWell(
        onTap: () async {
          await settingsProvider.setThemeMode(themeMode);
        },
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        child: ExcludeSemantics(
          child: Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTouchTarget,
        ),
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
        ),
      ),
    );
  }

  /// Builds the refresh mode selector card.
  Widget _buildRefreshModeCard(
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
              'Refresh Interval',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'How often should the widget affirmation update?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            _buildRefreshOption(
              context,
              settingsProvider,
              settings_model.RefreshMode.onUnlock,
              'Every Unlock',
              'Show a new affirmation each time you unlock your phone',
              Icons.lock_open,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildRefreshOption(
              context,
              settingsProvider,
              settings_model.RefreshMode.hourly,
              'Hourly',
              'Update every hour',
              Icons.schedule,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildRefreshOption(
              context,
              settingsProvider,
              settings_model.RefreshMode.daily,
              'Daily',
              'Update once per day',
              Icons.today,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single refresh mode option.
  Widget _buildRefreshOption(
    BuildContext context,
    SettingsProvider settingsProvider,
    settings_model.RefreshMode refreshMode,
    String label,
    String description,
    IconData icon,
  ) {
    final isSelected = settingsProvider.refreshMode == refreshMode;

    return Semantics(
      button: true,
      enabled: true,
      selected: isSelected,
      label: '$label refresh mode',
      hint: description,
      onTap: () async {
        await settingsProvider.setRefreshMode(refreshMode);
      },
      child: InkWell(
        onTap: () async {
          await settingsProvider.setRefreshMode(refreshMode);
        },
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        child: ExcludeSemantics(
          child: Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTouchTarget,
        ),
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
        ),
      ),
    );
  }

  /// Builds the language selector card.
  Widget _buildLanguageCard(
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
              'Language',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'Choose your preferred language',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            _buildLanguageOption(
              context,
              settingsProvider,
              'fr',
              'Français',
              'French',
              Icons.language,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildLanguageOption(
              context,
              settingsProvider,
              'en',
              'English',
              'English',
              Icons.language,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single language option.
  Widget _buildLanguageOption(
    BuildContext context,
    SettingsProvider settingsProvider,
    String languageCode,
    String label,
    String description,
    IconData icon,
  ) {
    final isSelected = settingsProvider.language == languageCode;

    return Semantics(
      button: true,
      enabled: true,
      selected: isSelected,
      label: '$label language',
      hint: description,
      onTap: () async {
        await settingsProvider.setLanguage(languageCode);
      },
      child: InkWell(
        onTap: () async {
          await settingsProvider.setLanguage(languageCode);
        },
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        child: ExcludeSemantics(
          child: Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTouchTarget,
        ),
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
        ),
      ),
    );
  }

  /// Builds the font size adjustment card.
  Widget _buildFontSizeCard(
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
              'Font Size',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'Adjust text size for better readability',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            // Preview text
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSmall),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
                child: Column(
                  children: [
                    Text(
                      'Sample Affirmation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      'I am becoming the best version of myself',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            // Slider
            Semantics(
              slider: true,
              label: 'Font size',
              value: '${(settingsProvider.fontSizeMultiplier * 100).round()} percent',
              hint: 'Adjust font size from 80% to 140%',
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.text_fields,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: settingsProvider.fontSizeMultiplier,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label:
                          '${(settingsProvider.fontSizeMultiplier * 100).round()}%',
                      onChanged: (value) async {
                        await settingsProvider.setFontSizeMultiplier(value);
                      },
                    ),
                  ),
                  ExcludeSemantics(
                    child: Icon(
                      Icons.text_fields,
                      size: 24,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                '${(settingsProvider.fontSizeMultiplier * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the widget rotation toggle card.
  Widget _buildWidgetRotationCard(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Semantics(
          toggled: settingsProvider.widgetRotationEnabled,
          label: 'Widget Rotation',
          hint: 'Automatically rotate affirmations in widget',
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.refresh,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Widget Rotation',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        'Automatically rotate affirmations in widget',
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
              ),
              Semantics(
                label: settingsProvider.widgetRotationEnabled ? 'On' : 'Off',
                child: Switch(
                  value: settingsProvider.widgetRotationEnabled,
                  onChanged: (value) async {
                    await settingsProvider.setWidgetRotationEnabled(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
