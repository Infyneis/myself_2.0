// Unit tests for HiveAffirmationRepository.
//
// Tests the Hive-backed implementation of AffirmationRepository.
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/hive_affirmation_repository.dart';
import 'package:uuid/uuid.dart';

// Mock classes
class MockBox extends Mock implements Box<Affirmation> {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late MockBox mockBox;
  late MockUuid mockUuid;
  late HiveAffirmationRepository repository;

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
    mockBox = MockBox();
    mockUuid = MockUuid();
    repository = HiveAffirmationRepository(box: mockBox, uuid: mockUuid);
  });

  group('HiveAffirmationRepository', () {
    group('getAll', () {
      test('should return all affirmations from box', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: '1',
            text: 'Test 1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Affirmation(
            id: '2',
            text: 'Test 2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        when(() => mockBox.values).thenReturn(affirmations);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result, equals(affirmations));
        expect(result.length, equals(2));
      });

      test('should return empty list when box is empty', () async {
        // Arrange
        when(() => mockBox.values).thenReturn([]);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getActive', () {
      test('should return only active affirmations', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: '1',
            text: 'Active',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
          ),
          Affirmation(
            id: '2',
            text: 'Inactive',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: false,
          ),
        ];
        when(() => mockBox.values).thenReturn(affirmations);

        // Act
        final result = await repository.getActive();

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals('1'));
        expect(result.first.isActive, isTrue);
      });
    });

    group('getById', () {
      test('should return affirmation when found', () async {
        // Arrange
        final affirmation = Affirmation(
          id: '1',
          text: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockBox.values).thenReturn([affirmation]);

        // Act
        final result = await repository.getById('1');

        // Assert
        expect(result, equals(affirmation));
      });

      test('should return null when not found', () async {
        // Arrange
        when(() => mockBox.values).thenReturn([]);

        // Act
        final result = await repository.getById('nonexistent');

        // Assert
        expect(result, isNull);
      });
    });

    group('create', () {
      test('should create affirmation with generated id when id is empty', () async {
        // Arrange
        final affirmation = Affirmation(
          id: '',
          text: 'New affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockUuid.v4()).thenReturn('generated-uuid');
        when(() => mockBox.values).thenReturn([]); // Empty box for sortOrder calculation
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        final result = await repository.create(affirmation);

        // Assert
        expect(result.id, equals('generated-uuid'));
        expect(result.text, equals('New affirmation'));
        expect(result.sortOrder, equals(0)); // First item gets sortOrder 0
        verify(() => mockBox.put('generated-uuid', any())).called(1);
      });

      test('should use provided id when not empty', () async {
        // Arrange
        final affirmation = Affirmation(
          id: 'my-custom-id',
          text: 'New affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockBox.values).thenReturn([]); // Empty box for sortOrder calculation
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        final result = await repository.create(affirmation);

        // Assert
        expect(result.id, equals('my-custom-id'));
        verify(() => mockBox.put('my-custom-id', any())).called(1);
        verifyNever(() => mockUuid.v4());
      });

      test('should assign next sortOrder when box has existing items', () async {
        // Arrange
        final existingAffirmation = Affirmation(
          id: '1',
          text: 'Existing',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sortOrder: 5,
        );
        final newAffirmation = Affirmation(
          id: '',
          text: 'New affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockUuid.v4()).thenReturn('generated-uuid');
        when(() => mockBox.values).thenReturn([existingAffirmation]);
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        final result = await repository.create(newAffirmation);

        // Assert
        expect(result.sortOrder, equals(6)); // max(5) + 1
      });
    });

    group('update', () {
      test('should update affirmation and set updatedAt', () async {
        // Arrange
        final originalTime = DateTime(2024, 1, 1);
        final affirmation = Affirmation(
          id: '1',
          text: 'Updated text',
          createdAt: originalTime,
          updatedAt: originalTime,
        );
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        final result = await repository.update(affirmation);

        // Assert
        expect(result.id, equals('1'));
        expect(result.text, equals('Updated text'));
        expect(result.updatedAt.isAfter(originalTime), isTrue);
        verify(() => mockBox.put('1', any())).called(1);
      });
    });

    group('delete', () {
      test('should delete affirmation and return true when found', () async {
        // Arrange
        final affirmation = Affirmation(
          id: '1',
          text: 'To delete',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockBox.values).thenReturn([affirmation]);
        when(() => mockBox.delete('1')).thenAnswer((_) async {});

        // Act
        final result = await repository.delete('1');

        // Assert
        expect(result, isTrue);
        verify(() => mockBox.delete('1')).called(1);
      });

      test('should return false when affirmation not found', () async {
        // Arrange
        when(() => mockBox.values).thenReturn([]);

        // Act
        final result = await repository.delete('nonexistent');

        // Assert
        expect(result, isFalse);
        verifyNever(() => mockBox.delete(any()));
      });
    });

    group('deleteAll', () {
      test('should clear all affirmations from box', () async {
        // Arrange
        when(() => mockBox.clear()).thenAnswer((_) async => 0);

        // Act
        await repository.deleteAll();

        // Assert
        verify(() => mockBox.clear()).called(1);
      });
    });

    group('count', () {
      test('should return number of affirmations in box', () async {
        // Arrange
        when(() => mockBox.length).thenReturn(5);

        // Act
        final result = await repository.count();

        // Assert
        expect(result, equals(5));
      });
    });
  });
}
