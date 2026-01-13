// Unit tests for ImportAffirmationsUseCase.
//
// Tests the business logic for importing affirmations from a text file with:
// - Successful import with various formats
// - Different import modes (append, replace, skipDuplicates)
// - Error handling for invalid files
// - Multi-line affirmation support
// - Character limit validation
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/import_affirmations.dart';

// Mock classes
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

class MockFileReader extends Mock implements FileReader {}

void main() {
  late MockAffirmationRepository mockRepository;
  late MockFileReader mockFileReader;
  late ImportAffirmationsUseCase useCase;

  setUp(() {
    mockRepository = MockAffirmationRepository();
    mockFileReader = MockFileReader();
    useCase = ImportAffirmationsUseCase(
      repository: mockRepository,
      fileReader: mockFileReader,
    );

    // Register fallback values
    registerFallbackValue(Affirmation(
      id: 'fallback-id',
      text: 'fallback',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  group('ImportAffirmationsUseCase', () {
    group('simple list format', () {
      test('should import affirmations from simple line-by-line format', () async {
        // Arrange
        const content = '''
I am confident
I am capable
I am worthy of love
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(3));
        expect(success.skippedCount, equals(0));
        verify(() => mockRepository.create(any())).called(3);
      });

      test('should skip empty lines in simple format', () async {
        // Arrange
        const content = '''
I am confident

I am capable

I am worthy
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(3));
      });
    });

    group('numbered list format', () {
      test('should import affirmations from numbered format', () async {
        // Arrange
        const content = '''
1. I am confident
2. I am capable
3. I am worthy of love
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(3));
      });

      test('should handle numbered format with double-digit numbers', () async {
        // Arrange
        final content = List.generate(
          15,
          (i) => '${i + 1}. Affirmation number ${i + 1}',
        ).join('\n');

        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(15));
      });
    });

    group('export format', () {
      test('should import from exported format with metadata comments', () async {
        // Arrange
        const content = '''
# My Affirmations
# Exported on 2025-01-13 10:30
# Total: 2 affirmation(s)

1. I am confident
   # Created: 2025-01-01 10:00
   # Active: Yes

2. I am capable
   # Created: 2025-01-02 11:00
   # Updated: 2025-01-03 12:00
   # Active: No

''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(2));
        expect(success.skippedCount, equals(0));
      });

      test('should skip header comments when parsing', () async {
        // Arrange
        const content = '''
# My Affirmations
# Exported on 2025-01-13 10:30
# Total: 1 affirmation(s)

1. I am confident
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(1));
      });
    });

    group('multi-line affirmations', () {
      test('should handle multi-line affirmations in numbered format', () async {
        // Arrange
        const content = '''
1. Line one
Line two
Line three

2. Single line affirmation
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);

        final createdAffirmations = <Affirmation>[];
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final aff = invocation.positionalArguments[0] as Affirmation;
          createdAffirmations.add(aff);
          return aff;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(2));

        // Verify multi-line affirmation was parsed correctly
        final multiLineAff = createdAffirmations.firstWhere(
          (a) => a.text.contains('Line one'),
        );
        expect(multiLineAff.text, contains('Line two'));
        expect(multiLineAff.text, contains('Line three'));
      });
    });

    group('import modes', () {
      test('append mode should add to existing affirmations', () async {
        // Arrange
        const content = '''
New affirmation
''';
        final existingAffirmation = Affirmation(
          id: 'existing-id',
          text: 'Existing affirmation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sortOrder: 0,
        );

        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => [existingAffirmation]);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(
          filePath: '/test/file.txt',
          mode: ImportMode.append,
        );

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(1));
        verify(() => mockRepository.create(any())).called(1);
        verifyNever(() => mockRepository.deleteAll());
      });

      test('replace mode should delete existing affirmations first', () async {
        // Arrange
        const content = '''
New affirmation
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.deleteAll()).thenAnswer((_) async {});
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(
          filePath: '/test/file.txt',
          mode: ImportMode.replace,
        );

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        verify(() => mockRepository.deleteAll()).called(1);
      });

      test('skipDuplicates mode should skip existing affirmations', () async {
        // Arrange
        const content = '''
I am confident
New affirmation
I am confident
''';
        final existingAffirmation = Affirmation(
          id: 'existing-id',
          text: 'I am confident',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => [existingAffirmation]);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(
          filePath: '/test/file.txt',
          mode: ImportMode.skipDuplicates,
        );

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(1)); // Only "New affirmation"
        verify(() => mockRepository.create(any())).called(1);
      });

      test('skipDuplicates should be case-insensitive', () async {
        // Arrange
        const content = '''
I AM CONFIDENT
''';
        final existingAffirmation = Affirmation(
          id: 'existing-id',
          text: 'I am confident',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => [existingAffirmation]);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(
          filePath: '/test/file.txt',
          mode: ImportMode.skipDuplicates,
        );

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(0)); // Should be skipped
        expect(success.skippedReasons, isNotEmpty);
      });
    });

    group('sort order', () {
      test('should assign correct sort order to imported affirmations', () async {
        // Arrange
        const content = '''
First new affirmation
Second new affirmation
''';
        final existingAffirmation = Affirmation(
          id: 'existing-id',
          text: 'Existing',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sortOrder: 5,
        );

        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => [existingAffirmation]);

        final createdAffirmations = <Affirmation>[];
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final aff = invocation.positionalArguments[0] as Affirmation;
          createdAffirmations.add(aff);
          return aff;
        });

        // Act
        await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(createdAffirmations[0].sortOrder, equals(6));
        expect(createdAffirmations[1].sortOrder, equals(7));
      });
    });

    group('validation', () {
      test('should skip affirmations exceeding character limit', () async {
        // Arrange
        final longText = 'A' * 300; // Exceeds 280 char limit
        final content = '''
Valid affirmation
$longText
Another valid
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(2));
        expect(success.skippedCount, equals(1));
        expect(success.skippedReasons, isNotEmpty);
      });

      test('should skip empty affirmations', () async {
        // Arrange
        const content = '''
Valid affirmation

Another valid
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(2));
      });
    });

    group('error handling', () {
      test('should return failure when file is empty', () async {
        // Arrange
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => '');

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsFailure>());
        final failure = result as ImportAffirmationsFailure;
        expect(failure.message, contains('File is empty'));
      });

      test('should return failure when file only has whitespace', () async {
        // Arrange
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => '   \n\n   ');

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsFailure>());
        final failure = result as ImportAffirmationsFailure;
        expect(failure.message, contains('File is empty'));
      });

      test('should return failure when file only has comments', () async {
        // Arrange
        const content = '''
# My Affirmations
# Exported on 2025-01-13 10:30
# Total: 0 affirmation(s)
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsFailure>());
        final failure = result as ImportAffirmationsFailure;
        expect(failure.message, contains('No valid affirmations found'));
      });

      test('should return failure when file reader throws exception', () async {
        // Arrange
        when(() => mockFileReader.readFile(any()))
            .thenThrow(Exception('File read error'));

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsFailure>());
        final failure = result as ImportAffirmationsFailure;
        expect(failure.message, contains('Failed to import affirmations'));
      });

      test('should return failure when repository throws exception', () async {
        // Arrange
        const content = 'Test affirmation';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenThrow(Exception('Database error'));

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsFailure>());
        final failure = result as ImportAffirmationsFailure;
        expect(failure.message, contains('Failed to import affirmations'));
      });
    });

    group('special characters', () {
      test('should handle special characters in affirmations', () async {
        // Arrange
        const content = '''
I embrace life's challenges & opportunities! "Success" is mine.
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);

        final createdAffirmations = <Affirmation>[];
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final aff = invocation.positionalArguments[0] as Affirmation;
          createdAffirmations.add(aff);
          return aff;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        expect(
          createdAffirmations[0].text,
          equals('I embrace life\'s challenges & opportunities! "Success" is mine.'),
        );
      });

      test('should handle unicode characters', () async {
        // Arrange
        const content = '''
Je suis confiant
I am strong
''';
        when(() => mockFileReader.readFile(any())).thenAnswer((_) async => content);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);

        final createdAffirmations = <Affirmation>[];
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final aff = invocation.positionalArguments[0] as Affirmation;
          createdAffirmations.add(aff);
          return aff;
        });

        // Act
        final result = await useCase.call(filePath: '/test/file.txt');

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(2));
        expect(createdAffirmations.any((a) => a.text == 'Je suis confiant'), isTrue);
      });
    });

    group('without file reader (real file)', () {
      late Directory tempDir;
      late ImportAffirmationsUseCase useCaseWithoutMock;

      setUpAll(() async {
        tempDir = await Directory.systemTemp.createTemp('import_test_');
      });

      tearDownAll(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      setUp(() {
        useCaseWithoutMock = ImportAffirmationsUseCase(
          repository: mockRepository,
        );
      });

      test('should return failure when file does not exist', () async {
        // Act
        final result = await useCaseWithoutMock.call(
          filePath: '${tempDir.path}/nonexistent.txt',
        );

        // Assert
        expect(result, isA<ImportAffirmationsFailure>());
        final failure = result as ImportAffirmationsFailure;
        expect(failure.message, contains('File not found'));
      });

      test('should import from real file', () async {
        // Arrange
        final testFile = File('${tempDir.path}/test_import.txt');
        await testFile.writeAsString('Test affirmation\n');

        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          return invocation.positionalArguments[0] as Affirmation;
        });

        // Act
        final result = await useCaseWithoutMock.call(
          filePath: testFile.path,
        );

        // Assert
        expect(result, isA<ImportAffirmationsSuccess>());
        final success = result as ImportAffirmationsSuccess;
        expect(success.importedCount, equals(1));
      });
    });
  });
}
