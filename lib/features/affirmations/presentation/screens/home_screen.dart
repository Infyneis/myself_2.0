/// Home screen displaying a random affirmation.
///
/// Main screen of the app showing zen animation with current affirmation.
/// Based on REQUIREMENTS.md FR-014, FR-015, FR-016.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/dimensions.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Myself 2.0'),
        centerTitle: true,
        actions: [
          // Navigation to affirmation list
          IconButton(
            icon: const Icon(Icons.list_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AffirmationListScreen(),
                ),
              );
            },
            tooltip: 'My Affirmations',
          ),
          // Navigation to settings
          IconButton(
            icon: const Icon(Icons.settings_rounded),
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
      body: Consumer<AffirmationProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while fetching data
          if (provider.isLoading && !provider.hasAffirmations) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error state if there's an error
          if (provider.error != null && !provider.hasAffirmations) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      provider.error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    ElevatedButton(
                      onPressed: () {
                        provider.loadAffirmations().then((_) {
                          if (provider.hasAffirmations) {
                            provider.selectRandomAffirmation();
                          }
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
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
              'Loading affirmation...',
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main affirmation card with zen animation
            Card(
              elevation: AppDimensions.elevationSoft,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingXl),
                child: Column(
                  children: [
                    // Affirmation text with fade-in animation
                    Text(
                      currentAffirmation.text,
                      key: ValueKey(currentAffirmation.id),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    )
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
                        ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Helper text to guide user
            Text(
              'Your daily affirmation',
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
