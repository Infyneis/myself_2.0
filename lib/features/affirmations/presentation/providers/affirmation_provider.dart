/// Affirmation provider for state management.
///
/// Manages affirmation state using Provider pattern.
/// Based on REQUIREMENTS.md state management requirements.
library;

import 'package:flutter/foundation.dart';
import '../../data/models/affirmation.dart';
import '../../data/repositories/affirmation_repository.dart';
import '../../domain/usecases/create_affirmation.dart';
import '../../domain/usecases/delete_affirmation.dart';
import '../../domain/usecases/edit_affirmation.dart';
import '../../domain/usecases/get_random_affirmation.dart';

/// Provider for managing affirmation state.
///
/// This provider exposes:
/// - List of all affirmations
/// - Currently displayed affirmation
/// - CRUD operations
/// - Random selection functionality
///
/// Note: Full implementation will be completed in INFRA-004.
class AffirmationProvider extends ChangeNotifier {
  /// Creates an AffirmationProvider instance.
  AffirmationProvider({
    required AffirmationRepository repository,
    GetRandomAffirmation? getRandomAffirmationUseCase,
    CreateAffirmationUseCase? createAffirmationUseCase,
    EditAffirmationUseCase? editAffirmationUseCase,
    DeleteAffirmationUseCase? deleteAffirmationUseCase,
  })  : _repository = repository,
        _getRandomAffirmation = getRandomAffirmationUseCase,
        _createAffirmationUseCase = createAffirmationUseCase ??
            CreateAffirmationUseCase(repository: repository),
        _editAffirmationUseCase = editAffirmationUseCase ??
            EditAffirmationUseCase(repository: repository),
        _deleteAffirmationUseCase = deleteAffirmationUseCase ??
            DeleteAffirmationUseCase(repository: repository);

  final AffirmationRepository _repository;
  final GetRandomAffirmation? _getRandomAffirmation;
  final CreateAffirmationUseCase _createAffirmationUseCase;
  final EditAffirmationUseCase _editAffirmationUseCase;
  final DeleteAffirmationUseCase _deleteAffirmationUseCase;

  List<Affirmation> _affirmations = [];
  Affirmation? _currentAffirmation;
  String? _lastDisplayedId;
  bool _isLoading = false;
  String? _error;

  /// List of all affirmations.
  List<Affirmation> get affirmations => List.unmodifiable(_affirmations);

  /// Currently displayed affirmation.
  Affirmation? get currentAffirmation => _currentAffirmation;

  /// Whether data is currently being loaded.
  bool get isLoading => _isLoading;

  /// Error message if any operation failed.
  String? get error => _error;

  /// Whether there are any affirmations.
  bool get hasAffirmations => _affirmations.isNotEmpty;

