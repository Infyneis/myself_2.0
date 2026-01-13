/// Import affirmations use case.
///
/// Implements functionality to import affirmations from a text file.
/// Based on REQUIREMENTS.md FR-020.
library;

import 'dart:io';

import '../../data/models/affirmation.dart';
import '../../data/repositories/affirmation_repository.dart';

/// Result of import operation.
sealed class ImportAffirmationsResult {
  const ImportAffirmationsResult();
}

/// Successful import result.
class ImportAffirmationsSuccess extends ImportAffirmationsResult {
  /// Creates a successful import result.
  const ImportAffirmationsSuccess({
    required this.importedCount,
    required this.skippedCount,
    this.skippedReasons = const [],
  });

  /// Number of affirmations successfully imported.
  final int importedCount;

  /// Number of affirmations skipped due to validation errors.
  final int skippedCount;

  /// Reasons for skipped affirmations.
  final List<String> skippedReasons;
}

/// Failed import result.
class ImportAffirmationsFailure extends ImportAffirmationsResult {
  /// Creates a failed import result.
  const ImportAffirmationsFailure({required this.message});

  /// Error message describing the failure.
  final String message;
}

/// Import mode for handling existing affirmations.
enum ImportMode {
  /// Append imported affirmations to existing ones.
  append,

  /// Replace all existing affirmations with imported ones.
  replace,

  /// Skip affirmations that already exist (based on text content).
  skipDuplicates,
}

/// Use case for importing affirmations from a text file.
///
/// This use case:
/// - Reads affirmations from a text file
/// - Parses the file content (supports multiple formats)
/// - Validates each affirmation
/// - Saves valid affirmations to the repository
/// - Returns import statistics
///
/// Supported file formats:
/// 1. Simple list (one affirmation per line)
/// 2. Numbered list (1. Affirmation text)
/// 3. Export format from [ExportAffirmationsUseCase] (with metadata comments)
///
/// Example:
/// ```dart
/// final useCase = ImportAffirmationsUseCase(repository: repository);
/// final result = await useCase.call(filePath: '/path/to/file.txt');
/// switch (result) {
///   case ImportAffirmationsSuccess(:final importedCount, :final skippedCount):
///     print('Imported $importedCount affirmations ($skippedCount skipped)');
///   case ImportAffirmationsFailure(:final message):
///     print('Import failed: $message');
/// }
/// ```
class ImportAffirmationsUseCase {
  /// Creates an ImportAffirmationsUseCase instance.
  const ImportAffirmationsUseCase({
    required AffirmationRepository repository,
    FileReader? fileReader,
  })  : _repository = repository,
        _fileReader = fileReader;

  final AffirmationRepository _repository;
  final FileReader? _fileReader;

