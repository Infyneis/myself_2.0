// Unit tests for CreateAffirmationUseCase.
//
// Tests the business logic for creating new affirmations with:
// - Free-form text input
// - Character limit validation (280 chars)
// - UUID generation
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/domain/usecases/create_affirmation.dart';

// Mock classes
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

void main() {
  late MockAffirmationRepository mockRepository;
  late CreateAffirmationUseCase useCase;

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
    mockRepository = MockAffirmationRepository();
    useCase = CreateAffirmationUseCase(repository: mockRepository);
  });

  group('CreateAffirmationUseCase', () {
    group('successful creation', () {
      test('should create affirmation with valid text', () async {
        // Arrange
        const text = 'I am confident and capable';
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: text);

        // Assert
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;
        expect(success.affirmation.text, equals(text));
        expect(success.affirmation.id, isNotEmpty);
        expect(success.affirmation.id.length, equals(36)); // UUID v4 format
        expect(success.affirmation.isActive, isTrue);
        verify(() => mockRepository.create(any())).called(1);
      });

      test('should trim whitespace from text', () async {
        // Arrange
        const text = '  I am successful  ';
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: text);

        // Assert
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;
        expect(success.affirmation.text, equals('I am successful'));
      });

      test('should create affirmation with isActive set to false', () async {
        // Arrange
        const text = 'Test affirmation';
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: text, isActive: false);

        // Assert
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;
        expect(success.affirmation.isActive, isFalse);
      });

      test('should accept text at exactly 280 characters', () async {
        // Arrange
        final text = 'a' * 280;
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: text);

        // Assert
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;
        expect(success.affirmation.text.length, equals(280));
      });

      test('should generate unique UUIDs for each affirmation', () async {
        // Arrange
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result1 = await useCase.call(text: 'First');
        final result2 = await useCase.call(text: 'Second');
        final result3 = await useCase.call(text: 'Third');

        // Assert
        expect(result1, isA<CreateAffirmationSuccess>());
        expect(result2, isA<CreateAffirmationSuccess>());
        expect(result3, isA<CreateAffirmationSuccess>());

        final id1 = (result1 as CreateAffirmationSuccess).affirmation.id;
        final id2 = (result2 as CreateAffirmationSuccess).affirmation.id;
        final id3 = (result3 as CreateAffirmationSuccess).affirmation.id;

        expect(id1, isNot(equals(id2)));
        expect(id2, isNot(equals(id3)));
        expect(id1, isNot(equals(id3)));
      });

      test('should set createdAt and updatedAt timestamps', () async {
        // Arrange
        final beforeCreate = DateTime.now();
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: 'Test');

        // Assert
        final afterCreate = DateTime.now();
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;

        expect(
          success.affirmation.createdAt.millisecondsSinceEpoch,
          greaterThanOrEqualTo(beforeCreate.millisecondsSinceEpoch),
        );
        expect(
          success.affirmation.createdAt.millisecondsSinceEpoch,
          lessThanOrEqualTo(afterCreate.millisecondsSinceEpoch),
        );
        expect(success.affirmation.updatedAt, equals(success.affirmation.createdAt));
      });

      test('should set displayCount to 0', () async {
        // Arrange
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: 'Test');

        // Assert
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;
        expect(success.affirmation.displayCount, equals(0));
      });
    });

    group('validation failures', () {
      test('should fail when text is empty', () async {
        // Act
        final result = await useCase.call(text: '');

        // Assert
        expect(result, isA<CreateAffirmationFailure>());
        final failure = result as CreateAffirmationFailure;
        expect(failure.message, contains('cannot be empty'));
        verifyNever(() => mockRepository.create(any()));
      });

      test('should fail when text is only whitespace', () async {
        // Act
        final result = await useCase.call(text: '   ');

        // Assert
        expect(result, isA<CreateAffirmationFailure>());
        final failure = result as CreateAffirmationFailure;
        expect(failure.message, contains('cannot be empty'));
        verifyNever(() => mockRepository.create(any()));
      });

      test('should fail when text exceeds 280 characters', () async {
        // Arrange
        final longText = 'a' * 281;

        // Act
        final result = await useCase.call(text: longText);

        // Assert
        expect(result, isA<CreateAffirmationFailure>());
        final failure = result as CreateAffirmationFailure;
        expect(failure.message, contains('cannot exceed'));
        expect(failure.message, contains('280'));
        verifyNever(() => mockRepository.create(any()));
      });

      test('should include character count in error for long text', () async {
        // Arrange
        final longText = 'a' * 300;

        // Act
        final result = await useCase.call(text: longText);

        // Assert
        expect(result, isA<CreateAffirmationFailure>());
        final failure = result as CreateAffirmationFailure;
        expect(failure.message, contains('300'));
      });
    });

    group('repository failures', () {
      test('should return failure when repository throws exception', () async {
        // Arrange
        when(() => mockRepository.create(any())).thenThrow(
          Exception('Storage error'),
        );

        // Act
        final result = await useCase.call(text: 'Valid text');

        // Assert
        expect(result, isA<CreateAffirmationFailure>());
        final failure = result as CreateAffirmationFailure;
        expect(failure.message, contains('Failed to create affirmation'));
      });
    });

    group('free-form text input', () {
      test('should accept multi-line text', () async {
        // Arrange
        const text = 'I am confident.\nI am capable.\nI am worthy.';
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: text);

        // Assert
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;
        expect(success.affirmation.text, equals(text));
        expect(success.affirmation.text.contains('\n'), isTrue);
      });

      test('should accept text with special characters', () async {
        // Arrange
        const text = 'I embrace life\'s challenges & opportunities! 🌟';
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: text);

        // Assert
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;
        expect(success.affirmation.text, equals(text));
      });

      test('should accept text with unicode characters', () async {
        // Arrange
        const text = 'Je suis confiant et capable. 日本語テスト';
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: text);

        // Assert
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;
        expect(success.affirmation.text, equals(text));
      });

      test('should accept text with numbers', () async {
        // Arrange
        const text = 'I will achieve 100% of my goals in 2025!';
        when(() => mockRepository.create(any())).thenAnswer((invocation) async {
          final arg = invocation.positionalArguments[0] as Affirmation;
          return arg;
        });

        // Act
        final result = await useCase.call(text: text);

        // Assert
        expect(result, isA<CreateAffirmationSuccess>());
        final success = result as CreateAffirmationSuccess;
        expect(success.affirmation.text, equals(text));
      });
    });
  });
}
