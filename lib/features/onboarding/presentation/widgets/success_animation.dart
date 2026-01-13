/// Success animation widget.
///
/// Displayed after creating the first affirmation.
/// Based on REQUIREMENTS.md Section 8.1.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Success animation widget.
///
/// Shows a celebratory animation when the user
/// successfully creates their first affirmation.
///
/// Features:
/// - Animated check mark with scale and fade effects
/// - Celebration message
/// - Smooth transitions
/// - Auto-completion callback
class SuccessAnimation extends StatefulWidget {
  /// Creates a SuccessAnimation widget.
  const SuccessAnimation({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  /// Callback when the animation completes.
  final VoidCallback? onComplete;

  /// Duration to show the animation before calling onComplete.
  final Duration duration;

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation> {
  @override
  void initState() {
    super.initState();
    // Auto-complete after duration
    if (widget.onComplete != null) {
      Future.delayed(widget.duration, () {
        if (mounted) {
          widget.onComplete!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon with animations
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: primaryColor,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),

            const SizedBox(height: AppDimensions.spacingXl),

            // Success title
            Text(
              l10n.congratulations,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: primaryColor,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 300.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: AppDimensions.spacingM),

            // Success message
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXl,
              ),
              child: Text(
                '${l10n.firstAffirmationCreated}!\n${l10n.widgetSetupDescription}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms)
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 500.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Sparkle effects around the icon
            _buildSparkles(theme),
          ],
        ),
      ),
    );
  }

  /// Builds decorative sparkle elements.
  Widget _buildSparkles(ThemeData theme) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          // Top left sparkle
          Positioned(
            top: 20,
            left: 20,
            child: _buildSparkle(theme, 0.ms),
          ),
          // Top right sparkle
          Positioned(
            top: 30,
            right: 30,
            child: _buildSparkle(theme, 200.ms),
          ),
          // Bottom left sparkle
          Positioned(
            bottom: 40,
            left: 40,
            child: _buildSparkle(theme, 400.ms),
          ),
          // Bottom right sparkle
          Positioned(
            bottom: 25,
            right: 20,
            child: _buildSparkle(theme, 100.ms),
          ),
        ],
      ),
    );
  }

  /// Builds a single sparkle element with animation.
  Widget _buildSparkle(ThemeData theme, Duration delay) {
    return Icon(
      Icons.star,
      size: 16,
      color: theme.colorScheme.primary.withValues(alpha: 0.6),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .fadeIn(delay: delay, duration: 800.ms)
        .then()
        .fadeOut(duration: 800.ms);
  }
}