  /// Executes the import operation.
  ///
  /// [filePath] is the path to the file to import from.
  /// [mode] determines how to handle existing affirmations.
  ///
  /// Returns [ImportAffirmationsSuccess] with import statistics on success,
  /// or [ImportAffirmationsFailure] with an error message on failure.
  Future<ImportAffirmationsResult> call({
    required String filePath,
    ImportMode mode = ImportMode.append,
  }) async {
    try {
      // Read file content
      final String content;
      if (_fileReader != null) {
        content = await _fileReader.readFile(filePath);
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          return const ImportAffirmationsFailure(
            message: 'File not found',
          );
        }
        content = await file.readAsString();
      }

      if (content.trim().isEmpty) {
        return const ImportAffirmationsFailure(
          message: 'File is empty',
        );
      }

      // Parse affirmations from content
      final parseResult = _parseAffirmations(content);
      final parsedTexts = parseResult.texts;
      final skippedReasons = List<String>.from(parseResult.skippedReasons);

      if (parsedTexts.isEmpty) {
        return const ImportAffirmationsFailure(
          message: 'No valid affirmations found in file',
        );
      }

      // Handle import mode
      List<String> textsToImport;
      if (mode == ImportMode.replace) {
        await _repository.deleteAll();
        textsToImport = parsedTexts;
      } else if (mode == ImportMode.skipDuplicates) {
        final existingAffirmations = await _repository.getAll();
        final existingTexts =
            existingAffirmations.map((a) => a.text.trim().toLowerCase()).toSet();

        textsToImport = [];
        for (final text in parsedTexts) {
          if (existingTexts.contains(text.trim().toLowerCase())) {
            skippedReasons.add('Duplicate: "${_truncateText(text, 30)}"');
          } else {
            textsToImport.add(text);
          }
        }
      } else {
        textsToImport = parsedTexts;
      }

      // Get current max sort order
      final existingAffirmations = await _repository.getAll();
      var nextSortOrder = existingAffirmations.isEmpty
          ? 0
          : existingAffirmations
                  .map((a) => a.sortOrder)
                  .reduce((a, b) => a > b ? a : b) +
              1;

      // Create and save affirmations
      var importedCount = 0;
      for (final text in textsToImport) {
        try {
          final affirmation = Affirmation.create(
            text: text,
            sortOrder: nextSortOrder,
          );
          await _repository.create(affirmation);
          importedCount++;
          nextSortOrder++;
        } catch (e) {
          skippedReasons.add('Failed to create: "${_truncateText(text, 30)}"');
        }
      }

      // Calculate total skipped: original parse skips + duplicates skipped + failed creates
      final totalSkipped = skippedReasons.length;

      return ImportAffirmationsSuccess(
        importedCount: importedCount,
        skippedCount: totalSkipped,
        skippedReasons: skippedReasons,
      );
    } catch (e) {
      return ImportAffirmationsFailure(
        message: 'Failed to import affirmations: $e',
      );
    }
  }

  /// Parses affirmation texts from file content.
  ///
  /// Supports multiple formats:
  /// - Simple list (one per line)
  /// - Numbered list (1. text, 2. text)
  /// - Export format with metadata comments
  _ParseResult _parseAffirmations(String content) {
    final texts = <String>[];
    final skippedReasons = <String>[];
    final lines = content.split('\n');

    var inAffirmation = false;
    var currentAffirmation = StringBuffer();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmedLine = line.trim();

      // Skip header comments
      if (trimmedLine.startsWith('# My Affirmations') ||
          trimmedLine.startsWith('# Exported on') ||
          trimmedLine.startsWith('# Total:')) {
        continue;
      }

      // Skip metadata comments (indented comments after affirmation)
      if (trimmedLine.startsWith('# Created:') ||
          trimmedLine.startsWith('# Updated:') ||
          trimmedLine.startsWith('# Active:')) {
        continue;
      }

      // Skip empty lines
      if (trimmedLine.isEmpty) {
        // If we were building a multi-line affirmation, save it
        if (inAffirmation && currentAffirmation.isNotEmpty) {
          final text = currentAffirmation.toString().trim();
          _validateAndAddText(text, texts, skippedReasons);
          currentAffirmation.clear();
          inAffirmation = false;
        }
        continue;
      }

      // Check for numbered format (e.g., "1. Affirmation text")
      final numberedMatch = RegExp(r'^\d+\.\s*(.+)$').firstMatch(trimmedLine);
      if (numberedMatch != null) {
        // Save any previous affirmation
        if (inAffirmation && currentAffirmation.isNotEmpty) {
          final text = currentAffirmation.toString().trim();
          _validateAndAddText(text, texts, skippedReasons);
          currentAffirmation.clear();
        }

        // Start new affirmation
        final affirmationText = numberedMatch.group(1)!;
        currentAffirmation.write(affirmationText);
        inAffirmation = true;
        continue;
      }

      // Check if this line continues a multi-line affirmation
      // (not a numbered item, not a comment, and we're in an affirmation)
      if (inAffirmation && !trimmedLine.startsWith('#')) {
        currentAffirmation.writeln();
        currentAffirmation.write(trimmedLine);
        continue;
      }

      // Simple line format (not numbered, not comment)
      if (!trimmedLine.startsWith('#')) {
        // Save any previous affirmation
        if (inAffirmation && currentAffirmation.isNotEmpty) {
          final text = currentAffirmation.toString().trim();
          _validateAndAddText(text, texts, skippedReasons);
          currentAffirmation.clear();
        }

        // This is a simple one-line affirmation
        _validateAndAddText(trimmedLine, texts, skippedReasons);
        inAffirmation = false;
      }
    }

    // Don't forget the last affirmation
    if (currentAffirmation.isNotEmpty) {
      final text = currentAffirmation.toString().trim();
      _validateAndAddText(text, texts, skippedReasons);
    }

    return _ParseResult(texts: texts, skippedReasons: skippedReasons);
  }

  /// Validates and adds text to the list if valid.
  void _validateAndAddText(
    String text,
    List<String> texts,
    List<String> skippedReasons,
  ) {
    final validationError = Affirmation.validateText(text);
    if (validationError != null) {
      skippedReasons.add('Invalid: "${_truncateText(text, 30)}" - $validationError');
    } else {
      texts.add(text);
    }
  }

  /// Truncates text for display in error messages.
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

/// Internal class to hold parse results.
class _ParseResult {
  const _ParseResult({
    required this.texts,
    required this.skippedReasons,
  });

  final List<String> texts;
  final List<String> skippedReasons;
}

/// Interface for reading files.
///
/// Used for dependency injection in tests.
abstract class FileReader {
  /// Reads the content of a file.
  Future<String> readFile(String filePath);
}

/// Default file reader using dart:io.
class DefaultFileReader implements FileReader {
  /// Creates a DefaultFileReader instance.
  const DefaultFileReader();

  @override
  Future<String> readFile(String filePath) async {
    final file = File(filePath);
    return file.readAsString();
  }
}
