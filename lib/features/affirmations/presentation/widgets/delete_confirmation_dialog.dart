/// Delete confirmation dialog widget.
///
/// Provides a confirmation dialog for affirmation deletion.
/// Based on REQUIREMENTS.md FR-003 and UI-016.
library;

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// A confirmation dialog for deleting an affirmation.
///
/// Shows a modal dialog asking the user to confirm deletion.
/// Provides Cancel and Delete buttons.
///
/// Example usage:
/// ```dart
/// final confirmed = await DeleteConfirmationDialog.show(
///   context: context,
///   affirmationText: 'I am confident',
/// );
/// if (confirmed) {
///   // Proceed with deletion
/// }
/// ```
class DeleteConfirmationDialog extends StatelessWidget {
  /// Creates a DeleteConfirmationDialog.
  const DeleteConfirmationDialog({
    super.key,
    required this.affirmationText,
  });

  /// A preview of the affirmation text to be deleted.
  final String affirmationText;

  /// Shows the delete confirmation dialog.
  ///
  /// Returns `true` if the user confirmed deletion, `false` otherwise.
  static Future<bool> show({
    required BuildContext context,
    required String affirmationText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => DeleteConfirmationDialog(
        affirmationText: affirmationText,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Truncate text for preview
    final previewText = affirmationText.length > 50
        ? '${affirmationText.substring(0, 50)}...'
        : affirmationText;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: 'Delete Affirmation Dialog',
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
        ),
        title: Semantics(
          header: true,
          label: 'Warning: Delete Affirmation',
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    'Delete Affirmation',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      content: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this affirmation?',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Semantics(
              label: 'Affirmation to be deleted: $previewText',
              readOnly: true,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.stone.withValues(alpha: 0.2)
                      : AppColors.mistGray,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSmall),
                ),
                child: ExcludeSemantics(
                  child: Text(
                    '"$previewText"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.softWhite : AppColors.stone,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Semantics(
              label: 'Warning: This action cannot be undone',
              child: Text(
                'This action cannot be undone.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Cancel button
        Semantics(
          button: true,
          enabled: true,
          label: 'Cancel',
          hint: 'Keep the affirmation and close this dialog',
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AppDimensions.minTouchTarget,
                AppDimensions.minTouchTarget,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.softWhite : AppColors.stone,
              ),
            ),
          ),
        ),
        // Delete button
        Semantics(
          button: true,
          enabled: true,
          label: 'Delete',
          hint: 'Permanently delete this affirmation',
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(
                AppDimensions.minTouchTarget,
                AppDimensions.minTouchTarget,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
            ),
            child: const Text('Delete'),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.only(
        left: AppDimensions.spacingM,
        right: AppDimensions.spacingM,
        bottom: AppDimensions.spacingM,
      ),
      ),
    );
  }
}
