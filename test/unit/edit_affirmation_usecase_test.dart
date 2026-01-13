// Unit tests for EditAffirmationUseCase.
//
// Tests the business logic for editing existing affirmations with
// text validation, updatedAt handling, and metadata preservation.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/edit_affirmation.dart';

// Mock classes
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

void main() {
  late MockAffirmationRepository mockRepository;
  late EditAffirmationUseCase useCase;

  // Sample affirmation for testing
  final existingAffirmation = Affirmation(
    id: 'test-uuid-123',
    text: 'Original affirmation text',
    createdAt: DateTime(2024, 1, 1, 10, 0),
    updatedAt: DateTime(2024, 1, 1, 10, 0),
    displayCount: 5,
    isActive: true,
  );

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(
      Affirmation(
        id: 'fallback-id',
        text: 'Fallback affirmation',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockRepository = MockAffirmationRepository();
    useCase = EditAffirmationUseCase(repository: mockRepository);
  });

  group('EditAffirmationUseCase', () {
    group('successful edit', () {
      test('should return success with updated text', () async {
        // Arrange
        const newText = 'Updated affirmation text';
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.call(
          id: existingAffirmation.id,
          text: newText,
        );

        // Assert
        expect(result, isA<EditAffirmationSuccess>());
        final success = result as EditAffirmationSuccess;
        expect(success.affirmation.text, equals(newText));
        expect(success.affirmation.id, equals(existingAffirmation.id));
        verify(() => mockRepository.update(any())).called(1);
      });

      test('should preserve id when editing', () async {
        // Arrange
        const newText = 'New text';
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.call(id: existingAffirmation.id, text: newText);

        // Assert
        final success = result as EditAffirmationSuccess;
        expect(success.affirmation.id, equals(existingAffirmation.id));
      });

      test('should preserve createdAt when editing', () async {
        // Arrange
        const newText = 'New text';
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.call(id: existingAffirmation.id, text: newText);

        // Assert
        final success = result as EditAffirmationSuccess;
        expect(success.affirmation.createdAt, equals(existingAffirmation.createdAt));
      });

      test('should preserve displayCount when editing', () async {
        // Arrange
        const newText = 'New text';
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.call(id: existingAffirmation.id, text: newText);

        // Assert
        final success = result as EditAffirmationSuccess;
        expect(success.affirmation.displayCount, equals(existingAffirmation.displayCount));
      });

      test('should update updatedAt timestamp', () async {
        // Arrange
        const newText = 'New text';
        final originalUpdatedAt = existingAffirmation.updatedAt;
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.call(id: existingAffirmation.id, text: newText);

        // Assert
        final success = result as EditAffirmationSuccess;
        expect(
          success.affirmation.updatedAt.isAfter(originalUpdatedAt) ||
              success.affirmation.updatedAt == originalUpdatedAt,
          isTrue,
        );
      });

      test('should trim whitespace from text', () async {
        // Arrange
        const newText = '  Trimmed text  ';
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.call(id: existingAffirmation.id, text: newText);

        // Assert
        final success = result as EditAffirmationSuccess;
        expect(success.affirmation.text, equals('Trimmed text'));
      });

      test('should allow updating isActive status', () async {
        // Arrange
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.call(
          id: existingAffirmation.id,
          isActive: false,
        );

        // Assert
        final success = result as EditAffirmationSuccess;
        expect(success.affirmation.isActive, isFalse);
      });

      test('should preserve text when only updating isActive', () async {
        // Arrange
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.call(
          id: existingAffirmation.id,
          isActive: false,
        );

        // Assert
        final success = result as EditAffirmationSuccess;
        expect(success.affirmation.text, equals(existingAffirmation.text));
      });
    });

    group('validation failures', () {
      test('should return failure when affirmation not found', () async {
        // Arrange
        when(() => mockRepository.getById('nonexistent-id'))
            .thenAnswer((_) async => null);

        // Act
        final result = await useCase.call(
          id: 'nonexistent-id',
          text: 'New text',
        );

        // Assert
        expect(result, isA<EditAffirmationFailure>());
        final failure = result as EditAffirmationFailure;
        expect(failure.message, contains('not found'));
        verifyNever(() => mockRepository.update(any()));
      });

      test('should return failure when text is empty', () async {
        // Arrange
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);

        // Act
        final result = await useCase.call(
          id: existingAffirmation.id,
          text: '',
        );

        // Assert
        expect(result, isA<EditAffirmationFailure>());
        final failure = result as EditAffirmationFailure;
        expect(failure.message, contains('empty'));
        verifyNever(() => mockRepository.update(any()));
      });

      test('should return failure when text is only whitespace', () async {
        // Arrange
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);

        // Act
        final result = await useCase.call(
          id: existingAffirmation.id,
          text: '   ',
        );

        // Assert
        expect(result, isA<EditAffirmationFailure>());
        final failure = result as EditAffirmationFailure;
        expect(failure.message, contains('empty'));
        verifyNever(() => mockRepository.update(any()));
      });

      test('should return failure when text exceeds 280 characters', () async {
        // Arrange
        final longText = 'a' * 281;
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);

        // Act
        final result = await useCase.call(
          id: existingAffirmation.id,
          text: longText,
        );

        // Assert
        expect(result, isA<EditAffirmationFailure>());
        final failure = result as EditAffirmationFailure;
        expect(failure.message, contains('280'));
        verifyNever(() => mockRepository.update(any()));
      });

      test('should allow text exactly at 280 characters', () async {
        // Arrange
        final exactText = 'a' * 280;
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.call(
          id: existingAffirmation.id,
          text: exactText,
        );

        // Assert
        expect(result, isA<EditAffirmationSuccess>());
        final success = result as EditAffirmationSuccess;
        expect(success.affirmation.text.length, equals(280));
      });
    });

    group('error handling', () {
      test('should return failure when repository throws exception', () async {
        // Arrange
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any()))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await useCase.call(
          id: existingAffirmation.id,
          text: 'New text',
        );

        // Assert
        expect(result, isA<EditAffirmationFailure>());
        final failure = result as EditAffirmationFailure;
        expect(failure.message, contains('Failed to update'));
      });

      test('should return failure when getById throws exception', () async {
        // Arrange
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await useCase.call(
          id: existingAffirmation.id,
          text: 'New text',
        );

        // Assert
        expect(result, isA<EditAffirmationFailure>());
      });
    });

    group('callWithAffirmation', () {
      test('should edit using affirmation object', () async {
        // Arrange
        final updatedAffirmation = existingAffirmation.copyWith(
          text: 'Updated via object',
          isActive: false,
        );
        when(() => mockRepository.getById(existingAffirmation.id))
            .thenAnswer((_) async => existingAffirmation);
        when(() => mockRepository.update(any())).thenAnswer((invocation) async {
          final affirmation = invocation.positionalArguments.first as Affirmation;
          return affirmation.copyWith(updatedAt: DateTime.now());
        });

        // Act
        final result = await useCase.callWithAffirmation(updatedAffirmation);

        // Assert
        expect(result, isA<EditAffirmationSuccess>());
        final success = result as EditAffirmationSuccess;
        expect(success.affirmation.text, equals('Updated via object'));
        expect(success.affirmation.isActive, isFalse);
      });
    });
  });
}
