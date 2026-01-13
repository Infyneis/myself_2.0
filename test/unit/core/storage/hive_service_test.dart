import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:myself_2_0/core/storage/hive_service.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // Create a temporary directory for Hive in tests
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(affirmationTypeId)) {
      Hive.registerAdapter(AffirmationAdapter());
    }
  });

  tearDownAll(() async {
    // Clean up
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Affirmation Model', () {
    test('should create Affirmation with required fields', () {
      final now = DateTime.now();
      final affirmation = Affirmation(
        id: 'test-uuid-123',
        text: 'I am confident and capable.',
        createdAt: now,
        updatedAt: now,
      );

      expect(affirmation.id, 'test-uuid-123');
      expect(affirmation.text, 'I am confident and capable.');
      expect(affirmation.createdAt, now);
      expect(affirmation.updatedAt, now);
      expect(affirmation.displayCount, 0);
      expect(affirmation.isActive, true);
    });

    test('should create Affirmation with all fields', () {
      final created = DateTime(2024, 1, 1);
      final updated = DateTime(2024, 1, 2);
      final affirmation = Affirmation(
        id: 'test-uuid-456',
        text: 'I embrace positive change.',
        createdAt: created,
        updatedAt: updated,
        displayCount: 5,
        isActive: false,
      );

      expect(affirmation.id, 'test-uuid-456');
      expect(affirmation.text, 'I embrace positive change.');
      expect(affirmation.createdAt, created);
      expect(affirmation.updatedAt, updated);
      expect(affirmation.displayCount, 5);
      expect(affirmation.isActive, false);
    });

    test('copyWith should create new instance with updated fields', () {
      final now = DateTime.now();
      final original = Affirmation(
        id: 'test-uuid-789',
        text: 'Original text',
        createdAt: now,
        updatedAt: now,
      );

      final newUpdatedAt = DateTime.now().add(const Duration(hours: 1));
      final updated = original.copyWith(
        text: 'Updated text',
        updatedAt: newUpdatedAt,
        displayCount: 1,
      );

      // Verify original is unchanged
      expect(original.text, 'Original text');
      expect(original.displayCount, 0);

      // Verify updated has new values
      expect(updated.id, original.id);
      expect(updated.text, 'Updated text');
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt, newUpdatedAt);
      expect(updated.displayCount, 1);
      expect(updated.isActive, original.isActive);
    });

    test('equality should work correctly', () {
      final now = DateTime.now();
      final affirmation1 = Affirmation(
        id: 'same-id',
        text: 'Same text',
        createdAt: now,
        updatedAt: now,
      );
      final affirmation2 = Affirmation(
        id: 'same-id',
        text: 'Same text',
        createdAt: now,
        updatedAt: now,
      );
      final affirmation3 = Affirmation(
        id: 'different-id',
        text: 'Same text',
        createdAt: now,
        updatedAt: now,
      );

      expect(affirmation1, equals(affirmation2));
      expect(affirmation1, isNot(equals(affirmation3)));
    });

    test('toString should return formatted string', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final affirmation = Affirmation(
        id: 'test-id',
        text: 'Test affirmation',
        createdAt: now,
        updatedAt: now,
      );

      final result = affirmation.toString();
      expect(result, contains('Affirmation'));
      expect(result, contains('test-id'));
      expect(result, contains('Test affirmation'));
    });
  });

  group('AffirmationAdapter', () {
    late Box<Affirmation> testBox;

    setUp(() async {
      testBox = await Hive.openBox<Affirmation>('test_affirmations_box');
    });

    tearDown(() async {
      await testBox.clear();
      await testBox.close();
    });

    test('should store and retrieve Affirmation', () async {
      final now = DateTime.now();
      final affirmation = Affirmation(
        id: 'hive-test-1',
        text: 'I persist through challenges.',
        createdAt: now,
        updatedAt: now,
        displayCount: 3,
        isActive: true,
      );

      await testBox.put(affirmation.id, affirmation);

      final retrieved = testBox.get(affirmation.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, affirmation.id);
      expect(retrieved.text, affirmation.text);
      expect(retrieved.displayCount, 3);
      expect(retrieved.isActive, true);
    });

    test('should store multiple affirmations', () async {
      final now = DateTime.now();
      final affirmations = List.generate(
        5,
        (i) => Affirmation(
          id: 'multi-test-$i',
          text: 'Affirmation number $i',
          createdAt: now,
          updatedAt: now,
        ),
      );

      for (final affirmation in affirmations) {
        await testBox.put(affirmation.id, affirmation);
      }

      expect(testBox.length, 5);

      for (var i = 0; i < 5; i++) {
        final retrieved = testBox.get('multi-test-$i');
        expect(retrieved?.text, 'Affirmation number $i');
      }
    });

    test('should update existing affirmation', () async {
      final now = DateTime.now();
      final original = Affirmation(
        id: 'update-test',
        text: 'Original',
        createdAt: now,
        updatedAt: now,
      );

      await testBox.put(original.id, original);

      final updated = original.copyWith(
        text: 'Updated',
        updatedAt: DateTime.now(),
        displayCount: 1,
      );
      await testBox.put(updated.id, updated);

      final retrieved = testBox.get('update-test');
      expect(retrieved?.text, 'Updated');
      expect(retrieved?.displayCount, 1);
    });

    test('should delete affirmation', () async {
      final now = DateTime.now();
      final affirmation = Affirmation(
        id: 'delete-test',
        text: 'To be deleted',
        createdAt: now,
        updatedAt: now,
      );

      await testBox.put(affirmation.id, affirmation);
      expect(testBox.containsKey('delete-test'), true);

      await testBox.delete('delete-test');
      expect(testBox.containsKey('delete-test'), false);
    });
  });

  group('HiveBoxNames', () {
    test('should have correct box names', () {
      expect(HiveBoxNames.affirmations, 'affirmations');
      expect(HiveBoxNames.settings, 'settings');
      expect(HiveBoxNames.appState, 'appState');
    });
  });
}
