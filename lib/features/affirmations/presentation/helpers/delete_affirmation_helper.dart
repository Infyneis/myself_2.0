/// Delete affirmation helper functions.
///
/// Provides utility functions for deleting affirmations with confirmation.
/// Based on REQUIREMENTS.md FR-003.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/affirmation.dart';
import '../providers/affirmation_provider.dart';
import '../widgets/delete_confirmation_dialog.dart';

/// Helper class for affirmation deletion operations.
///
/// Combines the confirmation dialog with the actual deletion logic.
class DeleteAffirmationHelper {
  DeleteAffirmationHelper._();

  /// Deletes an affirmation with confirmation dialog.
  ///
  /// Shows a confirmation dialog to the user. If confirmed, proceeds with deletion.
  ///
  /// Parameters:
  /// - [context]: The BuildContext for showing the dialog and accessing providers.
  /// - [affirmation]: The affirmation to delete.
  /// - [onSuccess]: Optional callback called after successful deletion.
  /// - [onError]: Optional callback called if deletion fails.
  ///
  /// Returns `true` if the affirmation was deleted, `false` if cancelled or failed.
  ///
  /// Example:
  /// ```dart
  /// final deleted = await DeleteAffirmationHelper.deleteWithConfirmation(
  ///   context: context,
  ///   affirmation: myAffirmation,
  ///   onSuccess: () => ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Affirmation deleted')),
  ///   ),
  /// );
  /// ```
  static Future<bool> deleteWithConfirmation({
    required BuildContext context,
    required Affirmation affirmation,
    VoidCallback? onSuccess,
    void Function(String error)? onError,
  }) async {
    // Show confirmation dialog
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      affirmationText: affirmation.text,
    );

    if (!confirmed) {
      return false;
    }

    // Perform deletion
    if (!context.mounted) return false;

    final provider = context.read<AffirmationProvider>();
    final success = await provider.deleteAffirmation(affirmation.id);

    if (success) {
      onSuccess?.call();
      return true;
    } else {
      onError?.call(provider.error ?? 'Failed to delete affirmation');
      return false;
    }
  }

  /// Shows a snackbar indicating successful deletion.
  ///
  /// Call this in the [onSuccess] callback of [deleteWithConfirmation].
  static void showSuccessSnackBar(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Affirmation deleted'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Shows a snackbar indicating failed deletion.
  ///
  /// Call this in the [onError] callback of [deleteWithConfirmation].
  static void showErrorSnackBar(BuildContext context, String error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
