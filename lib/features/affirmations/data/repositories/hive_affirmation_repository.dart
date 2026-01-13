/// Hive implementation of affirmation repository.
///
/// Provides concrete implementation of AffirmationRepository using Hive
/// for local storage persistence.
/// Based on REQUIREMENTS.md FR-017, FR-018.
library;

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/hive_service.dart';
import '../models/affirmation.dart';
import 'affirmation_repository.dart';

/// Hive-backed implementation of [AffirmationRepository].
///
/// This implementation uses Hive for local storage and provides
/// all CRUD operations for affirmations.
class HiveAffirmationRepository implements AffirmationRepository {
  /// Creates a new HiveAffirmationRepository.
  ///
  /// Optionally accepts a [Box<Affirmation>] for testing purposes.
  /// If not provided, uses the default box from [HiveService].
  HiveAffirmationRepository({
    Box<Affirmation>? box,
    Uuid? uuid,
  })  : _box = box,
        _uuid = uuid ?? const Uuid();

  final Box<Affirmation>? _box;
  final Uuid _uuid;

  /// Gets the Hive box, either injected or from HiveService.
  Box<Affirmation> get _affirmationsBox => _box ?? HiveService.affirmationsBox;

  @override
  Future<List<Affirmation>> getAll() async {
    return _affirmationsBox.values.toList();
  }

  @override
  Future<List<Affirmation>> getActive() async {
    return _affirmationsBox.values.where((a) => a.isActive).toList();
  }

  @override
  Future<Affirmation?> getById(String id) async {
    try {
      return _affirmationsBox.values.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Affirmation> create(Affirmation affirmation) async {
    // Generate a new ID if not provided or ensure uniqueness
    final id = affirmation.id.isEmpty ? _uuid.v4() : affirmation.id;
    final now = DateTime.now();

    final newAffirmation = Affirmation(
      id: id,
      text: affirmation.text,
      createdAt: now,
      updatedAt: now,
      displayCount: 0,
      isActive: affirmation.isActive,
    );

    await _affirmationsBox.put(id, newAffirmation);
    return newAffirmation;
  }

  @override
  Future<Affirmation> update(Affirmation affirmation) async {
    final updatedAffirmation = affirmation.copyWith(
      updatedAt: DateTime.now(),
    );

    await _affirmationsBox.put(affirmation.id, updatedAffirmation);
    return updatedAffirmation;
  }

  @override
  Future<bool> delete(String id) async {
    final affirmation = await getById(id);
    if (affirmation == null) {
      return false;
    }

    await _affirmationsBox.delete(id);
    return true;
  }

  @override
  Future<void> deleteAll() async {
    await _affirmationsBox.clear();
  }

  @override
  Future<int> count() async {
    return _affirmationsBox.length;
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    // For reordering, we would need to add an 'order' field to Affirmation
    // For now, this is a placeholder implementation
    // The full implementation will be done in FUNC-007
  }
}
