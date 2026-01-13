// Unit tests for AffirmationProvider.
//
// Tests state management functionality for affirmations.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/get_random_affirmation.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';

// Mock classes
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

class MockGetRandomAffirmation extends Mock implements GetRandomAffirmation {}

void main() {
  late MockAffirmationRepository mockRepository;
  late MockGetRandomAffirmation mockGetRandomAffirmation;
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
    provider = AffirmationProvider(
      repository: mockRepository,
      getRandomAffirmationUseCase: mockGetRandomAffirmation,
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
        when(() => mockRepository.delete('1')).thenAnswer((_) async => true);

        // Load initial data
        await provider.loadAffirmations();
        expect(provider.affirmations.length, equals(1));

        // Act
        await provider.deleteAffirmation('1');

        // Assert
        expect(provider.affirmations, isEmpty);
        verify(() => mockRepository.delete('1')).called(1);
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
  });
}
