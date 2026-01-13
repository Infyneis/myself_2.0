// Unit tests for AffirmationProvider.
//
// Tests state management functionality for affirmations.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/create_affirmation.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/delete_affirmation.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/edit_affirmation.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/get_random_affirmation.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';

// Mock classes
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

class MockGetRandomAffirmation extends Mock implements GetRandomAffirmation {}

class MockCreateAffirmationUseCase extends Mock implements CreateAffirmationUseCase {}

class MockEditAffirmationUseCase extends Mock implements EditAffirmationUseCase {}

class MockDeleteAffirmationUseCase extends Mock implements DeleteAffirmationUseCase {}

void main() {
  late MockAffirmationRepository mockRepository;
  late MockGetRandomAffirmation mockGetRandomAffirmation;
  late MockCreateAffirmationUseCase mockCreateAffirmationUseCase;
  late MockEditAffirmationUseCase mockEditAffirmationUseCase;
  late MockDeleteAffirmationUseCase mockDeleteAffirmationUseCase;
  late AffirmationProvider provider;

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(
      Affirmation(
        id: 'test-id',
        text: 'Test affirmation',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockRepository = MockAffirmationRepository();
    mockGetRandomAffirmation = MockGetRandomAffirmation();
    mockCreateAffirmationUseCase = MockCreateAffirmationUseCase();
    mockEditAffirmationUseCase = MockEditAffirmationUseCase();
    mockDeleteAffirmationUseCase = MockDeleteAffirmationUseCase();
    provider = AffirmationProvider(
      repository: mockRepository,
      getRandomAffirmationUseCase: mockGetRandomAffirmation,
      createAffirmationUseCase: mockCreateAffirmationUseCase,
      editAffirmationUseCase: mockEditAffirmationUseCase,
      deleteAffirmationUseCase: mockDeleteAffirmationUseCase,
    );
  });

  group('AffirmationProvider', () {
    group('loadAffirmations', () {
      test('should load affirmations from repository', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: '1',
            text: 'I am confident',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Affirmation(
            id: '2',
            text: 'I am successful',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);

        // Act
        await provider.loadAffirmations();

        // Assert
        expect(provider.affirmations, equals(affirmations));
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
        verify(() => mockRepository.getAll()).called(1);
      });

      test('should set isLoading to true during loading', () async {
        // Arrange
        when(() => mockRepository.getAll()).thenAnswer((_) async {
          // Verify loading state during operation
          expect(provider.isLoading, isTrue);
          return [];
        });

        // Act
        await provider.loadAffirmations();

        // Assert
        expect(provider.isLoading, isFalse);
      });

      test('should set error when loading fails', () async {
        // Arrange
        when(() => mockRepository.getAll()).thenThrow(Exception('Database error'));

        // Act
        await provider.loadAffirmations();

        // Assert
        expect(provider.error, contains('Failed to load affirmations'));
        expect(provider.isLoading, isFalse);
      });
    });

    group('createAffirmation', () {
      test('should create a new affirmation', () async {
        // Arrange
        final newAffirmation = Affirmation(
          id: '1',
          text: 'I am amazing',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.create(any())).thenAnswer((_) async => newAffirmation);

        // Act
        await provider.createAffirmation(newAffirmation);

        // Assert
        expect(provider.affirmations, contains(newAffirmation));
        expect(provider.error, isNull);
        verify(() => mockRepository.create(any())).called(1);
      });

      test('should set error when creation fails', () async {
        // Arrange
        final newAffirmation = Affirmation(
          id: '1',
          text: 'I am amazing',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.create(any())).thenThrow(Exception('Creation failed'));

        // Act
        await provider.createAffirmation(newAffirmation);

        // Assert
        expect(provider.error, contains('Failed to create affirmation'));
      });
    });

    group('updateAffirmation', () {
      test('should update an existing affirmation', () async {
        // Arrange
        final originalAffirmation = Affirmation(
          id: '1',
          text: 'Original text',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final updatedAffirmation = originalAffirmation.copyWith(
          text: 'Updated text',
        );

        when(() => mockRepository.getAll()).thenAnswer((_) async => [originalAffirmation]);
        when(() => mockRepository.update(any())).thenAnswer((_) async => updatedAffirmation);

        // Load initial data
        await provider.loadAffirmations();

        // Act
        await provider.updateAffirmation(updatedAffirmation);

        // Assert
        expect(provider.affirmations.first.text, equals('Updated text'));
        verify(() => mockRepository.update(any())).called(1);
      });
    });

    group('deleteAffirmation', () {
      test('should delete an affirmation by id', () async {
        // Arrange
        final affirmation = Affirmation(
          id: '1',
          text: 'To be deleted',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.getAll()).thenAnswer((_) async => [affirmation]);
        when(() => mockDeleteAffirmationUseCase.call(id: '1'))
            .thenAnswer((_) async => const DeleteAffirmationSuccess(id: '1'));

        // Load initial data
        await provider.loadAffirmations();
        expect(provider.affirmations.length, equals(1));

        // Act
        final success = await provider.deleteAffirmation('1');

        // Assert
        expect(success, isTrue);
        expect(provider.affirmations, isEmpty);
        verify(() => mockDeleteAffirmationUseCase.call(id: '1')).called(1);
      });

      test('should return false and set error when deletion fails', () async {
        // Arrange
        final affirmation = Affirmation(
          id: '1',
          text: 'To be deleted',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.getAll()).thenAnswer((_) async => [affirmation]);
        when(() => mockDeleteAffirmationUseCase.call(id: '1'))
            .thenAnswer((_) async => const DeleteAffirmationFailure(message: 'Failed to delete'));

        // Load initial data
        await provider.loadAffirmations();

        // Act
        final success = await provider.deleteAffirmation('1');

        // Assert
        expect(success, isFalse);
        expect(provider.error, equals('Failed to delete'));
      });

      test('should clear current affirmation if it was deleted', () async {
        // Arrange
        final affirmation = Affirmation(
          id: '1',
          text: 'Current affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.getAll()).thenAnswer((_) async => [affirmation]);
        when(() => mockGetRandomAffirmation.call(lastDisplayedId: null))
            .thenAnswer((_) async => affirmation);
        when(() => mockDeleteAffirmationUseCase.call(id: '1'))
            .thenAnswer((_) async => const DeleteAffirmationSuccess(id: '1'));

        // Load initial data and set current affirmation
        await provider.loadAffirmations();
        await provider.selectRandomAffirmation();
        expect(provider.currentAffirmation, isNotNull);

        // Act
        await provider.deleteAffirmation('1');

        // Assert
        expect(provider.currentAffirmation, isNull);
      });
    });

    group('selectRandomAffirmation', () {
      test('should select a random affirmation', () async {
        // Arrange
        final randomAffirmation = Affirmation(
          id: '1',
          text: 'Random affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockGetRandomAffirmation.call(lastDisplayedId: any(named: 'lastDisplayedId')))
            .thenAnswer((_) async => randomAffirmation);

        // Act
        await provider.selectRandomAffirmation();

        // Assert
        expect(provider.currentAffirmation, equals(randomAffirmation));
      });

      test('should avoid immediate repetition of last displayed affirmation', () async {
        // Arrange
        final firstAffirmation = Affirmation(
          id: '1',
          text: 'First',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final secondAffirmation = Affirmation(
          id: '2',
          text: 'Second',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockGetRandomAffirmation.call(lastDisplayedId: null))
            .thenAnswer((_) async => firstAffirmation);
        when(() => mockGetRandomAffirmation.call(lastDisplayedId: '1'))
            .thenAnswer((_) async => secondAffirmation);

        // Act - first selection
        await provider.selectRandomAffirmation();
        expect(provider.currentAffirmation?.id, equals('1'));

        // Act - second selection (should pass lastDisplayedId)
        await provider.selectRandomAffirmation();

        // Assert
        expect(provider.currentAffirmation?.id, equals('2'));
      });
    });

    group('hasAffirmations', () {
      test('should return false when affirmations list is empty', () {
        expect(provider.hasAffirmations, isFalse);
      });

      test('should return true when affirmations exist', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: '1',
            text: 'Test',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);

        // Act
        await provider.loadAffirmations();

        // Assert
        expect(provider.hasAffirmations, isTrue);
      });
    });

    group('createAffirmationFromText', () {
      test('should create affirmation from text and return true on success', () async {
        // Arrange
        const text = 'I am confident and capable';
        final createdAffirmation = Affirmation.create(text: text);

        when(() => mockCreateAffirmationUseCase.call(
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => CreateAffirmationSuccess(createdAffirmation));

        // Act
        final result = await provider.createAffirmationFromText(text: text);

        // Assert
        expect(result, isTrue);
        expect(provider.affirmations.length, equals(1));
        expect(provider.affirmations.first.text, equals(text));
        expect(provider.error, isNull);
      });

      test('should return false and set error on validation failure', () async {
        // Arrange
        const text = '';
        const errorMessage = 'Affirmation text cannot be empty';

        when(() => mockCreateAffirmationUseCase.call(
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => const CreateAffirmationFailure(errorMessage));

        // Act
        final result = await provider.createAffirmationFromText(text: text);

        // Assert
        expect(result, isFalse);
        expect(provider.affirmations, isEmpty);
        expect(provider.error, equals(errorMessage));
      });

      test('should return false and set error when text exceeds 280 characters', () async {
        // Arrange
        final longText = 'a' * 281;
        const errorMessage = 'Affirmation text cannot exceed 280 characters';

        when(() => mockCreateAffirmationUseCase.call(
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => const CreateAffirmationFailure(errorMessage));

        // Act
        final result = await provider.createAffirmationFromText(text: longText);

        // Assert
        expect(result, isFalse);
        expect(provider.error, contains('280'));
      });

      test('should pass isActive parameter to use case', () async {
        // Arrange
        const text = 'Test affirmation';
        final createdAffirmation = Affirmation.create(text: text, isActive: false);

        when(() => mockCreateAffirmationUseCase.call(
          text: any(named: 'text'),
          isActive: false,
        )).thenAnswer((_) async => CreateAffirmationSuccess(createdAffirmation));

        // Act
        final result = await provider.createAffirmationFromText(
          text: text,
          isActive: false,
        );

        // Assert
        expect(result, isTrue);
        expect(provider.affirmations.first.isActive, isFalse);
        verify(() => mockCreateAffirmationUseCase.call(
          text: text,
          isActive: false,
        )).called(1);
      });

      test('should set isLoading during operation', () async {
        // Arrange
        const text = 'Test affirmation';
        final createdAffirmation = Affirmation.create(text: text);
        var wasLoadingDuringCall = false;

        when(() => mockCreateAffirmationUseCase.call(
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async {
          wasLoadingDuringCall = provider.isLoading;
          return CreateAffirmationSuccess(createdAffirmation);
        });

        // Act
        await provider.createAffirmationFromText(text: text);

        // Assert
        expect(wasLoadingDuringCall, isTrue);
        expect(provider.isLoading, isFalse);
      });

      test('should handle exception from use case', () async {
        // Arrange
        const text = 'Test affirmation';

        when(() => mockCreateAffirmationUseCase.call(
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await provider.createAffirmationFromText(text: text);

        // Assert
        expect(result, isFalse);
        expect(provider.error, contains('Failed to create affirmation'));
      });

      test('should generate UUID for the created affirmation', () async {
        // Arrange
        const text = 'Test affirmation';
        final createdAffirmation = Affirmation.create(text: text);

        when(() => mockCreateAffirmationUseCase.call(
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => CreateAffirmationSuccess(createdAffirmation));

        // Act
        await provider.createAffirmationFromText(text: text);

        // Assert
        expect(provider.affirmations.first.id, isNotEmpty);
        expect(provider.affirmations.first.id.length, equals(36)); // UUID v4 format
      });
    });

    group('editAffirmationFromText', () {
      test('should edit affirmation and return true on success', () async {
        // Arrange
        final originalAffirmation = Affirmation(
          id: '1',
          text: 'Original text',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          displayCount: 5,
        );
        final editedAffirmation = originalAffirmation.copyWith(
          text: 'Updated text',
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.getAll())
            .thenAnswer((_) async => [originalAffirmation]);
        when(() => mockEditAffirmationUseCase.call(
          id: any(named: 'id'),
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => EditAffirmationSuccess(editedAffirmation));

        // Load initial data
        await provider.loadAffirmations();

        // Act
        final result = await provider.editAffirmationFromText(
          id: '1',
          text: 'Updated text',
        );

        // Assert
        expect(result, isTrue);
        expect(provider.affirmations.first.text, equals('Updated text'));
        expect(provider.error, isNull);
      });

      test('should return false and set error when affirmation not found', () async {
        // Arrange
        const errorMessage = 'Affirmation not found';

        when(() => mockEditAffirmationUseCase.call(
          id: any(named: 'id'),
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => const EditAffirmationFailure(errorMessage));

        // Act
        final result = await provider.editAffirmationFromText(
          id: 'nonexistent',
          text: 'New text',
        );

        // Assert
        expect(result, isFalse);
        expect(provider.error, equals(errorMessage));
      });

      test('should return false and set error when text is empty', () async {
        // Arrange
        const errorMessage = 'Affirmation text cannot be empty';

        when(() => mockEditAffirmationUseCase.call(
          id: any(named: 'id'),
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => const EditAffirmationFailure(errorMessage));

        // Act
        final result = await provider.editAffirmationFromText(
          id: '1',
          text: '',
        );

        // Assert
        expect(result, isFalse);
        expect(provider.error, contains('empty'));
      });

      test('should return false and set error when text exceeds 280 characters', () async {
        // Arrange
        final longText = 'a' * 281;
        const errorMessage = 'Affirmation text cannot exceed 280 characters';

        when(() => mockEditAffirmationUseCase.call(
          id: any(named: 'id'),
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => const EditAffirmationFailure(errorMessage));

        // Act
        final result = await provider.editAffirmationFromText(
          id: '1',
          text: longText,
        );

        // Assert
        expect(result, isFalse);
        expect(provider.error, contains('280'));
      });

      test('should preserve metadata when editing text', () async {
        // Arrange
        final originalTime = DateTime(2024, 1, 1);
        final originalAffirmation = Affirmation(
          id: '1',
          text: 'Original text',
          createdAt: originalTime,
          updatedAt: originalTime,
          displayCount: 10,
          isActive: true,
        );
        final editedAffirmation = originalAffirmation.copyWith(
          text: 'New text',
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.getAll())
            .thenAnswer((_) async => [originalAffirmation]);
        when(() => mockEditAffirmationUseCase.call(
          id: any(named: 'id'),
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => EditAffirmationSuccess(editedAffirmation));

        // Load initial data
        await provider.loadAffirmations();

        // Act
        await provider.editAffirmationFromText(
          id: '1',
          text: 'New text',
        );

        // Assert
        expect(provider.affirmations.first.id, equals('1'));
        expect(provider.affirmations.first.createdAt, equals(originalTime));
        expect(provider.affirmations.first.displayCount, equals(10));
      });

      test('should update updatedAt timestamp when editing', () async {
        // Arrange
        final originalTime = DateTime(2024, 1, 1);
        final newTime = DateTime.now();
        final originalAffirmation = Affirmation(
          id: '1',
          text: 'Original text',
          createdAt: originalTime,
          updatedAt: originalTime,
        );
        final editedAffirmation = originalAffirmation.copyWith(
          text: 'New text',
          updatedAt: newTime,
        );

        when(() => mockRepository.getAll())
            .thenAnswer((_) async => [originalAffirmation]);
        when(() => mockEditAffirmationUseCase.call(
          id: any(named: 'id'),
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => EditAffirmationSuccess(editedAffirmation));

        // Load initial data
        await provider.loadAffirmations();

        // Act
        await provider.editAffirmationFromText(
          id: '1',
          text: 'New text',
        );

        // Assert
        expect(
          provider.affirmations.first.updatedAt.isAfter(originalTime) ||
              provider.affirmations.first.updatedAt == newTime,
          isTrue,
        );
      });

      test('should allow updating isActive status', () async {
        // Arrange
        final originalAffirmation = Affirmation(
          id: '1',
          text: 'Original text',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );
        final editedAffirmation = originalAffirmation.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.getAll())
            .thenAnswer((_) async => [originalAffirmation]);
        when(() => mockEditAffirmationUseCase.call(
          id: '1',
          text: 'Original text',
          isActive: false,
        )).thenAnswer((_) async => EditAffirmationSuccess(editedAffirmation));

        // Load initial data
        await provider.loadAffirmations();

        // Act
        final result = await provider.editAffirmationFromText(
          id: '1',
          text: 'Original text',
          isActive: false,
        );

        // Assert
        expect(result, isTrue);
        expect(provider.affirmations.first.isActive, isFalse);
      });

      test('should set isLoading during operation', () async {
        // Arrange
        final originalAffirmation = Affirmation(
          id: '1',
          text: 'Original',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        var wasLoadingDuringCall = false;

        when(() => mockRepository.getAll())
            .thenAnswer((_) async => [originalAffirmation]);
        when(() => mockEditAffirmationUseCase.call(
          id: any(named: 'id'),
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async {
          wasLoadingDuringCall = provider.isLoading;
          return EditAffirmationSuccess(originalAffirmation.copyWith(text: 'New'));
        });

        // Load initial data
        await provider.loadAffirmations();

        // Act
        await provider.editAffirmationFromText(id: '1', text: 'New');

        // Assert
        expect(wasLoadingDuringCall, isTrue);
        expect(provider.isLoading, isFalse);
      });

      test('should handle exception from use case', () async {
        // Arrange
        when(() => mockEditAffirmationUseCase.call(
          id: any(named: 'id'),
          text: any(named: 'text'),
          isActive: any(named: 'isActive'),
        )).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await provider.editAffirmationFromText(
          id: '1',
          text: 'New text',
        );

        // Assert
        expect(result, isFalse);
        expect(provider.error, contains('Failed to edit affirmation'));
      });
    });

    group('getAffirmationById', () {
      test('should return affirmation when found', () async {
        // Arrange
        final affirmation = Affirmation(
          id: '1',
          text: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.getAll())
            .thenAnswer((_) async => [affirmation]);

        await provider.loadAffirmations();

        // Act
        final result = provider.getAffirmationById('1');

        // Assert
        expect(result, equals(affirmation));
      });

      test('should return null when not found', () async {
        // Arrange
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        await provider.loadAffirmations();

        // Act
        final result = provider.getAffirmationById('nonexistent');

        // Assert
        expect(result, isNull);
      });
    });
  });
}
