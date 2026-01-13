/// Empty affirmations state widget.
///
/// Displays a friendly empty state when no affirmations exist.
/// Based on REQUIREMENTS.md FR-004 empty state handling.
library;

import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// Widget displayed when the user has no saved affirmations.
///
/// Shows:
/// - A calming icon
/// - Encouraging message to create first affirmation
/// - Call-to-action button to add an affirmation
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
            // Decorative icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.softSage.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.self_improvement_outlined,
                size: 64,
                color: isDarkMode
                    ? AppColors.softSage
                    : AppColors.softSage.withValues(alpha: 0.8),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Title
            Text(
              'No Affirmations Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

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
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Call-to-action button
            FilledButton.icon(
              onPressed: onAddAffirmation,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Affirmation'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(240, AppDimensions.minTouchTarget),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingL,
                  vertical: AppDimensions.spacingM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
