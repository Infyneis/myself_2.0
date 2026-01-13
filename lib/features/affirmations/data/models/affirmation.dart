/// Affirmation data model.
///
/// Represents a user's personal affirmation with metadata.
/// Based on REQUIREMENTS.md Section 9.2
library;

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'affirmation.g.dart';

/// Hive type ID for Affirmation model.
const int affirmationTypeId = 0;

/// Maximum allowed length for affirmation text.
const int maxAffirmationTextLength = 280;

/// Represents a single affirmation.
///
/// Each affirmation has:
/// - A unique identifier (UUID)
/// - Text content (max 280 characters)
/// - Creation and update timestamps
/// - Display count for future analytics
/// - Active status to enable/disable individual affirmations
/// - Sort order for drag-and-drop reordering
@HiveType(typeId: affirmationTypeId)
class Affirmation extends HiveObject {
  /// Creates a new Affirmation instance.
  ///
  /// The [text] must not exceed [maxAffirmationTextLength] characters.
  Affirmation({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.displayCount = 0,
    this.isActive = true,
    this.sortOrder = 0,
  }) : assert(
         text.length <= maxAffirmationTextLength,
         'Affirmation text cannot exceed $maxAffirmationTextLength characters',
       );

  /// Factory constructor to create a new affirmation with auto-generated UUID.
  ///
  /// Automatically generates a unique ID and sets creation/update timestamps.
  /// The [text] must not exceed [maxAffirmationTextLength] characters.
  ///
  /// Throws [ArgumentError] if [text] exceeds [maxAffirmationTextLength].
  factory Affirmation.create({
    required String text,
    bool isActive = true,
    int sortOrder = 0,
  }) {
    if (text.length > maxAffirmationTextLength) {
      throw ArgumentError(
        'Affirmation text cannot exceed $maxAffirmationTextLength characters. '
        'Got ${text.length} characters.',
      );
    }

    final now = DateTime.now();
    return Affirmation(
      id: const Uuid().v4(),
      text: text,
      createdAt: now,
      updatedAt: now,
      displayCount: 0,
      isActive: isActive,
      sortOrder: sortOrder,
    );
  }

  /// Unique identifier (UUID)
  @HiveField(0)
  final String id;

  /// Affirmation text content (max 280 characters)
  @HiveField(1)
  String text;

  /// Timestamp when the affirmation was created
  @HiveField(2)
  final DateTime createdAt;

  /// Timestamp when the affirmation was last updated
  @HiveField(3)
  DateTime updatedAt;

  /// Number of times this affirmation has been displayed (for future analytics)
  @HiveField(4)
  int displayCount;

  /// Whether this affirmation is active and should be included in rotation
  @HiveField(5)
  bool isActive;

  /// Sort order for drag-and-drop reordering in list view
  @HiveField(6)
  int sortOrder;

  /// Creates a copy of this affirmation with the given fields replaced.
  Affirmation copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? displayCount,
    bool? isActive,
    int? sortOrder,
  }) {
    return Affirmation(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayCount: displayCount ?? this.displayCount,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Affirmation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          displayCount == other.displayCount &&
          isActive == other.isActive &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      displayCount.hashCode ^
      isActive.hashCode ^
      sortOrder.hashCode;

  @override
  String toString() {
    return 'Affirmation(id: $id, text: $text, createdAt: $createdAt, '
        'updatedAt: $updatedAt, displayCount: $displayCount, isActive: $isActive, '
        'sortOrder: $sortOrder)';
  }

  /// Returns the remaining character count for this affirmation's text.
  int get remainingCharacters => maxAffirmationTextLength - text.length;

  /// Returns true if the text is within the allowed character limit.
  bool get isValidLength => text.length <= maxAffirmationTextLength;

  /// Returns true if the text is empty or only contains whitespace.
  bool get isEmpty => text.trim().isEmpty;

  /// Returns true if the text has valid content (not empty and within limits).
  bool get isValid => !isEmpty && isValidLength;

  /// Validates the given text against the maximum length constraint.
  ///
  /// Returns `null` if valid, or an error message if invalid.
  static String? validateText(String text) {
    if (text.trim().isEmpty) {
      return 'Affirmation text cannot be empty';
    }
    if (text.length > maxAffirmationTextLength) {
      return 'Affirmation text cannot exceed $maxAffirmationTextLength characters. '
          'Currently: ${text.length} characters.';
    }
    return null;
  }
}
