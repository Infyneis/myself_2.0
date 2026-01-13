/// Empty affirmations state widget.
///
/// Displays a friendly empty state when no affirmations exist.
/// Based on REQUIREMENTS.md FR-004 empty state handling and UI-012.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Widget displayed when the user has no saved affirmations.
///
/// Shows:
/// - A calming illustration with zen elements
/// - Encouraging message to create first affirmation
/// - Call-to-action button to add an affirmation
/// - Subtle animations for a delightful user experience
class EmptyAffirmationsState extends StatelessWidget {
  /// Creates an EmptyAffirmationsState widget.
  const EmptyAffirmationsState({
    super.key,
    required this.onAddAffirmation,
  });

  /// Callback when the add affirmation button is pressed.
  final VoidCallback onAddAffirmation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zen illustration with multiple elements
            _ZenIllustration(isDarkMode: isDarkMode)
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: AppDimensions.spacingXxl),

            // Title
            Text(
              'No Affirmations Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms),

            const SizedBox(height: AppDimensions.spacingM),

            // Subtitle with encouraging message
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingL,
              ),
              child: Text(
                'Start your journey of self-affirmation.\nCreate your first positive thought to begin.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDarkMode ? AppColors.stone : AppColors.stone,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms),

            const SizedBox(height: AppDimensions.spacingXxl),

            // Call-to-action button
            FilledButton.icon(
              onPressed: onAddAffirmation,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Your First Affirmation'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(280, AppDimensions.minTouchTarget + 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXl,
                  vertical: AppDimensions.spacingM + 2,
                ),
                elevation: 2,
                shadowColor: AppColors.softSage.withValues(alpha: 0.3),
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms)
                .shimmer(
                  delay: 1500.ms,
                  duration: 1500.ms,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
          ],
        ),
      ),
    );
  }
}

/// Custom zen-themed illustration for the empty state.
///
/// Creates a layered illustration with:
/// - Background circles for depth
/// - Central lotus/meditation icon
/// - Decorative sparkle elements
class _ZenIllustration extends StatelessWidget {
  const _ZenIllustration({required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle - subtle background
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.softSage.withValues(alpha: 0.08),
                  AppColors.softSage.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.1, 1.1),
                duration: 3000.ms,
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1.0, 1.0),
                duration: 3000.ms,
                curve: Curves.easeInOut,
              ),

          // Middle circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softSage.withValues(alpha: 0.12),
            ),
          ),

          // Inner circle - main background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softSage.withValues(alpha: 0.18),
              border: Border.all(
                color: AppColors.softSage.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
          ),

          // Central icon - meditation/lotus pose
          Icon(
            Icons.self_improvement_outlined,
            size: 72,
            color: isDarkMode
                ? AppColors.softSage.withValues(alpha: 0.9)
                : AppColors.softSage,
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                delay: 2000.ms,
                duration: 2000.ms,
                color: Colors.white.withValues(alpha: 0.2),
              ),

          // Decorative sparkle elements
          Positioned(
            top: 20,
            right: 30,
            child: _SparkleIcon(isDarkMode: isDarkMode, size: 16),
          ),
          Positioned(
            top: 50,
            left: 25,
            child: _SparkleIcon(isDarkMode: isDarkMode, size: 12),
          ),
          Positioned(
            bottom: 35,
            right: 25,
            child: _SparkleIcon(isDarkMode: isDarkMode, size: 14),
          ),
          Positioned(
            bottom: 25,
            left: 35,
            child: _SparkleIcon(isDarkMode: isDarkMode, size: 10),
          ),
        ],
      ),
    );
  }
}

/// Small sparkle icon for decorative purposes.
class _SparkleIcon extends StatelessWidget {
  const _SparkleIcon({
    required this.isDarkMode,
    required this.size,
  });

  final bool isDarkMode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome,
      size: size,
      color: isDarkMode
          ? AppColors.softSage.withValues(alpha: 0.5)
          : AppColors.softSage.withValues(alpha: 0.4),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 1000.ms)
        .then(delay: 500.ms)
        .fadeOut(duration: 1000.ms)
        .then(delay: 500.ms);
  }
}
