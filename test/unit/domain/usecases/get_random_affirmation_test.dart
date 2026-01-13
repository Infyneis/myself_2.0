/// Unit tests for GetRandomAffirmation use case.
///
/// Tests the business logic for selecting random affirmations
/// with repetition avoidance per REQUIREMENTS.md FR-008, FR-014.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/get_random_affirmation.dart';
import 'package:myself_2_0/core/utils/random_selector.dart';

class MockAffirmationRepository extends Mock implements AffirmationRepository {}

class MockRandomSelector extends Mock implements RandomSelector {}

/// A mock Random that always returns a specific value.
class MockRandom implements Random {
  MockRandom(this._nextIntValue);

  final int _nextIntValue;

  @override
  int nextInt(int max) => _nextIntValue < max ? _nextIntValue : 0;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0.0;
}

void main() {
  late MockAffirmationRepository mockRepository;
  late GetRandomAffirmation useCase;

  setUp(() {
    mockRepository = MockAffirmationRepository();
  });

  Affirmation createAffirmation({
    required String id,
    required String text,
    bool isActive = true,
  }) {
    final now = DateTime.now();
    return Affirmation(
      id: id,
      text: text,
      createdAt: now,
      updatedAt: now,
      isActive: isActive,
    );
  }

  group('GetRandomAffirmation', () {
    group('when no affirmations exist', () {
      test('should return null when repository returns empty list', () async {
        when(() => mockRepository.getActive()).thenAnswer((_) async => []);

        useCase = GetRandomAffirmation(repository: mockRepository);
        final result = await useCase.call();

        expect(result, isNull);
        verify(() => mockRepository.getActive()).called(1);
      });
    });

    group('when one affirmation exists', () {
      test('should return the only active affirmation', () async {
        final affirmation = createAffirmation(
          id: 'single-id',
          text: 'I am confident',
        );
        when(() => mockRepository.getActive())
            .thenAnswer((_) async => [affirmation]);

        useCase = GetRandomAffirmation(repository: mockRepository);
        final result = await useCase.call();

        expect(result, equals(affirmation));
        expect(result?.id, equals('single-id'));
      });

      test(
          'should return the only affirmation even when lastDisplayedId matches',
          () async {
        final affirmation = createAffirmation(
          id: 'single-id',
          text: 'I am confident',
        );
        when(() => mockRepository.getActive())
            .thenAnswer((_) async => [affirmation]);

        useCase = GetRandomAffirmation(repository: mockRepository);
        final result = await useCase.call(lastDisplayedId: 'single-id');

        // When there's only one affirmation, it should still be returned
        // even if it was the last displayed (edge case)
        expect(result, equals(affirmation));
      });
    });

    group('when multiple affirmations exist', () {
      late List<Affirmation> affirmations;

      setUp(() {
        affirmations = [
          createAffirmation(id: 'id-1', text: 'I am confident'),
          createAffirmation(id: 'id-2', text: 'I am capable'),
          createAffirmation(id: 'id-3', text: 'I am strong'),
        ];
        when(() => mockRepository.getActive())
            .thenAnswer((_) async => affirmations);
      });

      test('should return a random affirmation', () async {
        // Use deterministic random for testing
        final randomSelector = RandomSelector(random: MockRandom(0));
        useCase = GetRandomAffirmation(
          repository: mockRepository,
          randomSelector: randomSelector,
        );

        final result = await useCase.call();

        expect(result, isNotNull);
        expect(result?.id, equals('id-1'));
      });

      test('should avoid returning lastDisplayedId when possible', () async {
        // Use deterministic random for testing - will select index 0 from available pool
        final randomSelector = RandomSelector(random: MockRandom(0));
        useCase = GetRandomAffirmation(
          repository: mockRepository,
          randomSelector: randomSelector,
        );

        final result = await useCase.call(lastDisplayedId: 'id-1');

        // After excluding 'id-1', available pool is ['id-2', 'id-3']
        // MockRandom(0) selects first item: 'id-2'
        expect(result, isNotNull);
        expect(result?.id, equals('id-2'));
        expect(result?.id, isNot(equals('id-1')));
      });

      test('should not return the same affirmation twice in a row', () async {
        useCase = GetRandomAffirmation(repository: mockRepository);

        // Run multiple selections to verify exclusion logic
        for (var i = 0; i < 50; i++) {
          final result = await useCase.call(lastDisplayedId: 'id-1');

          expect(result, isNotNull);
          expect(result?.id, isNot(equals('id-1')));
        }
      });

      test('should handle null lastDisplayedId', () async {
        final randomSelector = RandomSelector(random: MockRandom(1));
        useCase = GetRandomAffirmation(
          repository: mockRepository,
          randomSelector: randomSelector,
        );

        final result = await useCase.call(lastDisplayedId: null);

        // All items available, MockRandom(1) selects index 1
        expect(result, isNotNull);
        expect(result?.id, equals('id-2'));
      });
    });

    group('only active affirmations are considered', () {
      test('should only use active affirmations', () async {
        // The use case should call getActive(), not getAll()
        when(() => mockRepository.getActive()).thenAnswer((_) async => [
              createAffirmation(id: 'active-1', text: 'Active'),
            ]);

        useCase = GetRandomAffirmation(repository: mockRepository);
        await useCase.call();

        verify(() => mockRepository.getActive()).called(1);
        verifyNever(() => mockRepository.getAll());
      });
    });

    group('with two affirmations', () {
      test('should always return the other affirmation when one is excluded',
          () async {
        final affirmations = [
          createAffirmation(id: 'id-1', text: 'First'),
          createAffirmation(id: 'id-2', text: 'Second'),
        ];
        when(() => mockRepository.getActive())
            .thenAnswer((_) async => affirmations);

        useCase = GetRandomAffirmation(repository: mockRepository);

        // Run multiple times to ensure it always returns the other one
        for (var i = 0; i < 20; i++) {
          final result = await useCase.call(lastDisplayedId: 'id-1');
          expect(result?.id, equals('id-2'));
        }
      });
    });

    group('edge cases', () {
      test('should handle affirmation with empty text', () async {
        // Note: In practice, this shouldn't happen due to validation,
        // but the use case should handle it gracefully
        final affirmation = createAffirmation(id: 'empty-text', text: '');
        when(() => mockRepository.getActive())
            .thenAnswer((_) async => [affirmation]);

        useCase = GetRandomAffirmation(repository: mockRepository);
        final result = await useCase.call();

        expect(result, isNotNull);
        expect(result?.id, equals('empty-text'));
      });

      test('should handle very long affirmation text', () async {
        final longText = 'A' * 280;
        final affirmation = createAffirmation(id: 'long-text', text: longText);
        when(() => mockRepository.getActive())
            .thenAnswer((_) async => [affirmation]);

        useCase = GetRandomAffirmation(repository: mockRepository);
        final result = await useCase.call();

        expect(result, isNotNull);
        expect(result?.text.length, equals(280));
      });

      test('should handle excludeId that does not exist in list', () async {
        final affirmations = [
          createAffirmation(id: 'id-1', text: 'First'),
          createAffirmation(id: 'id-2', text: 'Second'),
        ];
        when(() => mockRepository.getActive())
            .thenAnswer((_) async => affirmations);

        final randomSelector = RandomSelector(random: MockRandom(0));
        useCase = GetRandomAffirmation(
          repository: mockRepository,
          randomSelector: randomSelector,
        );

        // 'non-existent' is not in the list, so all items should be available
        final result = await useCase.call(lastDisplayedId: 'non-existent');

        expect(result, isNotNull);
        expect(result?.id, equals('id-1'));
      });
    });

    group('custom RandomSelector injection', () {
      test('should use injected RandomSelector', () async {
        final mockRandomSelector = MockRandomSelector();
        final affirmation = createAffirmation(id: 'id-1', text: 'Test');
        final affirmations = [affirmation];

        when(() => mockRepository.getActive())
            .thenAnswer((_) async => affirmations);
        when(() => mockRandomSelector.selectRandom<Affirmation>(
              items: affirmations,
              getId: any(named: 'getId'),
              excludeId: any(named: 'excludeId'),
            )).thenReturn(affirmation);

        useCase = GetRandomAffirmation(
          repository: mockRepository,
          randomSelector: mockRandomSelector,
        );

        final result = await useCase.call();

        expect(result, equals(affirmation));
        verify(() => mockRandomSelector.selectRandom<Affirmation>(
              items: affirmations,
              getId: any(named: 'getId'),
              excludeId: any(named: 'excludeId'),
            )).called(1);
      });
    });

    group('repository error handling', () {
      test('should propagate repository exceptions', () async {
        when(() => mockRepository.getActive())
            .thenThrow(Exception('Database error'));

        useCase = GetRandomAffirmation(repository: mockRepository);

        expect(
          () => useCase.call(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('statistical distribution', () {
      test('should eventually select all available affirmations (fairness)',
          () async {
        final affirmations = [
          createAffirmation(id: 'id-1', text: 'First'),
          createAffirmation(id: 'id-2', text: 'Second'),
          createAffirmation(id: 'id-3', text: 'Third'),
        ];
        when(() => mockRepository.getActive())
            .thenAnswer((_) async => affirmations);

        useCase = GetRandomAffirmation(repository: mockRepository);

        final selectedIds = <String>{};

        // Run enough iterations to expect all items to be selected
        for (var i = 0; i < 100; i++) {
          final result = await useCase.call();
          if (result != null) {
            selectedIds.add(result.id);
          }
        }

        // All affirmations should have been selected at least once
        expect(selectedIds, containsAll(['id-1', 'id-2', 'id-3']));
      });
    });
  });
}
