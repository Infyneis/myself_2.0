/// Unit tests for HiveService - Data Persistence Layer
///
/// Tests the Hive-backed data persistence layer including:
/// - Service initialization and lifecycle
/// - Box management (lazy opening, multiple boxes)
/// - Data persistence and retrieval
/// - Error handling and state management
/// - Affirmation model and adapter functionality
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:myself_2_0/core/storage/hive_service.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    // Create a temporary directory for Hive in tests
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(affirmationTypeId)) {
      Hive.registerAdapter(AffirmationAdapter());
    }

    // Mock flutter_secure_storage for EncryptionService
    const MethodChannel secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        // Return null to simulate first-time key generation
        return null;
      } else if (methodCall.method == 'write') {
        // Simulate successful write
        return null;
      } else if (methodCall.method == 'delete') {
        // Simulate successful delete
        return null;
      }
      return null;
    });

    // Mock path_provider for getApplicationDocumentsDirectory
    const MethodChannel pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });
  });

  tearDownAll(() async {
    // Clean up
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('HiveService - Data Persistence Layer', () {
    tearDown(() async {
      // Clear all data before closing to ensure clean state between tests
      try {
        if (HiveService.isInitialized) {
          await HiveService.clearAll();
        }
      } catch (e) {
        // Ignore if boxes are not open
      }
      // Close HiveService after each test to ensure clean state
      await HiveService.close();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Act
        await HiveService.initialize();

        // Assert
        expect(HiveService.isInitialized, isTrue);
      });

      test('should be idempotent - multiple initializations should not fail', () async {
        // Act
        await HiveService.initialize();
        await HiveService.initialize();
        await HiveService.initialize();

        // Assert
        expect(HiveService.isInitialized, isTrue);
      });

      test('should reset state after close', () async {
        // Arrange
        await HiveService.initialize();
        expect(HiveService.isInitialized, isTrue);

        // Act
        await HiveService.close();

        // Assert
        expect(HiveService.isInitialized, isFalse);
      });
    });

    group('Box Management - Lazy Opening', () {
      test('affirmationsBox should throw StateError when not initialized', () async {
        // Assert
        expect(
          () => HiveService.affirmationsBox,
          throwsA(isA<StateError>()),
        );
      });

      test('settingsBox should throw StateError when not initialized', () async {
        // Assert
        expect(
          () => HiveService.settingsBox,
          throwsA(isA<StateError>()),
        );
      });

      test('appStateBox should throw StateError when not initialized', () async {
        // Assert
        expect(
          () => HiveService.appStateBox,
          throwsA(isA<StateError>()),
        );
      });

      test('should open affirmationsBox lazily after initialization', () async {
        // Arrange
        await HiveService.initialize();

        // Act
        final box = await HiveService.affirmationsBox;

        // Assert
        expect(box, isNotNull);
        expect(box.isOpen, isTrue);
        expect(box.name, equals(HiveBoxNames.affirmations));
      });

      test('should open settingsBox lazily after initialization', () async {
        // Arrange
        await HiveService.initialize();

        // Act
        final box = await HiveService.settingsBox;

        // Assert
        expect(box, isNotNull);
        expect(box.isOpen, isTrue);
        expect(box.name, equals(HiveBoxNames.settings));
      });

      test('should open appStateBox lazily after initialization', () async {
        // Arrange
        await HiveService.initialize();

        // Act
        final box = await HiveService.appStateBox;

        // Assert
        expect(box, isNotNull);
        expect(box.isOpen, isTrue);
        // Note: Hive converts box names to lowercase internally
        expect(box.name.toLowerCase(), equals(HiveBoxNames.appState.toLowerCase()));
      });

      test('should return same box instance on multiple accesses', () async {
        // Arrange
        await HiveService.initialize();

        // Act
        final box1 = await HiveService.affirmationsBox;
        final box2 = await HiveService.affirmationsBox;

        // Assert
        expect(identical(box1, box2), isTrue);
      });

      test('should reopen box if it was closed', () async {
        // Arrange
        await HiveService.initialize();
        final box1 = await HiveService.affirmationsBox;
        await box1.close();

        // Act
        final box2 = await HiveService.affirmationsBox;

        // Assert
        expect(box2.isOpen, isTrue);
        expect(box2.name, equals(HiveBoxNames.affirmations));
      });
    });

    group('Data Persistence - Affirmations Box', () {
      test('should persist affirmation data', () async {
        // Arrange
        await HiveService.initialize();
        final box = await HiveService.affirmationsBox;
        final now = DateTime.now();
        final affirmation = Affirmation(
          id: 'persist-test-1',
          text: 'I persist data successfully',
          createdAt: now,
          updatedAt: now,
        );

        // Act
        await box.put(affirmation.id, affirmation);
        final retrieved = box.get('persist-test-1');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('persist-test-1'));
        expect(retrieved.text, equals('I persist data successfully'));
        expect(retrieved.createdAt, equals(now));
        expect(retrieved.updatedAt, equals(now));
      });

      test('should persist multiple affirmations', () async {
        // Arrange
        await HiveService.initialize();
        final box = await HiveService.affirmationsBox;
        final now = DateTime.now();
        final affirmations = List.generate(
          10,
          (i) => Affirmation(
            id: 'multi-persist-$i',
            text: 'Affirmation $i',
            createdAt: now,
            updatedAt: now,
            displayCount: i,
          ),
        );

        // Act
        for (final affirmation in affirmations) {
          await box.put(affirmation.id, affirmation);
        }

        // Assert
        expect(box.length, equals(10));
        for (var i = 0; i < 10; i++) {
          final retrieved = box.get('multi-persist-$i');
          expect(retrieved?.text, equals('Affirmation $i'));
          expect(retrieved?.displayCount, equals(i));
        }
      });

      test('should update existing affirmation', () async {
        // Arrange
        await HiveService.initialize();
        final box = await HiveService.affirmationsBox;
        final now = DateTime.now();
        final original = Affirmation(
          id: 'update-persist',
          text: 'Original text',
          createdAt: now,
          updatedAt: now,
          displayCount: 0,
        );
        await box.put(original.id, original);

        // Act
        final updated = original.copyWith(
          text: 'Updated text',
          displayCount: 5,
        );
        await box.put(updated.id, updated);

        // Assert
        final retrieved = box.get('update-persist');
        expect(retrieved?.text, equals('Updated text'));
        expect(retrieved?.displayCount, equals(5));
        expect(box.length, equals(1)); // Should not create duplicate
      });

      test('should delete affirmation', () async {
        // Arrange
        await HiveService.initialize();
        final box = await HiveService.affirmationsBox;
        final now = DateTime.now();
        final affirmation = Affirmation(
          id: 'delete-persist',
          text: 'To be deleted',
          createdAt: now,
          updatedAt: now,
        );
        await box.put(affirmation.id, affirmation);
        expect(box.containsKey('delete-persist'), isTrue);

        // Act
        await box.delete('delete-persist');

        // Assert
        expect(box.containsKey('delete-persist'), isFalse);
        expect(box.get('delete-persist'), isNull);
      });

      test('should persist data across box close and reopen', () async {
        // Arrange
        await HiveService.initialize();
        final box1 = await HiveService.affirmationsBox;
        final now = DateTime.now();
        final affirmation = Affirmation(
          id: 'cross-session-test',
          text: 'Persists across sessions',
          createdAt: now,
          updatedAt: now,
        );
        await box1.put(affirmation.id, affirmation);
        await box1.close();

        // Act
        final box2 = await HiveService.affirmationsBox;
        final retrieved = box2.get('cross-session-test');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('cross-session-test'));
        expect(retrieved.text, equals('Persists across sessions'));
      });
    });

    group('Data Persistence - Settings Box', () {
      test('should persist settings data', () async {
        // Arrange
        await HiveService.initialize();
        final box = await HiveService.settingsBox;

        // Act
        await box.put('theme_mode', 'dark');
        await box.put('language', 'fr');
        await box.put('font_size', 1.5);

        // Assert
        expect(box.get('theme_mode'), equals('dark'));
        expect(box.get('language'), equals('fr'));
        expect(box.get('font_size'), equals(1.5));
      });

      test('should persist settings across box close and reopen', () async {
        // Arrange
        await HiveService.initialize();
        final box1 = await HiveService.settingsBox;
        await box1.put('theme_mode', 'light');
        await box1.put('refresh_mode', 'hourly');
        await box1.close();

        // Act
        final box2 = await HiveService.settingsBox;

        // Assert
        expect(box2.get('theme_mode'), equals('light'));
        expect(box2.get('refresh_mode'), equals('hourly'));
      });
    });

    group('Data Persistence - App State Box', () {
      test('should persist app state data', () async {
        // Arrange
        await HiveService.initialize();
        final box = await HiveService.appStateBox;

        // Act
        await box.put('onboarding_completed', true);
        await box.put('first_launch_date', DateTime.now().toIso8601String());

        // Assert
        expect(box.get('onboarding_completed'), isTrue);
        expect(box.get('first_launch_date'), isNotNull);
      });

      test('should persist app state across box close and reopen', () async {
        // Arrange
        await HiveService.initialize();
        final box1 = await HiveService.appStateBox;
        await box1.put('onboarding_completed', true);
        await box1.put('app_version', '1.0.0');
        await box1.close();

        // Act
        final box2 = await HiveService.appStateBox;

        // Assert
        expect(box2.get('onboarding_completed'), isTrue);
        expect(box2.get('app_version'), equals('1.0.0'));
      });
    });

    group('Clear and Delete Operations', () {
      test('clearAll should remove all data from all boxes', () async {
        // Arrange
        await HiveService.initialize();
        final affirmationsBox = await HiveService.affirmationsBox;
        final settingsBox = await HiveService.settingsBox;
        final appStateBox = await HiveService.appStateBox;

        // Add data to all boxes
        final now = DateTime.now();
        await affirmationsBox.put(
          'test',
          Affirmation(
            id: 'test',
            text: 'Test',
            createdAt: now,
            updatedAt: now,
          ),
        );
        await settingsBox.put('theme', 'dark');
        await appStateBox.put('onboarding', true);

        // Act
        await HiveService.clearAll();

        // Assert
        expect(affirmationsBox.isEmpty, isTrue);
        expect(settingsBox.isEmpty, isTrue);
        expect(appStateBox.isEmpty, isTrue);
      });

      test('clearAll should throw StateError when not initialized', () async {
        // Assert
        expect(
          () => HiveService.clearAll(),
          throwsA(isA<StateError>()),
        );
      });

      test('deleteFromDisk should remove database and reset state', () async {
        // Arrange
        await HiveService.initialize();
        expect(HiveService.isInitialized, isTrue);

        // Act
        await HiveService.deleteFromDisk();

        // Assert
        expect(HiveService.isInitialized, isFalse);
      });
    });
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
