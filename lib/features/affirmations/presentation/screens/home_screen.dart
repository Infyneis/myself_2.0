/// Home screen displaying a random affirmation.
///
/// Main screen of the app showing zen animation with current affirmation.
/// Based on REQUIREMENTS.md FR-014, FR-015, FR-016.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/affirmation_provider.dart';
import '../widgets/empty_affirmations_state.dart';
import 'affirmation_edit_screen.dart';
import 'affirmation_list_screen.dart';

/// Home screen widget.
///
/// Displays:
/// - A random affirmation with zen animation
/// - Navigation to affirmation list and settings
/// - Empty state when no affirmations exist
///
/// Features:
/// - Fade-in animation for affirmations (300-500ms)
/// - Automatic random affirmation selection on load
/// - Clean, zen-inspired minimal UI
class HomeScreen extends StatefulWidget {
  /// Creates a HomeScreen widget.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load affirmations and select a random one when the screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AffirmationProvider>();
      provider.loadAffirmations().then((_) {
        // Select a random affirmation if any exist
        if (provider.hasAffirmations) {
          provider.selectRandomAffirmation();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: l10n.appTitle,
          header: true,
          child: Text(l10n.appTitle),
        ),
        centerTitle: true,
        actions: [
          // Navigation to affirmation list
          Semantics(
            button: true,
            enabled: true,
            label: l10n.myAffirmations,
            hint: l10n.myAffirmationsHint,
            child: IconButton(
              icon: const Icon(Icons.list_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AffirmationListScreen(),
                  ),
                );
              },
              tooltip: l10n.myAffirmations,
            ),
          ),
          // Navigation to settings
          Semantics(
            button: true,
            enabled: true,
            label: l10n.settings,
            hint: l10n.settingsHint,
            child: IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              tooltip: l10n.settings,
            ),
          ),
        ],
      ),
      body: Consumer<AffirmationProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while fetching data
          if (provider.isLoading && !provider.hasAffirmations) {
            return Center(
              child: Semantics(
                label: 'Loading affirmations',
                liveRegion: true,
                child: const CircularProgressIndicator(),
              ),
            );
          }

          // Show error state if there's an error
          if (provider.error != null && !provider.hasAffirmations) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        label: 'Error',
                        image: true,
                        child: Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Semantics(
                        header: true,
                        child: Text(
                          'Something went wrong',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        provider.error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      Semantics(
                        button: true,
                        enabled: true,
                        label: 'Retry',
                        hint: 'Tap to retry loading affirmations',
                        child: ElevatedButton(
                          onPressed: () {
                            provider.loadAffirmations().then((_) {
                              if (provider.hasAffirmations) {
                                provider.selectRandomAffirmation();
                              }
                            });
                          },
                          child: Text(l10n.tryAgain),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Show empty state if no affirmations exist
          if (!provider.hasAffirmations) {
            return EmptyAffirmationsState(
              onAddAffirmation: () => _navigateToAddAffirmation(context),
            );
          }

          // Show the current affirmation with zen animation
          return _buildAffirmationDisplay(context, provider);
        },
      ),
    );
  }

  /// Builds the main affirmation display with zen animation.
  Widget _buildAffirmationDisplay(
    BuildContext context,
    AffirmationProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currentAffirmation = provider.currentAffirmation;

    // If no current affirmation is selected yet, show a placeholder
    if (currentAffirmation == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              '${l10n.refresh}...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final breathingEnabled = settingsProvider.breathingAnimationEnabled;

        // Wrap the content with GestureDetector to handle tap and swipe gestures
        return Semantics(
          label: '${l10n.affirmationCard}: ${currentAffirmation.text}',
          hint: l10n.tapToRefresh,
          button: true,
          enabled: true,
          onTap: () => _showNextAffirmation(provider),
          child: GestureDetector(
            // Handle tap gesture to show next affirmation
            onTap: () => _showNextAffirmation(provider),
            // Handle horizontal swipe gestures (left or right) to show next affirmation
            onHorizontalDragEnd: (details) {
              // Only trigger if there's significant horizontal velocity
              if (details.primaryVelocity != null &&
                  details.primaryVelocity!.abs() > 100) {
                _showNextAffirmation(provider);
              }
            },
            child: ExcludeSemantics(
              child: Center(
                child: SingleChildScrollView(
                  padding: ResponsiveLayout.getAdaptivePadding(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  // Main affirmation card with zen animation
                  // Constrain width on tablets for better readability
                  ResponsiveLayout.constrainContentWidth(
                    context: context,
                    maxWidth: 600,
                    child: Card(
                    elevation: AppDimensions.elevationSoft,
                    child: Padding(
                      padding: ResponsiveLayout.getAdaptivePadding(context),
                      child: Column(
                        children: [
                          // Affirmation text with fade-in animation
                          _buildAnimatedAffirmation(
                            context,
                            currentAffirmation.text,
                            currentAffirmation.id,
                            breathingEnabled,
                          ),

                          SizedBox(
                            height: ResponsiveLayout.getAdaptiveSpacing(
                              context,
                              AppDimensions.spacingL,
                            ),
                          ),

                          // Refresh button to cycle through affirmations
                          _buildRefreshButton(context, provider),
                        ],
                      ),
                    ),
                  ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // Helper text to guide user
                  Text(
                    l10n.tapToRefresh,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                          letterSpacing: 1.2,
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(
                        delay: 200.ms,
                        duration: 400.ms,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows the next random affirmation with smooth transition.
  void _showNextAffirmation(AffirmationProvider provider) {
    provider.selectRandomAffirmation();
  }

  /// Builds the refresh button to manually cycle through affirmations.
  Widget _buildRefreshButton(
    BuildContext context,
    AffirmationProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      enabled: true,
      label: l10n.refreshAffirmation,
      hint: l10n.showNewAffirmation,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppDimensions.minTouchTarget,
          minHeight: AppDimensions.minTouchTarget,
        ),
        child: IconButton(
          onPressed: () => _showNextAffirmation(provider),
          icon: const Icon(Icons.refresh_rounded),
          tooltip: l10n.refresh,
          iconSize: 28,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.1),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(AppDimensions.spacingM),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: 300.ms,
          duration: 400.ms,
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          delay: 300.ms,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// Builds the animated affirmation text with optional breathing animation.
  Widget _buildAnimatedAffirmation(
    BuildContext context,
    String text,
    String id,
    bool breathingEnabled,
  ) {
    final textWidget = Text(
      text,
      key: ValueKey(id),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
      textAlign: TextAlign.center,
      softWrap: true,
    );

    // Start with fade-in and slide animation
    if (breathingEnabled) {
      // Add breathing animation with fade-in
      // Using a slow, gentle breathing rhythm (4 seconds per cycle)
      return textWidget
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .fadeIn(
            duration: AppDimensions.animationDurationSlow.ms,
            curve: Curves.easeInOut,
          )
          .slideY(
            begin: 0.1,
            end: 0,
            duration: AppDimensions.animationDurationSlow.ms,
            curve: Curves.easeOut,
          )
          .then(delay: 500.ms)
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.02, 1.02),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          );
    }

    // Without breathing animation, just fade-in and slide
    return textWidget
        .animate()
        .fadeIn(
          duration: AppDimensions.animationDurationSlow.ms,
          curve: Curves.easeInOut,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: AppDimensions.animationDurationSlow.ms,
          curve: Curves.easeOut,
        );
  }

  /// Navigates to the affirmation edit screen to add a new affirmation.
  void _navigateToAddAffirmation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AffirmationEditScreen(),
      ),
    );
  }
}
