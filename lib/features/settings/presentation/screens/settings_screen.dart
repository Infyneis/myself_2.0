/// Settings screen.
///
/// Screen for managing application settings.
/// Based on REQUIREMENTS.md FR-022 through FR-026.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../generated/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: l10n.settings,
          header: true,
          child: Text(l10n.settings),
        ),
        centerTitle: false,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ResponsiveLayout.constrainContentWidth(
            context: context,
            child: ListView(
            padding: ResponsiveLayout.getAdaptivePadding(context),
            children: [
              // Theme Section
              _buildSectionHeader(context, l10n.appearance),
              const SizedBox(height: AppDimensions.spacingS),
              _buildThemeSelector(context, settingsProvider),
              const SizedBox(height: AppDimensions.spacingS),
              _buildFontSizeCard(context, settingsProvider),
              const SizedBox(height: AppDimensions.spacingL),

              // Widget Settings Section
              _buildSectionHeader(context, l10n.widgetSettings),
              const SizedBox(height: AppDimensions.spacingS),
              _buildRefreshModeCard(context, settingsProvider),
              const SizedBox(height: AppDimensions.spacingS),
              _buildWidgetRotationCard(context, settingsProvider),
              const SizedBox(height: AppDimensions.spacingL),

              // Preferences Section
              _buildSectionHeader(context, l10n.preferences),
              const SizedBox(height: AppDimensions.spacingS),
              _buildLanguageCard(context, settingsProvider),
            ],
          ),
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.theme,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.chooseTheme,
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
              l10n.themeLight,
              l10n.themeLightDescription,
              Icons.light_mode,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildThemeOption(
              context,
              settingsProvider,
              settings_model.ThemeMode.dark,
              l10n.themeDark,
              l10n.themeDarkDescription,
              Icons.dark_mode,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildThemeOption(
              context,
              settingsProvider,
              settings_model.ThemeMode.system,
              l10n.themeSystem,
              l10n.themeSystemDescription,
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.refreshMode,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.refreshModeDescription,
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
              l10n.refreshModeUnlock,
              l10n.refreshModeUnlockDescription,
              Icons.lock_open,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildRefreshOption(
              context,
              settingsProvider,
              settings_model.RefreshMode.hourly,
              l10n.refreshModeHourly,
              l10n.refreshModeHourlyDescription,
              Icons.schedule,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildRefreshOption(
              context,
              settingsProvider,
              settings_model.RefreshMode.daily,
              l10n.refreshModeDaily,
              l10n.refreshModeDailyDescription,
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.languageDescription,
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
              l10n.languageFrench,
              l10n.languageFrench,
              Icons.language,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildLanguageOption(
              context,
              settingsProvider,
              'en',
              l10n.languageEnglish,
              l10n.languageEnglish,
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.fontSize,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.fontSizeDescription,
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Semantics(
          toggled: settingsProvider.widgetRotationEnabled,
          label: l10n.widgetRotation,
          hint: l10n.widgetRotationDescription,
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
                        l10n.widgetRotation,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        l10n.widgetRotationDescription,
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
                label: settingsProvider.widgetRotationEnabled ? l10n.enabled : l10n.disabled,
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
