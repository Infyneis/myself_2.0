/// Affirmation data model.
///
/// Represents a user's personal affirmation with metadata.
/// Based on REQUIREMENTS.md Section 9.2
library;

import 'package:hive/hive.dart';

part 'affirmation.g.dart';

/// Hive type ID for Affirmation model.
const int affirmationTypeId = 0;

/// Represents a single affirmation.
///
/// Each affirmation has:
/// - A unique identifier (UUID)
/// - Text content (max 280 characters)
/// - Creation and update timestamps
/// - Display count for future analytics
/// - Active status to enable/disable individual affirmations
@HiveType(typeId: affirmationTypeId)
class Affirmation extends HiveObject {
  /// Creates a new Affirmation instance.
  Affirmation({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.displayCount = 0,
    this.isActive = true,
  });

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

  /// Creates a copy of this affirmation with the given fields replaced.
  Affirmation copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? displayCount,
    bool? isActive,
  }) {
    return Affirmation(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayCount: displayCount ?? this.displayCount,
      isActive: isActive ?? this.isActive,
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
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      displayCount.hashCode ^
      isActive.hashCode;

  @override
  String toString() {
    return 'Affirmation(id: $id, text: $text, createdAt: $createdAt, '
        'updatedAt: $updatedAt, displayCount: $displayCount, isActive: $isActive)';
  }
}
