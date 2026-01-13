/// Widget setup instructions.
///
/// Guides users on how to add the home screen widget.
/// Based on REQUIREMENTS.md.
library;

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/dimensions.dart';

/// Widget setup instructions screen.
///
/// Provides platform-specific instructions for
/// adding the home screen widget.
///
/// Features:
/// - Platform-specific instructions (iOS/Android)
/// - Step-by-step guide with icons
/// - Skip option for users who want to do this later
/// - "Done" button to complete onboarding
class WidgetSetupInstructions extends StatelessWidget {
  /// Creates a WidgetSetupInstructions widget.
  const WidgetSetupInstructions({
    super.key,
    this.onDone,
    this.onSkip,
  });

  /// Callback when user completes the instructions.
  final VoidCallback? onDone;

  /// Callback when user chooses to skip widget setup.
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = Platform.isIOS;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
            vertical: AppDimensions.spacingXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip button in top-right
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip for now',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Title
              Text(
                'Add Your Widget',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: AppDimensions.spacingM),

              // Subtitle
              Text(
                'See your affirmations every time you unlock your phone',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 200.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // Platform-specific instructions
              Expanded(
                child: SingleChildScrollView(
                  child: isIOS
                      ? _buildIOSInstructions(theme)
                      : _buildAndroidInstructions(theme),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Done button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onDone,
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
                        'I\'ve Added It',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      const Icon(Icons.check_rounded, size: 20),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 600.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds iOS-specific widget setup instructions.
  Widget _buildIOSInstructions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInstructionStep(
          theme: theme,
          stepNumber: 1,
          icon: Icons.touch_app_rounded,
          title: 'Long press on your home screen',
          description: 'Press and hold any empty area on your home screen',
          delay: 400.ms,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        _buildInstructionStep(
          theme: theme,
          stepNumber: 2,
          icon: Icons.add_circle_outline_rounded,
          title: 'Tap the + button',
          description: 'Look for the plus icon in the top-left corner',
          delay: 500.ms,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        _buildInstructionStep(
          theme: theme,
          stepNumber: 3,
          icon: Icons.search_rounded,
          title: 'Search for "Myself 2.0"',
          description: 'Find our app in the widget gallery',
          delay: 600.ms,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        _buildInstructionStep(
          theme: theme,
          stepNumber: 4,
          icon: Icons.widgets_rounded,
          title: 'Choose your widget size',
          description: 'Select small, medium, or large',
          delay: 700.ms,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        _buildInstructionStep(
          theme: theme,
          stepNumber: 5,
          icon: Icons.check_circle_outline_rounded,
          title: 'Add Widget',
          description: 'Tap "Add Widget" and you\'re done!',
          delay: 800.ms,
        ),
      ],
    );
  }

  /// Builds Android-specific widget setup instructions.
  Widget _buildAndroidInstructions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInstructionStep(
          theme: theme,
          stepNumber: 1,
          icon: Icons.touch_app_rounded,
          title: 'Long press on your home screen',
          description: 'Press and hold any empty area on your home screen',
          delay: 400.ms,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        _buildInstructionStep(
          theme: theme,
          stepNumber: 2,
          icon: Icons.widgets_rounded,
          title: 'Tap "Widgets"',
          description: 'Select the widgets option from the menu',
          delay: 500.ms,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        _buildInstructionStep(
          theme: theme,
          stepNumber: 3,
          icon: Icons.search_rounded,
          title: 'Find "Myself 2.0"',
          description: 'Scroll or search for our app',
          delay: 600.ms,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        _buildInstructionStep(
          theme: theme,
          stepNumber: 4,
          icon: Icons.drag_indicator_rounded,
          title: 'Drag the widget',
          description: 'Hold and drag the widget to your home screen',
          delay: 700.ms,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        _buildInstructionStep(
          theme: theme,
          stepNumber: 5,
          icon: Icons.check_circle_outline_rounded,
          title: 'Release to place',
          description: 'Drop it where you want and you\'re done!',
          delay: 800.ms,
        ),
      ],
    );
  }

  /// Builds a single instruction step.
  Widget _buildInstructionStep({
    required ThemeData theme,
    required int stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required Duration delay,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: delay, duration: 500.ms)
        .slideX(
          begin: 0.2,
          end: 0,
          delay: delay,
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }
}
