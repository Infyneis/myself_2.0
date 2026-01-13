/// Encryption service for secure local data storage.
///
/// Provides platform-native encryption for Hive database using AES-256
/// encryption with securely stored keys.
/// Based on REQUIREMENTS.md NFR-011.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// Service for managing encryption keys and providing Hive encryption cipher.
///
/// This service implements platform-native encryption for local data storage:
/// - iOS: Uses Keychain for secure key storage
/// - Android: Uses KeyStore for secure key storage
/// - AES-256 encryption for Hive database
///
/// Usage:
/// ```dart
/// await EncryptionService.initialize();
/// final cipher = await EncryptionService.getEncryptionCipher();
/// final box = await Hive.openBox('myBox', encryptionCipher: cipher);
/// ```
class EncryptionService {
  EncryptionService._();

  /// Key name for storing the encryption key in secure storage.
  static const String _encryptionKeyName = 'hive_encryption_key_v1';

  /// Secure storage instance for storing encryption keys.
  ///
  /// Platform-specific implementations:
  /// - iOS: Uses Keychain
  /// - Android: Uses KeyStore with custom cipher for encryption
  /// - Linux: Uses Secret Service API / libsecret
  /// - Windows: Uses Credential Manager
  /// - Web: Uses localStorage (not truly secure, but encrypted)
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static HiveCipher? _encryptionCipher;
  static bool _initialized = false;

  /// Whether encryption has been initialized.
  static bool get isInitialized => _initialized;

  /// Initializes the encryption service.
  ///
  /// This method must be called before using [getEncryptionCipher].
  /// It generates or retrieves the encryption key and creates the cipher.
  ///
  /// Performance optimization:
  /// - Key is cached in memory after first retrieval
  /// - Subsequent calls return immediately if already initialized
  ///
  /// Throws [Exception] if encryption initialization fails.
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('EncryptionService: Already initialized, skipping.');
      return;
    }

    try {
      // Get or generate encryption key
      final encryptionKey = await _getOrGenerateEncryptionKey();

      // Create Hive AES cipher with 256-bit key
      _encryptionCipher = HiveAesCipher(encryptionKey);

      _initialized = true;
      debugPrint('EncryptionService: Initialized with AES-256 encryption.');
    } catch (e, stackTrace) {
      debugPrint('EncryptionService: Initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Gets the encryption cipher for Hive boxes.
  ///
  /// This cipher should be passed to Hive.openBox to enable encryption.
  ///
  /// Throws [StateError] if encryption has not been initialized.
  static HiveCipher getEncryptionCipher() {
    if (!_initialized || _encryptionCipher == null) {
      throw StateError(
        'Encryption has not been initialized. '
        'Call EncryptionService.initialize() first.',
      );
    }
    return _encryptionCipher!;
  }

  /// Gets an existing encryption key or generates a new one.
  ///
  /// The encryption key is:
  /// - 256 bits (32 bytes) for AES-256
  /// - Stored securely using platform-native secure storage
  /// - Generated using cryptographically secure random number generator
  ///
  /// Returns a [Uint8List] containing the 256-bit encryption key.
  static Future<Uint8List> _getOrGenerateEncryptionKey() async {
    try {
      // Try to retrieve existing key
      final existingKey = await _secureStorage.read(key: _encryptionKeyName);

      if (existingKey != null) {
        debugPrint('EncryptionService: Retrieved existing encryption key.');
        // Decode from base64
        return base64Url.decode(existingKey);
      }

      // Generate new key if none exists
      debugPrint('EncryptionService: Generating new encryption key.');
      final newKey = _generateSecureKey();

      // Store the key securely (encoded as base64)
      final encodedKey = base64Url.encode(newKey);
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: encodedKey,
      );

      debugPrint('EncryptionService: New encryption key generated and stored.');
      return newKey;
    } catch (e) {
      debugPrint('EncryptionService: Failed to get or generate key: $e');
      rethrow;
    }
  }

  /// Generates a cryptographically secure 256-bit encryption key.
  ///
  /// Uses Hive's built-in secure random number generator.
  static Uint8List _generateSecureKey() {
    // Generate 256-bit (32 bytes) key for AES-256
    final key = Hive.generateSecureKey();
    return Uint8List.fromList(key);
  }

  /// Deletes the encryption key from secure storage.
  ///
  /// WARNING: This will make all encrypted data unrecoverable.
  /// Only use this for testing or when resetting the app completely.
  static Future<void> deleteEncryptionKey() async {
    try {
      await _secureStorage.delete(key: _encryptionKeyName);
      _encryptionCipher = null;
      _initialized = false;
      debugPrint('EncryptionService: Encryption key deleted.');
    } catch (e) {
      debugPrint('EncryptionService: Failed to delete key: $e');
      rethrow;
    }
  }

  /// Resets the encryption service and generates a new key.
  ///
  /// WARNING: This will make all encrypted data unrecoverable.
  /// Only use this for testing or when resetting the app completely.
  static Future<void> reset() async {
    await deleteEncryptionKey();
    await initialize();
    debugPrint('EncryptionService: Reset complete with new encryption key.');
  }
}
