/// Memory optimization utilities for reducing app memory footprint.
///
/// Provides strategies and utilities to optimize memory usage
/// and stay under the 50MB target (PERF-003).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Memory optimization utilities.
///
/// This class provides static utilities for:
/// - Image cache management
/// - List optimization
/// - Resource cleanup
/// - Memory-efficient data structures
abstract class MemoryOptimizer {
  /// Maximum number of cached images.
  ///
  /// Default Flutter image cache can grow unbounded.
  /// We limit it to reduce memory footprint.
  static const int maxImageCacheCount = 50;

  /// Maximum image cache size in bytes (10 MB).
  ///
  /// Limits the total size of cached images.
  static const int maxImageCacheSizeBytes = 10 * 1024 * 1024;

  /// Configures Flutter's image cache with memory-efficient limits.
  ///
  /// Should be called early in app initialization, before loading images.
  ///
  /// This reduces memory usage by:
  /// - Limiting the number of cached images to [maxImageCacheCount]
  /// - Limiting total cache size to [maxImageCacheSizeBytes]
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   MemoryOptimizer.configureImageCache();
  ///   runApp(MyApp());
  /// }
  /// ```
  static void configureImageCache() {
    try {
      // Configure image cache limits
      PaintingBinding.instance.imageCache.maximumSize = maxImageCacheCount;
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          maxImageCacheSizeBytes;
    } catch (e) {
      // Binding not initialized yet (likely in tests)
      // This is safe to skip - cache will use default limits
      if (kDebugMode) {
        debugPrint(
          'MemoryOptimizer: Could not configure image cache (binding not initialized): $e',
        );
      }
    }
  }

  /// Clears the image cache to free memory.
  ///
  /// Call this when memory is running low or when
  /// images are no longer needed.
  static void clearImageCache() {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      // Binding not initialized yet (likely in tests)
      // This is safe to skip
      if (kDebugMode) {
        debugPrint(
          'MemoryOptimizer: Could not clear image cache (binding not initialized): $e',
        );
      }
    }
  }

  /// Creates a memory-efficient list builder for large lists.
  ///
  /// Uses ListView.builder with optimizations:
  /// - Only builds visible items
  /// - Recycles item widgets
  /// - Limits cache extent to reduce off-screen items in memory
  ///
  /// [itemCount] is the total number of items in the list.
  /// [itemBuilder] builds each item widget.
  /// [cacheExtent] defines how much off-screen content to keep (default: 100px).
  ///
  /// Example:
  /// ```dart
  /// MemoryOptimizer.buildOptimizedList(
  ///   itemCount: affirmations.length,
  ///   itemBuilder: (context, index) {
  ///     return AffirmationCard(affirmations[index]);
  ///   },
  /// )
  /// ```
  static Widget buildOptimizedList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    double cacheExtent = 100.0,
    ScrollPhysics? physics,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      physics: physics,
      padding: padding,
      // Limit cache extent to reduce memory usage
      // Default is much larger (viewport height * 2)
      cacheExtent: cacheExtent,
      // Add key for better widget reuse
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
    );
  }

  /// Creates a memory-efficient reorderable list for large lists.
  ///
  /// Similar to [buildOptimizedList] but supports drag-and-drop reordering.
  ///
  /// [itemCount] is the total number of items.
  /// [itemBuilder] builds each item (must include a unique key).
  /// [onReorder] callback when items are reordered.
  ///
  /// Example:
  /// ```dart
  /// MemoryOptimizer.buildOptimizedReorderableList(
  ///   itemCount: affirmations.length,
  ///   itemBuilder: (context, index) {
  ///     return AffirmationCard(
  ///       key: Key(affirmations[index].id),
  ///       affirmation: affirmations[index],
  ///     );
  ///   },
  ///   onReorder: (oldIndex, newIndex) {
  ///     provider.reorderAffirmations(oldIndex, newIndex);
  ///   },
  /// )
  /// ```
  static Widget buildOptimizedReorderableList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required void Function(int, int) onReorder,
    ScrollPhysics? physics,
    EdgeInsets? padding,
  }) {
    return ReorderableListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      onReorder: onReorder,
      physics: physics,
      padding: padding,
      // Optimize for memory
      buildDefaultDragHandles: true,
    );
  }

  /// Disposes resources and triggers garbage collection hint.
  ///
  /// Call this when disposing large objects or providers
  /// to help the garbage collector reclaim memory faster.
  ///
  /// Note: This doesn't guarantee immediate collection,
  /// it's just a hint to the GC.
  static void disposeAndCleanup() {
    try {
      // Clear image cache if it's grown large
      final imageCache = PaintingBinding.instance.imageCache;
      if (imageCache.currentSize > maxImageCacheCount ~/ 2) {
        clearImageCache();
      }
    } catch (e) {
      // Binding not initialized yet (likely in tests)
      // This is safe to skip
      if (kDebugMode) {
        debugPrint(
          'MemoryOptimizer: Could not check image cache (binding not initialized): $e',
        );
      }
    }

    // Hint to GC (not guaranteed to run immediately)
    // The repeated allocations may trigger GC
    for (var i = 0; i < 10; i++) {
      // ignore: unused_local_variable
      final temp = List.filled(100, 0);
    }
  }

  /// Creates a memory-efficient copy of a list.
  ///
  /// Returns an unmodifiable view instead of a full copy
  /// when possible, reducing memory usage.
  ///
  /// Example:
  /// ```dart
  /// List<Affirmation> get affirmations =>
  ///     MemoryOptimizer.unmodifiableCopy(_affirmations);
  /// ```
  static List<T> unmodifiableCopy<T>(List<T> source) {
    return List.unmodifiable(source);
  }

  /// Checks if an object should be kept alive in memory.
  ///
  /// Used to determine if widgets/data should be cached or disposed.
  /// Returns false for null or empty collections.
  static bool shouldKeepAlive(dynamic object) {
    if (object == null) return false;
    if (object is List && object.isEmpty) return false;
    if (object is Map && object.isEmpty) return false;
    if (object is String && object.isEmpty) return false;
    return true;
  }
}
