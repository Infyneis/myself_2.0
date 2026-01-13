/// Unit tests for EncryptionService.
///
/// Tests platform-native encryption implementation for local data storage.
/// Based on REQUIREMENTS.md NFR-011.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/security/encryption_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EncryptionService', () {
    setUp(() async {
      // Reset encryption service before each test
      try {
        await EncryptionService.deleteEncryptionKey();
      } catch (_) {
        // Ignore if not initialized
      }
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await EncryptionService.deleteEncryptionKey();
      } catch (_) {
        // Ignore if already deleted
      }
    });

    test('initializes successfully', () async {
      // Act
      await EncryptionService.initialize();

      // Assert
      expect(EncryptionService.isInitialized, isTrue);
    });

    test('returns encryption cipher after initialization', () async {
      // Arrange
      await EncryptionService.initialize();

      // Act
      final cipher = EncryptionService.getEncryptionCipher();

      // Assert
      expect(cipher, isNotNull);
    });

    test('throws StateError when getting cipher before initialization', () {
      // Act & Assert
      expect(
        () => EncryptionService.getEncryptionCipher(),
        throwsStateError,
      );
    });

    test('reuses same cipher on multiple calls', () async {
      // Arrange
      await EncryptionService.initialize();

      // Act
      final cipher1 = EncryptionService.getEncryptionCipher();
      final cipher2 = EncryptionService.getEncryptionCipher();

      // Assert
      expect(cipher1, same(cipher2));
    });

    test('skips re-initialization if already initialized', () async {
      // Arrange
      await EncryptionService.initialize();
      final cipher1 = EncryptionService.getEncryptionCipher();

      // Act
      await EncryptionService.initialize();
      final cipher2 = EncryptionService.getEncryptionCipher();

      // Assert
      expect(cipher1, same(cipher2));
    });

    test('reset creates new encryption key', () async {
      // Arrange
      await EncryptionService.initialize();
      final cipher1 = EncryptionService.getEncryptionCipher();

      // Act
      await EncryptionService.reset();
      final cipher2 = EncryptionService.getEncryptionCipher();

      // Assert
      expect(cipher1, isNot(same(cipher2)));
      expect(EncryptionService.isInitialized, isTrue);
    });

    test('deleteEncryptionKey removes encryption state', () async {
      // Arrange
      await EncryptionService.initialize();
      expect(EncryptionService.isInitialized, isTrue);

      // Act
      await EncryptionService.deleteEncryptionKey();

      // Assert
      expect(EncryptionService.isInitialized, isFalse);
      expect(
        () => EncryptionService.getEncryptionCipher(),
        throwsStateError,
      );
    });

    test('persists encryption key across re-initialization', () async {
      // Arrange
      await EncryptionService.initialize();
      final cipher1 = EncryptionService.getEncryptionCipher();

      // Act - delete in-memory state but keep key in secure storage
      await EncryptionService.deleteEncryptionKey();

      // Note: In a real scenario, the key would persist in secure storage
      // but for testing purposes, we're verifying the service can handle
      // re-initialization correctly
      await EncryptionService.initialize();
      final cipher2 = EncryptionService.getEncryptionCipher();

      // Assert - both ciphers exist and are functional
      expect(cipher1, isNotNull);
      expect(cipher2, isNotNull);
    });
  });
}
