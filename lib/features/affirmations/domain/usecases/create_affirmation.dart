/// Create affirmation use case.
///
/// Implements the business logic for creating new affirmations with
/// free-form text input, character limit validation (280 chars), and UUID generation.
/// Based on REQUIREMENTS.md FR-001, FR-006.
library;

import '../../data/models/affirmation.dart';
import '../../data/repositories/affirmation_repository.dart';

/// Result of an affirmation creation attempt.
sealed class CreateAffirmationResult {
  const CreateAffirmationResult();
}

/// Successful creation result containing the created affirmation.
class CreateAffirmationSuccess extends CreateAffirmationResult {
  /// Creates a success result.
  const CreateAffirmationSuccess(this.affirmation);

  /// The created affirmation.
  final Affirmation affirmation;
}

/// Failed creation result containing an error message.
class CreateAffirmationFailure extends CreateAffirmationResult {
  /// Creates a failure result.
  const CreateAffirmationFailure(this.message);

  /// The error message describing why creation failed.
  final String message;
}

/// Use case for creating new affirmations.
///
/// This use case encapsulates the business logic for:
/// - Validating affirmation text (max 280 characters, non-empty)
/// - Generating unique UUID for each affirmation
/// - Persisting the affirmation to storage
///
/// Example:
/// ```dart
/// final useCase = CreateAffirmationUseCase(repository: myRepository);
/// final result = await useCase.call(text: 'I am confident and capable');
///
/// switch (result) {
///   case CreateAffirmationSuccess(:final affirmation):
///     print('Created: ${affirmation.id}');
///   case CreateAffirmationFailure(:final message):
///     print('Error: $message');
/// }
/// ```
class CreateAffirmationUseCase {
  /// Creates a CreateAffirmationUseCase.
  ///
  /// Requires an [AffirmationRepository] for persistence.
  const CreateAffirmationUseCase({
    required AffirmationRepository repository,
  }) : _repository = repository;

  final AffirmationRepository _repository;

  /// Creates a new affirmation with the given text.
  ///
  /// The [text] parameter accepts free-form text input.
  /// The [isActive] parameter defaults to true.
  ///
  /// Returns [CreateAffirmationSuccess] with the created affirmation if successful,
  /// or [CreateAffirmationFailure] with an error message if validation fails.
  ///
  /// Validation rules:
  /// - Text must not be empty or whitespace-only
  /// - Text must not exceed 280 characters
  Future<CreateAffirmationResult> call({
    required String text,
    bool isActive = true,
  }) async {
    // Validate text
    final validationError = Affirmation.validateText(text);
    if (validationError != null) {
      return CreateAffirmationFailure(validationError);
    }

    try {
      // Create affirmation with auto-generated UUID
      final affirmation = Affirmation.create(
        text: text.trim(),
        isActive: isActive,
      );

      // Persist to repository
      final created = await _repository.create(affirmation);

      return CreateAffirmationSuccess(created);
    } catch (e) {
      return CreateAffirmationFailure('Failed to create affirmation: $e');
    }
  }
}
