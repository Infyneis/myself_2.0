/// Welcome screen for first-time users.
///
/// Initial screen in the onboarding flow.
/// Based on REQUIREMENTS.md Section 8.1.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/dimensions.dart';

/// Welcome screen widget.
///
/// Displays:
/// - Zen-inspired illustration
/// - Brief app explanation
/// - "Get Started" action
///
/// Features:
/// - Smooth fade-in animations
/// - Clean, minimal design
/// - Centered content layout
/// - Accessible with proper touch targets
class WelcomeScreen extends StatelessWidget {
  /// Creates a WelcomeScreen widget.
  const WelcomeScreen({super.key, this.onGetStarted});

  /// Callback when "Get Started" button is pressed.
  final VoidCallback? onGetStarted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
            vertical: AppDimensions.spacingXl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Zen illustration
              _buildZenIllustration(context, isDarkMode)
                  .animate()
                  .fadeIn(
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  )
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // Welcome title
              Text(
                'Welcome to\nMyself 2.0',
                style: theme.textTheme.displayLarge?.copyWith(
                  height: 1.2,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(
                    delay: 200.ms,
                    duration: 500.ms,
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 200.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: AppDimensions.spacingL),

              // App description
              Text(
                'Your personal sanctuary for daily affirmations.\n\n'
                'Create meaningful affirmations, see them on your home screen widget, '
                'and cultivate a mindful practice of self-compassion.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(
                    delay: 400.ms,
                    duration: 500.ms,
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 400.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // Get Started button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onGetStarted,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusSmall,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                    delay: 600.ms,
                    duration: 500.ms,
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 600.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              const Spacer(),

              // Feature highlights
              _buildFeatureHighlights(context)
                  .animate()
                  .fadeIn(
                    delay: 800.ms,
                    duration: 500.ms,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the zen illustration.
  ///
  /// A simple, elegant visual representation using circles and shapes
  /// to evoke calm and mindfulness.
  Widget _buildZenIllustration(BuildContext context, bool isDarkMode) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle - representing wholeness
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.1),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),

          // Middle circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.15),
            ),
          ),

          // Inner circle - zen center
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.3),
            ),
          ),

          // Central lotus or meditation symbol
          Icon(
            Icons.self_improvement_rounded,
            size: 48,
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  /// Builds feature highlights section.
  Widget _buildFeatureHighlights(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureItem(
          context,
          icon: Icons.create_rounded,
          label: 'Create',
        ),
        _buildFeatureItem(
          context,
          icon: Icons.widgets_rounded,
          label: 'Widget',
        ),
        _buildFeatureItem(
          context,
          icon: Icons.spa_rounded,
          label: 'Mindful',
        ),
      ],
    );
  }

  /// Builds a single feature highlight item.
  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
          child: Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
