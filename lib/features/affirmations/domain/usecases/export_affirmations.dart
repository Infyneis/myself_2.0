/// Export affirmations use case.
///
/// Implements functionality to export affirmations to a text file.
/// Based on REQUIREMENTS.md FR-019.
library;

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/affirmation.dart';
import '../../data/repositories/affirmation_repository.dart';

/// Result of export operation.
sealed class ExportAffirmationsResult {
  const ExportAffirmationsResult();
}

/// Successful export result.
class ExportAffirmationsSuccess extends ExportAffirmationsResult {
  /// Creates a successful export result.
  const ExportAffirmationsSuccess({
    required this.filePath,
    required this.affirmationCount,
  });

  /// Path to the exported file.
  final String filePath;

  /// Number of affirmations exported.
  final int affirmationCount;
}

/// Failed export result.
class ExportAffirmationsFailure extends ExportAffirmationsResult {
  /// Creates a failed export result.
  const ExportAffirmationsFailure({required this.message});

  /// Error message describing the failure.
  final String message;
}

/// Use case for exporting affirmations to a text file.
///
/// This use case:
/// - Retrieves all affirmations from the repository
/// - Formats them as a human-readable text file
/// - Saves the file to the device's documents directory
/// - Returns the file path for sharing or reference
///
/// Example:
/// ```dart
/// final useCase = ExportAffirmationsUseCase(repository: repository);
/// final result = await useCase.call();
/// switch (result) {
///   case ExportAffirmationsSuccess(:final filePath, :final affirmationCount):
///     print('Exported $affirmationCount affirmations to $filePath');
///   case ExportAffirmationsFailure(:final message):
///     print('Export failed: $message');
/// }
/// ```
class ExportAffirmationsUseCase {
  /// Creates an ExportAffirmationsUseCase instance.
  const ExportAffirmationsUseCase({
    required AffirmationRepository repository,
    DirectoryProvider? directoryProvider,
  })  : _repository = repository,
        _directoryProvider = directoryProvider;

  final AffirmationRepository _repository;
  final DirectoryProvider? _directoryProvider;

  /// Executes the export operation.
  ///
  /// [fileName] is optional custom filename without extension.
  /// If not provided, generates a timestamped filename.
  ///
  /// Returns [ExportAffirmationsSuccess] with the file path on success,
  /// or [ExportAffirmationsFailure] with an error message on failure.
  Future<ExportAffirmationsResult> call({String? fileName}) async {
    try {
      // Get all affirmations
      final affirmations = await _repository.getAll();

      if (affirmations.isEmpty) {
        return const ExportAffirmationsFailure(
          message: 'No affirmations to export',
        );
      }

      // Generate file content
      final content = _formatAffirmations(affirmations);

      // Get documents directory
      final Directory directory;
      if (_directoryProvider != null) {
        directory = await _directoryProvider.getDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Generate filename with timestamp if not provided
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final finalFileName = fileName ?? 'affirmations_$timestamp';
      final filePath = '${directory.path}/$finalFileName.txt';

      // Write file
      final file = File(filePath);
      await file.writeAsString(content);

      return ExportAffirmationsSuccess(
        filePath: filePath,
        affirmationCount: affirmations.length,
      );
    } catch (e) {
      return ExportAffirmationsFailure(
        message: 'Failed to export affirmations: $e',
      );
    }
  }

  /// Formats affirmations list into a human-readable text format.
  String _formatAffirmations(List<Affirmation> affirmations) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    // Add header
    buffer.writeln('# My Affirmations');
    buffer.writeln('# Exported on ${dateFormat.format(DateTime.now())}');
    buffer.writeln('# Total: ${affirmations.length} affirmation(s)');
    buffer.writeln();

    // Sort by sort order, then by creation date
    final sorted = List<Affirmation>.from(affirmations)
      ..sort((a, b) {
        final orderCompare = a.sortOrder.compareTo(b.sortOrder);
        if (orderCompare != 0) return orderCompare;
        return a.createdAt.compareTo(b.createdAt);
      });

    // Add each affirmation
    for (var i = 0; i < sorted.length; i++) {
      final affirmation = sorted[i];
      buffer.writeln('${i + 1}. ${affirmation.text}');

      // Add metadata as comments
      buffer.writeln('   # Created: ${dateFormat.format(affirmation.createdAt)}');
      if (affirmation.updatedAt != affirmation.createdAt) {
        buffer.writeln('   # Updated: ${dateFormat.format(affirmation.updatedAt)}');
      }
      buffer.writeln('   # Active: ${affirmation.isActive ? 'Yes' : 'No'}');
      buffer.writeln();
    }

    return buffer.toString();
  }
}

/// Interface for providing directory access.
///
/// Used for dependency injection in tests.
abstract class DirectoryProvider {
  /// Gets the directory for file operations.
  Future<Directory> getDirectory();
}

/// Default directory provider using path_provider.
class DefaultDirectoryProvider implements DirectoryProvider {
  /// Creates a DefaultDirectoryProvider instance.
  const DefaultDirectoryProvider();

  @override
  Future<Directory> getDirectory() => getApplicationDocumentsDirectory();
}
