/// Affirmation repository interface.
///
/// Defines the contract for affirmation data operations.
/// Based on REQUIREMENTS.md FR-017, FR-018.
library;

import '../models/affirmation.dart';

/// Repository interface for affirmation CRUD operations.
///
/// This abstract class defines the contract that any affirmation
/// storage implementation must follow. The actual Hive implementation
/// will be provided in FUNC-008.
abstract class AffirmationRepository {
  /// Retrieves all affirmations.
  Future<List<Affirmation>> getAll();

  /// Retrieves all active affirmations.
  Future<List<Affirmation>> getActive();

  /// Retrieves a single affirmation by ID.
  ///
  /// Returns null if not found.
  Future<Affirmation?> getById(String id);

  /// Creates a new affirmation.
  ///
  /// Returns the created affirmation with generated ID.
  Future<Affirmation> create(Affirmation affirmation);

  /// Updates an existing affirmation.
  ///
  /// Returns the updated affirmation.
  Future<Affirmation> update(Affirmation affirmation);

  /// Deletes an affirmation by ID.
  ///
  /// Returns true if deletion was successful.
  Future<bool> delete(String id);

  /// Deletes all affirmations.
  Future<void> deleteAll();

  /// Gets the count of all affirmations.
  Future<int> count();

  /// Reorders affirmations based on the provided list order.
  Future<void> reorder(List<String> orderedIds);
}
