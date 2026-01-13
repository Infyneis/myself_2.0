// Unit tests for Affirmation data model.
//
// Tests the Affirmation class including:
// - UUID generation
// - Character limit validation (280 chars max)
// - Field initialization and defaults
// - copyWith functionality
// - Equality and hashCode
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';

void main() {
  group('Affirmation', () {
    group('constructor', () {
      test('should create an affirmation with all required fields', () {
        // Arrange & Act
        final now = DateTime.now();
        final affirmation = Affirmation(
          id: 'test-uuid-1234',
          text: 'I am confident and capable',
          createdAt: now,
          updatedAt: now,
        );

        // Assert
        expect(affirmation.id, equals('test-uuid-1234'));
        expect(affirmation.text, equals('I am confident and capable'));
        expect(affirmation.createdAt, equals(now));
        expect(affirmation.updatedAt, equals(now));
        expect(affirmation.displayCount, equals(0));
        expect(affirmation.isActive, isTrue);
      });

      test('should create an affirmation with custom displayCount and isActive', () {
        // Arrange & Act
        final now = DateTime.now();
        final affirmation = Affirmation(
          id: 'test-uuid-1234',
          text: 'Test affirmation',
          createdAt: now,
          updatedAt: now,
          displayCount: 5,
          isActive: false,
        );

        // Assert
        expect(affirmation.displayCount, equals(5));
        expect(affirmation.isActive, isFalse);
      });

      test('should accept text at exactly 280 characters', () {
        // Arrange
        final now = DateTime.now();
        final maxText = 'a' * maxAffirmationTextLength;

        // Act & Assert - should not throw
        expect(
          () => Affirmation(
            id: 'test-id',
            text: maxText,
            createdAt: now,
            updatedAt: now,
          ),
          returnsNormally,
        );
      });
    });

    group('Affirmation.create factory', () {
      test('should create an affirmation with auto-generated UUID', () {
        // Arrange & Act
        final affirmation = Affirmation.create(text: 'I am successful');

        // Assert
        expect(affirmation.id, isNotEmpty);
        expect(affirmation.id.length, equals(36)); // UUID v4 format
        expect(affirmation.text, equals('I am successful'));
      });

      test('should set createdAt and updatedAt to now', () {
        // Arrange
        final beforeCreate = DateTime.now();

        // Act
        final affirmation = Affirmation.create(text: 'Test');

        // Assert
        final afterCreate = DateTime.now();
        expect(
          affirmation.createdAt.millisecondsSinceEpoch,
          greaterThanOrEqualTo(beforeCreate.millisecondsSinceEpoch),
        );
        expect(
          affirmation.createdAt.millisecondsSinceEpoch,
          lessThanOrEqualTo(afterCreate.millisecondsSinceEpoch),
        );
        expect(affirmation.updatedAt, equals(affirmation.createdAt));
      });

      test('should set displayCount to 0 by default', () {
        // Arrange & Act
        final affirmation = Affirmation.create(text: 'Test');

        // Assert
        expect(affirmation.displayCount, equals(0));
      });

      test('should set isActive to true by default', () {
        // Arrange & Act
        final affirmation = Affirmation.create(text: 'Test');

        // Assert
        expect(affirmation.isActive, isTrue);
      });

      test('should allow setting isActive to false', () {
        // Arrange & Act
        final affirmation = Affirmation.create(
          text: 'Test',
          isActive: false,
        );

        // Assert
        expect(affirmation.isActive, isFalse);
      });

      test('should generate unique UUIDs for each affirmation', () {
        // Arrange & Act
        final affirmation1 = Affirmation.create(text: 'First');
        final affirmation2 = Affirmation.create(text: 'Second');
        final affirmation3 = Affirmation.create(text: 'Third');

        // Assert
        expect(affirmation1.id, isNot(equals(affirmation2.id)));
        expect(affirmation2.id, isNot(equals(affirmation3.id)));
        expect(affirmation1.id, isNot(equals(affirmation3.id)));
      });

      test('should throw ArgumentError when text exceeds 280 characters', () {
        // Arrange
        final longText = 'a' * (maxAffirmationTextLength + 1);

        // Act & Assert
        expect(
          () => Affirmation.create(text: longText),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should accept text at exactly 280 characters', () {
        // Arrange
        final maxText = 'a' * maxAffirmationTextLength;

        // Act & Assert - should not throw
        expect(
          () => Affirmation.create(text: maxText),
          returnsNormally,
        );
      });
    });

    group('maxAffirmationTextLength constant', () {
      test('should be 280', () {
        expect(maxAffirmationTextLength, equals(280));
      });
    });

    group('copyWith', () {
      test('should create a copy with updated text', () {
        // Arrange
        final original = Affirmation.create(text: 'Original text');

        // Act
        final copy = original.copyWith(text: 'New text');

        // Assert
        expect(copy.id, equals(original.id));
        expect(copy.text, equals('New text'));
        expect(copy.createdAt, equals(original.createdAt));
      });

      test('should create a copy with updated updatedAt', () {
        // Arrange
        final original = Affirmation.create(text: 'Test');
        final newUpdatedAt = DateTime.now().add(const Duration(hours: 1));

        // Act
        final copy = original.copyWith(updatedAt: newUpdatedAt);

        // Assert
        expect(copy.updatedAt, equals(newUpdatedAt));
        expect(copy.createdAt, equals(original.createdAt));
      });

      test('should create a copy with updated displayCount', () {
        // Arrange
        final original = Affirmation.create(text: 'Test');

        // Act
        final copy = original.copyWith(displayCount: 10);

        // Assert
        expect(copy.displayCount, equals(10));
        expect(original.displayCount, equals(0));
      });

      test('should create a copy with updated isActive', () {
        // Arrange
        final original = Affirmation.create(text: 'Test');

        // Act
        final copy = original.copyWith(isActive: false);

        // Assert
        expect(copy.isActive, isFalse);
        expect(original.isActive, isTrue);
      });

      test('should preserve all fields when no changes are made', () {
        // Arrange
        final original = Affirmation(
          id: 'test-id',
          text: 'Original',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 2),
          displayCount: 5,
          isActive: false,
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        // Arrange
        final date = DateTime(2025, 1, 1);
        final affirmation1 = Affirmation(
          id: 'same-id',
          text: 'Same text',
          createdAt: date,
          updatedAt: date,
          displayCount: 1,
          isActive: true,
        );
        final affirmation2 = Affirmation(
          id: 'same-id',
          text: 'Same text',
          createdAt: date,
          updatedAt: date,
          displayCount: 1,
          isActive: true,
        );

        // Assert
        expect(affirmation1, equals(affirmation2));
        expect(affirmation1.hashCode, equals(affirmation2.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        final date = DateTime(2025, 1, 1);
        final affirmation1 = Affirmation(
          id: 'id-1',
          text: 'Same text',
          createdAt: date,
          updatedAt: date,
        );
        final affirmation2 = Affirmation(
          id: 'id-2',
          text: 'Same text',
          createdAt: date,
          updatedAt: date,
        );

        // Assert
        expect(affirmation1, isNot(equals(affirmation2)));
      });

      test('should not be equal when text differs', () {
        // Arrange
        final date = DateTime(2025, 1, 1);
        final affirmation1 = Affirmation(
          id: 'same-id',
          text: 'Text 1',
          createdAt: date,
          updatedAt: date,
        );
        final affirmation2 = Affirmation(
          id: 'same-id',
          text: 'Text 2',
          createdAt: date,
          updatedAt: date,
        );

        // Assert
        expect(affirmation1, isNot(equals(affirmation2)));
      });
    });

    group('validation helpers', () {
      test('remainingCharacters should return correct count', () {
        // Arrange
        final affirmation = Affirmation.create(text: 'Hello'); // 5 chars

        // Assert
        expect(affirmation.remainingCharacters, equals(275));
      });

      test('isValidLength should return true for valid text', () {
        // Arrange
        final affirmation = Affirmation.create(text: 'Valid text');

        // Assert
        expect(affirmation.isValidLength, isTrue);
      });

      test('isEmpty should return false for non-empty text', () {
        // Arrange
        final affirmation = Affirmation.create(text: 'Some text');

        // Assert
        expect(affirmation.isEmpty, isFalse);
      });

      test('isValid should return true for valid affirmation', () {
        // Arrange
        final affirmation = Affirmation.create(text: 'Valid affirmation');

        // Assert
        expect(affirmation.isValid, isTrue);
      });
    });

    group('validateText static method', () {
      test('should return null for valid text', () {
        // Act
        final result = Affirmation.validateText('Valid text');

        // Assert
        expect(result, isNull);
      });

      test('should return error message for empty text', () {
        // Act
        final result = Affirmation.validateText('');

        // Assert
        expect(result, contains('cannot be empty'));
      });

      test('should return error message for whitespace-only text', () {
        // Act
        final result = Affirmation.validateText('   ');

        // Assert
        expect(result, contains('cannot be empty'));
      });

      test('should return error message for text exceeding 280 characters', () {
        // Arrange
        final longText = 'a' * (maxAffirmationTextLength + 1);

        // Act
        final result = Affirmation.validateText(longText);

        // Assert
        expect(result, contains('cannot exceed'));
        expect(result, contains('280'));
      });

      test('should return null for text at exactly 280 characters', () {
        // Arrange
        final maxText = 'a' * maxAffirmationTextLength;

        // Act
        final result = Affirmation.validateText(maxText);

        // Assert
        expect(result, isNull);
      });
    });

    group('toString', () {
      test('should return a string representation of the affirmation', () {
        // Arrange
        final date = DateTime(2025, 1, 1, 12, 0, 0);
        final affirmation = Affirmation(
          id: 'test-id',
          text: 'Test',
          createdAt: date,
          updatedAt: date,
          displayCount: 5,
          isActive: true,
        );

        // Act
        final result = affirmation.toString();

        // Assert
        expect(result, contains('test-id'));
        expect(result, contains('Test'));
        expect(result, contains('displayCount: 5'));
        expect(result, contains('isActive: true'));
      });
    });

    group('mutable fields', () {
      test('should allow updating text directly', () {
        // Arrange
        final affirmation = Affirmation.create(text: 'Original');

        // Act
        affirmation.text = 'Updated';

        // Assert
        expect(affirmation.text, equals('Updated'));
      });

      test('should allow updating displayCount directly', () {
        // Arrange
        final affirmation = Affirmation.create(text: 'Test');

        // Act
        affirmation.displayCount = 10;

        // Assert
        expect(affirmation.displayCount, equals(10));
      });

      test('should allow updating isActive directly', () {
        // Arrange
        final affirmation = Affirmation.create(text: 'Test');

        // Act
        affirmation.isActive = false;

        // Assert
        expect(affirmation.isActive, isFalse);
      });

      test('should allow updating updatedAt directly', () {
        // Arrange
        final affirmation = Affirmation.create(text: 'Test');
        final newDate = DateTime(2030, 1, 1);

        // Act
        affirmation.updatedAt = newDate;

        // Assert
        expect(affirmation.updatedAt, equals(newDate));
      });
    });
  });
}