  /// Loads all affirmations from storage.
  Future<void> loadAffirmations() async {
    _setLoading(true);
    try {
      _affirmations = await _repository.getAll();
      _error = null;
    } catch (e) {
      _error = 'Failed to load affirmations: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Selects and sets a random affirmation as current.
  Future<void> selectRandomAffirmation() async {
    if (_getRandomAffirmation == null) return;

    try {
      final affirmation = await _getRandomAffirmation.call(
        lastDisplayedId: _lastDisplayedId,
      );
      if (affirmation != null) {
        _currentAffirmation = affirmation;
        _lastDisplayedId = affirmation.id;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to select random affirmation: $e';
      notifyListeners();
    }
  }

  /// Creates a new affirmation from an existing Affirmation object.
  Future<void> createAffirmation(Affirmation affirmation) async {
    _setLoading(true);
    try {
      final created = await _repository.create(affirmation);
      _affirmations = [..._affirmations, created];
      _error = null;
    } catch (e) {
      _error = 'Failed to create affirmation: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a new affirmation from free-form text input.
  ///
  /// This method:
  /// - Validates the text (non-empty, max 280 characters)
  /// - Generates a unique UUID for the affirmation
  /// - Persists the affirmation to storage
  /// - Updates the local state
  ///
  /// Returns `true` if creation was successful, `false` otherwise.
  /// Check [error] property for failure details.
  ///
  /// Example:
  /// ```dart
  /// final success = await provider.createAffirmationFromText(
  ///   'I am confident and capable',
  /// );
  /// if (!success) {
  ///   print(provider.error);
  /// }
  /// ```
  Future<bool> createAffirmationFromText({
    required String text,
    bool isActive = true,
  }) async {
    _setLoading(true);
    try {
      final result = await _createAffirmationUseCase.call(
        text: text,
        isActive: isActive,
      );

      switch (result) {
        case CreateAffirmationSuccess(:final affirmation):
          _affirmations = [..._affirmations, affirmation];
          _error = null;
          return true;
        case CreateAffirmationFailure(:final message):
          _error = message;
          return false;
      }
    } catch (e) {
      _error = 'Failed to create affirmation: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing affirmation.
  Future<void> updateAffirmation(Affirmation affirmation) async {
    _setLoading(true);
    try {
      final updated = await _repository.update(affirmation);
      final index = _affirmations.indexWhere((a) => a.id == affirmation.id);
      if (index != -1) {
        _affirmations = [
          ..._affirmations.sublist(0, index),
          updated,
          ..._affirmations.sublist(index + 1),
        ];
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to update affirmation: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Edits an existing affirmation with new text.
  ///
  /// This method:
  /// - Validates the text (non-empty, max 280 characters)
  /// - Verifies the affirmation exists
  /// - Updates the text while preserving other metadata (id, createdAt, displayCount)
  /// - Automatically updates the updatedAt timestamp
  ///
  /// Returns `true` if edit was successful, `false` otherwise.
  /// Check [error] property for failure details.
  ///
  /// Example:
  /// ```dart
  /// final success = await provider.editAffirmationFromText(
  ///   id: 'existing-uuid',
  ///   text: 'Updated affirmation text',
  /// );
  /// if (!success) {
  ///   print(provider.error);
  /// }
  /// ```
  Future<bool> editAffirmationFromText({
    required String id,
    required String text,
    bool? isActive,
  }) async {
    _setLoading(true);
    try {
      final result = await _editAffirmationUseCase.call(
        id: id,
        text: text,
        isActive: isActive,
      );

      switch (result) {
        case EditAffirmationSuccess(:final affirmation):
          final index = _affirmations.indexWhere((a) => a.id == id);
          if (index != -1) {
            _affirmations = [
              ..._affirmations.sublist(0, index),
              affirmation,
              ..._affirmations.sublist(index + 1),
            ];
          }
          _error = null;
          return true;
        case EditAffirmationFailure(:final message):
          _error = message;
          return false;
      }
    } catch (e) {
      _error = 'Failed to edit affirmation: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Gets an affirmation by its ID.
  ///
  /// Returns the affirmation if found, null otherwise.
  Affirmation? getAffirmationById(String id) {
    try {
      return _affirmations.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Deletes an affirmation by ID.
  ///
  /// This method directly deletes the affirmation without confirmation.
  /// For deletion with confirmation dialog, use [deleteAffirmationWithConfirmation].
  ///
  /// Returns `true` if deletion was successful, `false` otherwise.
  /// Check [error] property for failure details.
  ///
  /// Example:
  /// ```dart
  /// final success = await provider.deleteAffirmation('affirmation-uuid');
  /// if (!success) {
  ///   print(provider.error);
  /// }
  /// ```
  Future<bool> deleteAffirmation(String id) async {
    _setLoading(true);
    try {
      final result = await _deleteAffirmationUseCase.call(id: id);

      switch (result) {
        case DeleteAffirmationSuccess(:final id):
          _affirmations = _affirmations.where((a) => a.id != id).toList();
          // Clear current affirmation if it was deleted
          if (_currentAffirmation?.id == id) {
            _currentAffirmation = null;
            _lastDisplayedId = null;
          }
          _error = null;
          return true;
        case DeleteAffirmationFailure(:final message):
          _error = message;
          return false;
      }
    } catch (e) {
      _error = 'Failed to delete affirmation: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reorders affirmations based on drag-and-drop interaction.
  ///
  /// This method:
  /// - Updates the local list immediately for responsive UI
  /// - Persists the new order to storage
  /// - Updates sort order values for all affected affirmations
  ///
  /// [oldIndex] is the original position of the item being moved.
  /// [newIndex] is the target position where the item should be placed.
  ///
  /// Returns `true` if reorder was successful, `false` otherwise.
  /// Check [error] property for failure details.
  ///
  /// Example:
  /// ```dart
  /// // Move item from index 0 to index 2
  /// final success = await provider.reorderAffirmations(0, 2);
  /// if (!success) {
  ///   print(provider.error);
  /// }
  /// ```
  Future<bool> reorderAffirmations(int oldIndex, int newIndex) async {
    // Adjust newIndex for removal behavior of ReorderableListView
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Update local list immediately for responsive UI
    final item = _affirmations[oldIndex];
    final newList = List<Affirmation>.from(_affirmations);
    newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    _affirmations = newList;
    notifyListeners();

    // Persist the new order to storage
    try {
      final orderedIds = _affirmations.map((a) => a.id).toList();
      await _repository.reorder(orderedIds);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to save new order: $e';
      // Revert on error - reload from storage
      await loadAffirmations();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
