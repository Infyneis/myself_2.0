/// Edit affirmation use case.
///
/// Implements the business logic for editing existing affirmations with
/// text validation, character limit enforcement (280 chars), and automatic
/// updatedAt timestamp updating while preserving other metadata.
/// Based on REQUIREMENTS.md FR-002.
library;

import '../../data/models/affirmation.dart';
import '../../data/repositories/affirmation_repository.dart';

/// Result of an affirmation edit attempt.
sealed class EditAffirmationResult {
  const EditAffirmationResult();
}

/// Successful edit result containing the updated affirmation.
class EditAffirmationSuccess extends EditAffirmationResult {
  /// Creates a success result.
  const EditAffirmationSuccess(this.affirmation);

  /// The updated affirmation.
  final Affirmation affirmation;
}

/// Failed edit result containing an error message.
class EditAffirmationFailure extends EditAffirmationResult {
  /// Creates a failure result.
  const EditAffirmationFailure(this.message);

  /// The error message describing why edit failed.
  final String message;
}

/// Use case for editing existing affirmations.
///
/// This use case encapsulates the business logic for:
/// - Validating the affirmation exists
/// - Validating new text (max 280 characters, non-empty)
/// - Updating the affirmation while preserving metadata (id, createdAt, displayCount)
/// - Automatically updating the updatedAt timestamp
///
/// Example:
/// ```dart
/// final useCase = EditAffirmationUseCase(repository: myRepository);
/// final result = await useCase.call(
///   id: 'existing-uuid',
///   text: 'Updated affirmation text',
/// );
///
/// switch (result) {
///   case EditAffirmationSuccess(:final affirmation):
///     print('Updated: ${affirmation.text}');
///   case EditAffirmationFailure(:final message):
///     print('Error: $message');
/// }
/// ```
class EditAffirmationUseCase {
  /// Creates an EditAffirmationUseCase.
  ///
  /// Requires an [AffirmationRepository] for persistence.
  const EditAffirmationUseCase({
    required AffirmationRepository repository,
  }) : _repository = repository;

  final AffirmationRepository _repository;

  /// Edits an existing affirmation with the given text.
  ///
  /// The [id] parameter specifies which affirmation to edit.
  /// The [text] parameter is optional; if provided, it replaces the current text.
  /// The [isActive] parameter is optional; if provided, it updates the active status.
  ///
  /// Returns [EditAffirmationSuccess] with the updated affirmation if successful,
  /// or [EditAffirmationFailure] with an error message if validation fails or
  /// the affirmation doesn't exist.
  ///
  /// Validation rules:
  /// - Affirmation with given ID must exist
  /// - If text is provided, it must not be empty or whitespace-only
  /// - If text is provided, it must not exceed 280 characters
  ///
  /// Preserved metadata:
  /// - id: Remains unchanged
  /// - createdAt: Remains unchanged
  /// - displayCount: Remains unchanged (unless explicitly modified)
  ///
  /// Updated fields:
  /// - text: Updated if provided
  /// - isActive: Updated if provided
  /// - updatedAt: Automatically set to current timestamp
  Future<EditAffirmationResult> call({
    required String id,
    String? text,
    bool? isActive,
  }) async {
    try {
      // Validate that affirmation exists
      final existingAffirmation = await _repository.getById(id);
      if (existingAffirmation == null) {
        return const EditAffirmationFailure('Affirmation not found');
      }

      // Validate new text if provided
      if (text != null) {
        final validationError = Affirmation.validateText(text);
        if (validationError != null) {
          return EditAffirmationFailure(validationError);
        }
      }

      // Create updated affirmation preserving metadata
      final updatedAffirmation = existingAffirmation.copyWith(
        text: text?.trim() ?? existingAffirmation.text,
        isActive: isActive ?? existingAffirmation.isActive,
        // Note: updatedAt will be set by the repository's update method
      );

      // Persist to repository (repository handles updatedAt timestamp)
      final saved = await _repository.update(updatedAffirmation);

      return EditAffirmationSuccess(saved);
    } catch (e) {
      return EditAffirmationFailure('Failed to update affirmation: $e');
    }
  }

  /// Edits an existing affirmation using an Affirmation object.
  ///
  /// This is a convenience method for when you have an Affirmation object
  /// with the desired changes already applied.
  ///
  /// Returns [EditAffirmationSuccess] with the updated affirmation if successful,
  /// or [EditAffirmationFailure] with an error message if validation fails.
  Future<EditAffirmationResult> callWithAffirmation(
    Affirmation affirmation,
  ) async {
    return call(
      id: affirmation.id,
      text: affirmation.text,
      isActive: affirmation.isActive,
    );
  }
}
