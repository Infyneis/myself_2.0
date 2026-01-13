/// Delete affirmation use case.
///
/// Implements the business logic for deleting affirmations.
/// Based on REQUIREMENTS.md FR-003.
library;

import '../../data/repositories/affirmation_repository.dart';

/// Result of delete affirmation operation.
sealed class DeleteAffirmationResult {
  const DeleteAffirmationResult();
}

/// Successful deletion result.
final class DeleteAffirmationSuccess extends DeleteAffirmationResult {
  /// Creates a successful deletion result.
  const DeleteAffirmationSuccess({
    required this.id,
  });

  /// The ID of the deleted affirmation.
  final String id;
}

/// Failed deletion result.
final class DeleteAffirmationFailure extends DeleteAffirmationResult {
  /// Creates a failure result with an error message.
  const DeleteAffirmationFailure({
    required this.message,
  });

  /// Error message describing what went wrong.
  final String message;
}

/// Use case for deleting an existing affirmation.
///
/// This use case:
/// - Validates that the affirmation ID is not empty
/// - Verifies the affirmation exists before deletion
/// - Removes the affirmation from storage
///
/// Example:
/// ```dart
/// final useCase = DeleteAffirmationUseCase(repository: repository);
/// final result = await useCase.call(id: 'affirmation-uuid');
/// switch (result) {
///   case DeleteAffirmationSuccess(:final id):
///     print('Deleted affirmation: $id');
///   case DeleteAffirmationFailure(:final message):
///     print('Error: $message');
/// }
/// ```
class DeleteAffirmationUseCase {
  /// Creates a DeleteAffirmationUseCase.
  const DeleteAffirmationUseCase({
    required AffirmationRepository repository,
  }) : _repository = repository;

  final AffirmationRepository _repository;

  /// Executes the delete affirmation use case.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the affirmation to delete (required).
  ///
  /// Returns:
  /// - [DeleteAffirmationSuccess] if deletion was successful.
  /// - [DeleteAffirmationFailure] if validation failed or affirmation not found.
  Future<DeleteAffirmationResult> call({
    required String id,
  }) async {
    // Validate ID is not empty
    if (id.isEmpty) {
      return const DeleteAffirmationFailure(
        message: 'Affirmation ID cannot be empty',
      );
    }

    // Check if affirmation exists
    final existing = await _repository.getById(id);
    if (existing == null) {
      return const DeleteAffirmationFailure(
        message: 'Affirmation not found',
      );
    }

    // Perform deletion
    final deleted = await _repository.delete(id);
    if (!deleted) {
      return const DeleteAffirmationFailure(
        message: 'Failed to delete affirmation from storage',
      );
    }

    return DeleteAffirmationSuccess(id: id);
  }
}
