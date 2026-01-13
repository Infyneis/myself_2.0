/// Affirmation provider for state management.
///
/// Manages affirmation state using Provider pattern.
/// Based on REQUIREMENTS.md state management requirements.
library;

import 'package:flutter/foundation.dart';
import '../../data/models/affirmation.dart';
import '../../data/repositories/affirmation_repository.dart';
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
  })  : _repository = repository,
        _getRandomAffirmation = getRandomAffirmationUseCase;

  final AffirmationRepository _repository;
  final GetRandomAffirmation? _getRandomAffirmation;

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

  /// Creates a new affirmation.
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

  /// Deletes an affirmation by ID.
  Future<void> deleteAffirmation(String id) async {
    _setLoading(true);
    try {
      await _repository.delete(id);
      _affirmations = _affirmations.where((a) => a.id != id).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete affirmation: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
