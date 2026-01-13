/// Affirmation card widget.
///
/// Reusable card component for displaying an affirmation.
/// Based on REQUIREMENTS.md design requirements.
library;

import 'package:flutter/material.dart';
import '../../../../core/constants/dimensions.dart';
import '../../data/models/affirmation.dart';

/// A card widget displaying a single affirmation.
///
/// Styled according to the zen design philosophy:
/// - Rounded corners (16px)
/// - Soft elevation
/// - Comfortable padding
/// - Multi-line text display with proper wrapping
///
/// Note: Full styling will be completed in UI-009.
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
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Multi-line text display with proper line breaks
              // softWrap ensures text wraps naturally at word boundaries
              // overflow with fade gives visual hint when text is truncated
              Text(
                affirmation.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5, // Line height for better readability
                    ),
                softWrap: true,
                maxLines: maxLines, // null allows unlimited lines
                overflow:
                    maxLines != null ? TextOverflow.fade : TextOverflow.visible,
              ),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: AppDimensions.spacingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
