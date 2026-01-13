// Unit tests for ExportAffirmationsUseCase.
//
// Tests the business logic for exporting affirmations to a text file with:
// - Successful export with affirmations
// - Proper file format and content
// - Error handling for empty affirmations
// - Repository failure handling
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/export_affirmations.dart';

// Mock classes
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

class MockDirectoryProvider extends Mock implements DirectoryProvider {}

void main() {
  late MockAffirmationRepository mockRepository;
  late MockDirectoryProvider mockDirectoryProvider;
  late ExportAffirmationsUseCase useCase;
  late Directory tempDir;

  setUpAll(() async {
    // Create a temporary directory for tests
    tempDir = await Directory.systemTemp.createTemp('export_test_');
  });

  tearDownAll(() async {
    // Clean up temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() {
    mockRepository = MockAffirmationRepository();
    mockDirectoryProvider = MockDirectoryProvider();
    useCase = ExportAffirmationsUseCase(
      repository: mockRepository,
      directoryProvider: mockDirectoryProvider,
    );
  });

  tearDown(() async {
    // Clean up any files created during tests
    final files = tempDir.listSync().whereType<File>();
    for (final file in files) {
      await file.delete();
    }
  });

  group('ExportAffirmationsUseCase', () {
    group('successful export', () {
      test('should export affirmations to a text file', () async {
        // Arrange
        final now = DateTime.now();
        final affirmations = [
          Affirmation(
            id: 'id-1',
            text: 'I am confident',
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 2)),
            sortOrder: 0,
          ),
          Affirmation(
            id: 'id-2',
            text: 'I am capable',
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
            sortOrder: 1,
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;
        expect(success.affirmationCount, equals(2));
        expect(success.filePath, contains(tempDir.path));
        expect(success.filePath, endsWith('.txt'));

        // Verify file was created
        final file = File(success.filePath);
        expect(await file.exists(), isTrue);

        // Verify file content
        final content = await file.readAsString();
        expect(content, contains('# My Affirmations'));
        expect(content, contains('# Total: 2 affirmation(s)'));
        expect(content, contains('I am confident'));
        expect(content, contains('I am capable'));
      });

      test('should use custom filename when provided', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: 'id-1',
            text: 'Test affirmation',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call(fileName: 'my_custom_export');

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;
        expect(success.filePath, contains('my_custom_export.txt'));
      });

      test('should generate timestamped filename when not provided', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: 'id-1',
            text: 'Test affirmation',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;
        expect(success.filePath, contains('affirmations_'));
        // Check for timestamp format YYYYMMDD_HHMMSS
        expect(
          RegExp(r'affirmations_\d{8}_\d{6}\.txt$').hasMatch(success.filePath),
          isTrue,
        );
      });

      test('should sort affirmations by sortOrder then createdAt', () async {
        // Arrange
        final now = DateTime.now();
        final affirmations = [
          Affirmation(
            id: 'id-3',
            text: 'Third (sorted last)',
            createdAt: now.subtract(const Duration(days: 3)),
            updatedAt: now.subtract(const Duration(days: 3)),
            sortOrder: 2,
          ),
          Affirmation(
            id: 'id-1',
            text: 'First (sorted first)',
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
            sortOrder: 0,
          ),
          Affirmation(
            id: 'id-2',
            text: 'Second (sorted middle)',
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 2)),
            sortOrder: 1,
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;

        final file = File(success.filePath);
        final content = await file.readAsString();

        // Verify order in file
        final firstIndex = content.indexOf('First (sorted first)');
        final secondIndex = content.indexOf('Second (sorted middle)');
        final thirdIndex = content.indexOf('Third (sorted last)');

        expect(firstIndex, lessThan(secondIndex));
        expect(secondIndex, lessThan(thirdIndex));
      });

      test('should include metadata in exported file', () async {
        // Arrange
        final createdAt = DateTime(2025, 1, 1, 10, 30);
        final updatedAt = DateTime(2025, 1, 2, 15, 45);
        final affirmations = [
          Affirmation(
            id: 'id-1',
            text: 'Active affirmation',
            createdAt: createdAt,
            updatedAt: updatedAt,
            isActive: true,
          ),
          Affirmation(
            id: 'id-2',
            text: 'Inactive affirmation',
            createdAt: createdAt,
            updatedAt: createdAt,
            isActive: false,
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;

        final file = File(success.filePath);
        final content = await file.readAsString();

        // Verify metadata comments
        expect(content, contains('# Created:'));
        expect(content, contains('# Active: Yes'));
        expect(content, contains('# Active: No'));
        // First affirmation should have Updated comment (updatedAt != createdAt)
        expect(content, contains('# Updated:'));
      });

      test('should handle multi-line affirmations correctly', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: 'id-1',
            text: 'Line one\nLine two\nLine three',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;

        final file = File(success.filePath);
        final content = await file.readAsString();

        expect(content, contains('Line one\nLine two\nLine three'));
      });
    });

    group('error handling', () {
      test('should return failure when no affirmations exist', () async {
        // Arrange
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsFailure>());
        final failure = result as ExportAffirmationsFailure;
        expect(failure.message, contains('No affirmations to export'));
      });

      test('should return failure when repository throws exception', () async {
        // Arrange
        when(() => mockRepository.getAll()).thenThrow(Exception('Database error'));

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsFailure>());
        final failure = result as ExportAffirmationsFailure;
        expect(failure.message, contains('Failed to export affirmations'));
      });

      test('should return failure when directory provider throws exception', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: 'id-1',
            text: 'Test',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory())
            .thenThrow(Exception('Permission denied'));

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsFailure>());
        final failure = result as ExportAffirmationsFailure;
        expect(failure.message, contains('Failed to export affirmations'));
      });
    });

    group('file content format', () {
      test('should number affirmations starting from 1', () async {
        // Arrange
        final affirmations = List.generate(
          5,
          (index) => Affirmation(
            id: 'id-$index',
            text: 'Affirmation $index',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            sortOrder: index,
          ),
        );

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;

        final file = File(success.filePath);
        final content = await file.readAsString();

        expect(content, contains('1. Affirmation 0'));
        expect(content, contains('2. Affirmation 1'));
        expect(content, contains('3. Affirmation 2'));
        expect(content, contains('4. Affirmation 3'));
        expect(content, contains('5. Affirmation 4'));
      });

      test('should include header with export date', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: 'id-1',
            text: 'Test',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;

        final file = File(success.filePath);
        final content = await file.readAsString();

        expect(content, contains('# My Affirmations'));
        expect(content, contains('# Exported on'));
      });

      test('should handle special characters in affirmation text', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: 'id-1',
            text: 'I embrace life\'s challenges & opportunities! "Success" is mine.',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;

        final file = File(success.filePath);
        final content = await file.readAsString();

        expect(
          content,
          contains('I embrace life\'s challenges & opportunities! "Success" is mine.'),
        );
      });

      test('should handle unicode characters in affirmation text', () async {
        // Arrange
        final affirmations = [
          Affirmation(
            id: 'id-1',
            text: 'Je suis confiant 🌟 日本語テスト',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAll()).thenAnswer((_) async => affirmations);
        when(() => mockDirectoryProvider.getDirectory()).thenAnswer((_) async => tempDir);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<ExportAffirmationsSuccess>());
        final success = result as ExportAffirmationsSuccess;

        final file = File(success.filePath);
        final content = await file.readAsString();

        expect(content, contains('Je suis confiant 🌟 日本語テスト'));
      });
    });
  });
}
