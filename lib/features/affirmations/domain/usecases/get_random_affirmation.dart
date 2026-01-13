/// Get random affirmation use case.
///
/// Implements the business logic for selecting a random affirmation.
/// Based on REQUIREMENTS.md FR-008, FR-014.
library;

import '../../../affirmations/data/models/affirmation.dart';
import '../../../affirmations/data/repositories/affirmation_repository.dart';
import '../../../../core/utils/random_selector.dart';

/// Use case for getting a random affirmation.
///
/// Selects a random active affirmation while avoiding immediate repetition
/// of the last displayed affirmation.
class GetRandomAffirmation {
  /// Creates a new GetRandomAffirmation use case.
  GetRandomAffirmation({
    required AffirmationRepository repository,
    RandomSelector? randomSelector,
  })  : _repository = repository,
        _randomSelector = randomSelector ?? RandomSelector();

  final AffirmationRepository _repository;
  final RandomSelector _randomSelector;

  /// Executes the use case to get a random affirmation.
  ///
  /// [lastDisplayedId] - Optional ID of the last displayed affirmation
  /// to avoid showing the same one twice in a row.
  ///
  /// Returns null if no active affirmations exist.
  Future<Affirmation?> call({String? lastDisplayedId}) async {
    final activeAffirmations = await _repository.getActive();

    if (activeAffirmations.isEmpty) {
      return null;
    }

    return _randomSelector.selectRandom(
      items: activeAffirmations,
      getId: (affirmation) => affirmation.id,
      excludeId: lastDisplayedId,
    );
  }
}
