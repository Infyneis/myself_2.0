/// Random selection utility for affirmations.
///
/// Provides functionality to select random items while avoiding
/// immediate repetition as per REQUIREMENTS.md FR-014.
library;

import 'dart:math';

/// Utility class for random selection with repetition avoidance.
///
/// Used primarily for selecting random affirmations to display
/// while ensuring the same affirmation isn't shown twice in a row.
class RandomSelector {
  /// Creates a [RandomSelector] instance.
  ///
  /// Optionally accepts a [random] instance for testing purposes.
  /// If not provided, uses a standard [Random] instance.
  RandomSelector({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Selects a random item from the list, avoiding the excluded ID.
  ///
  /// [items] - List of items to select from
  /// [getId] - Function to extract ID from an item
  /// [excludeId] - ID to exclude from selection (typically last shown)
  ///
  /// Returns null if list is empty.
  /// If list has only one item and it matches excludeId, returns that item anyway.
  T? selectRandom<T>({
    required List<T> items,
    required String Function(T item) getId,
    String? excludeId,
  }) {
    if (items.isEmpty) {
      return null;
    }

    if (items.length == 1) {
      return items.first;
    }

    // Filter out the excluded item if specified
    final availableItems = excludeId != null
        ? items.where((item) => getId(item) != excludeId).toList()
        : items;

    // If all items were filtered out, fall back to the original list
    final selectionPool = availableItems.isNotEmpty ? availableItems : items;

    final index = _random.nextInt(selectionPool.length);
    return selectionPool[index];
  }

  /// Generates a random integer in the given range [min, max).
  int nextInt(int min, int max) {
    return min + _random.nextInt(max - min);
  }
}
