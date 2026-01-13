/// Unit tests for RandomSelector utility.
///
/// Tests the random selection logic with repetition avoidance.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/utils/random_selector.dart';

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
  group('RandomSelector', () {
    group('selectRandom', () {
      test('should return null when items list is empty', () {
        final selector = RandomSelector();
        final result = selector.selectRandom<String>(
          items: [],
          getId: (item) => item,
        );

        expect(result, isNull);
      });

      test('should return the only item when list has one item', () {
        final selector = RandomSelector();
        final result = selector.selectRandom<String>(
          items: ['only-item'],
          getId: (item) => item,
        );

        expect(result, equals('only-item'));
      });

      test(
          'should return the only item even when it matches excludeId (edge case)',
          () {
        final selector = RandomSelector();
        final result = selector.selectRandom<String>(
          items: ['only-item'],
          getId: (item) => item,
          excludeId: 'only-item',
        );

        expect(result, equals('only-item'));
      });

      test('should select a random item from the list', () {
        // Use mock random to make test deterministic
        final selector = RandomSelector(random: MockRandom(0));
        final items = ['item-1', 'item-2', 'item-3'];

        final result = selector.selectRandom<String>(
          items: items,
          getId: (item) => item,
        );

        expect(result, equals('item-1'));
      });

      test('should exclude the item matching excludeId', () {
        // When we exclude 'item-1', only 'item-2' and 'item-3' remain
        // MockRandom(0) will select the first item from available pool
        final selector = RandomSelector(random: MockRandom(0));
        final items = ['item-1', 'item-2', 'item-3'];

        final result = selector.selectRandom<String>(
          items: items,
          getId: (item) => item,
          excludeId: 'item-1',
        );

        expect(result, equals('item-2'));
      });

      test('should not return excluded item when others are available', () {
        final selector = RandomSelector();
        final items = ['item-1', 'item-2', 'item-3'];

        // Run multiple times to ensure excluded item is never returned
        for (var i = 0; i < 100; i++) {
          final result = selector.selectRandom<String>(
            items: items,
            getId: (item) => item,
            excludeId: 'item-1',
          );

          expect(result, isNot(equals('item-1')));
          expect(['item-2', 'item-3'], contains(result));
        }
      });

      test(
          'should work with custom getId function for complex objects',
          () {
        final selector = RandomSelector(random: MockRandom(1));

        final items = [
          {'id': 'a', 'name': 'Item A'},
          {'id': 'b', 'name': 'Item B'},
          {'id': 'c', 'name': 'Item C'},
        ];

        final result = selector.selectRandom<Map<String, String>>(
          items: items,
          getId: (item) => item['id']!,
          excludeId: 'a',
        );

        // After excluding 'a', we have ['b', 'c']
        // MockRandom(1) selects index 1, which is 'c'
        expect(result?['id'], equals('c'));
      });

      test('should handle null excludeId gracefully', () {
        final selector = RandomSelector(random: MockRandom(0));
        final items = ['item-1', 'item-2'];

        final result = selector.selectRandom<String>(
          items: items,
          getId: (item) => item,
          excludeId: null,
        );

        expect(result, equals('item-1'));
      });

      test('should handle excludeId not in list gracefully', () {
        final selector = RandomSelector(random: MockRandom(0));
        final items = ['item-1', 'item-2'];

        final result = selector.selectRandom<String>(
          items: items,
          getId: (item) => item,
          excludeId: 'non-existent',
        );

        // All items remain available, MockRandom(0) selects first
        expect(result, equals('item-1'));
      });

      test('should fall back to original list when all items are excluded', () {
        final selector = RandomSelector(random: MockRandom(0));
        final items = ['item-1'];

        // This simulates the edge case where the only item matches excludeId
        // The implementation should fall back to the original list
        final result = selector.selectRandom<String>(
          items: items,
          getId: (item) => item,
          excludeId: 'item-1',
        );

        expect(result, equals('item-1'));
      });
    });

    group('nextInt', () {
      test('should return value within range', () {
        final selector = RandomSelector(random: MockRandom(5));

        final result = selector.nextInt(0, 10);

        expect(result, equals(5));
      });

      test('should respect minimum value', () {
        final selector = RandomSelector(random: MockRandom(3));

        final result = selector.nextInt(5, 10);

        // 5 + 3 = 8
        expect(result, equals(8));
      });
    });
  });
}
