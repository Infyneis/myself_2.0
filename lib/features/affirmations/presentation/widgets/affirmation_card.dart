/// Affirmation card widget.
///
/// Reusable card component for displaying an affirmation.
/// Based on REQUIREMENTS.md design requirements.
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/models/affirmation.dart';

/// A card widget displaying a single affirmation.
///
/// Styled according to the zen design philosophy:
/// - Rounded corners (16px) via [AppDimensions.borderRadiusDefault]
/// - Soft elevation (2.0) via theme's CardTheme
/// - Generous padding for breathing room
/// - Multi-line text display with proper wrapping
/// - Playfair Display font for elegant affirmation text
/// - Zen color palette for calm aesthetics
///
/// The card supports optional interactions:
/// - [onTap]: Called when the entire card is tapped
/// - [onEdit]: Displays an edit button when provided
/// - [onDelete]: Displays a delete button when provided
/// - [maxLines]: Limits displayed lines (null = unlimited)
///
/// Complete zen styling implementation for UI-009.
class AffirmationCard extends StatelessWidget {
  /// Creates an AffirmationCard widget.
  const AffirmationCard({
    super.key,
    required this.affirmation,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.maxLines,
  });

  /// The affirmation to display.
  final Affirmation affirmation;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when edit action is triggered.
  final VoidCallback? onEdit;

  /// Callback when delete action is triggered.
  final VoidCallback? onDelete;

  /// Maximum number of lines to display before truncating.
  /// If null, all lines will be displayed.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    // Zen colors based on theme brightness
    final cardColor = brightness == Brightness.light
        ? AppColors.cloudWhite
        : AppColors.deepNight;
    final textColor = brightness == Brightness.light
        ? AppColors.zenBlack
        : AppColors.softWhite;
    final accentColor = AppColors.softSage;
    final mutedColor = AppColors.stone;

    // Build semantic label for VoiceOver
    String semanticLabel = 'Affirmation: ${affirmation.text}';
    if (onEdit != null || onDelete != null) {
      semanticLabel += '. Swipe up or down for actions';
    }

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      enabled: true,
      customSemanticsActions: {
        if (onEdit != null)
          const CustomSemanticsAction(label: 'Edit'): () => onEdit!(),
        if (onDelete != null)
          const CustomSemanticsAction(label: 'Delete'): () => onDelete!(),
      },
      child: Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      elevation: AppDimensions.elevationSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
      ),
      color: cardColor,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
          splashColor: accentColor.withValues(alpha: 0.1),
          highlightColor: accentColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Affirmation text with Playfair Display for elegant display
              // Multi-line support with proper line breaks and wrapping
              // Soft wrap ensures text wraps naturally at word boundaries
              // Generous line height (1.5) for readability and calm aesthetics
              Text(
                affirmation.text,
                style: AppTextStyles.playfairDisplay(
                  fontSize: AppTextStyles.affirmationDisplaySize,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  height: 1.5,
                  letterSpacing: 0.25,
                ),
                softWrap: true,
                maxLines: maxLines, // null allows unlimited lines
                overflow:
                    maxLines != null ? TextOverflow.fade : TextOverflow.visible,
                textAlign: TextAlign.start,
              ),
              // Action buttons (edit/delete) with proper spacing and touch targets
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: AppDimensions.spacingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: mutedColor,
                        ),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: AppDimensions.minTouchTarget,
                          minHeight: AppDimensions.minTouchTarget,
                        ),
                        splashRadius: AppDimensions.spacingL,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: mutedColor,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: AppDimensions.minTouchTarget,
                          minHeight: AppDimensions.minTouchTarget,
                        ),
                        splashRadius: AppDimensions.spacingL,
                      ),
                  ],
                ),
              ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
