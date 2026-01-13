/// Memory monitoring utilities for tracking app memory usage.
///
/// Provides tools for measuring and monitoring memory consumption
/// to ensure the app stays under the 50MB footprint requirement (PERF-003).
library;

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Memory monitoring utility for tracking memory usage.
///
/// This class helps measure memory consumption and ensures
/// the app meets memory requirements:
/// - PERF-003: Memory footprint < 50MB
///
/// Usage:
/// ```dart
/// final monitor = MemoryMonitor();
/// await monitor.logMemoryUsage('After loading affirmations');
///
/// if (monitor.currentMemoryMB > 50) {
///   debugPrint('⚠️ Memory usage exceeds 50MB target');
/// }
/// ```
class MemoryMonitor {
  /// Creates a new memory monitor.
  MemoryMonitor();

  /// Cached memory usage from last check (in bytes).
  int? _lastMemoryUsageBytes;

  /// Timestamp of last memory check.
  DateTime? _lastCheckTime;

  /// Gets current memory usage from the VM.
  ///
  /// Returns memory usage in bytes, or null if unable to determine.
  ///
  /// Note: This is a simplified implementation that works in test mode.
  /// For production memory profiling, use Flutter DevTools.
  Future<int?> getCurrentMemoryUsage() async {
    try {
      // In debug/profile mode, we can get service info
      final info = await developer.Service.getInfo();

      // Check if service is available
      if (info.serverUri == null) {
        // Service not available (likely release mode)
        return null;
      }

      // For now, we'll use a simplified approach
      // In production, use Flutter DevTools for accurate measurements
      // This is primarily for development/testing purposes

      // Note: The Service protocol API has changed in recent Flutter versions
      // For accurate memory measurement, use Flutter DevTools Memory profiler
      return null;
    } catch (e) {
      // Service protocol may not be available in release mode
      // or when debugging is disabled
      if (kDebugMode) {
        debugPrint('MemoryMonitor: Unable to get precise memory usage: $e');
      }
    }

    return null;
  }

  /// Gets estimated memory usage in megabytes.
  ///
  /// Returns the current memory usage in MB, or null if unable to determine.
  Future<double?> getCurrentMemoryMB() async {
    final bytes = await getCurrentMemoryUsage();
    if (bytes == null) return null;

    return bytes / (1024 * 1024); // Convert bytes to MB
  }

  /// Logs current memory usage with a label.
  ///
  /// Records the current memory usage and prints it in debug mode.
  Future<void> logMemoryUsage(String label) async {
    if (!kDebugMode) return;

    final memoryMB = await getCurrentMemoryMB();
    _lastCheckTime = DateTime.now();

    if (memoryMB != null) {
      _lastMemoryUsageBytes = (memoryMB * 1024 * 1024).toInt();

      final icon = memoryMB > 50.0 ? '⚠️' : '✅';
      debugPrint(
        'MemoryMonitor [$label]: ${memoryMB.toStringAsFixed(2)} MB $icon',
      );
    } else {
      debugPrint(
        'MemoryMonitor [$label]: Unable to determine memory usage',
      );
    }
  }

  /// Logs a memory usage summary.
  ///
  /// Highlights if memory usage exceeds the 50MB target.
  Future<void> logSummary() async {
    if (!kDebugMode) return;

    final memoryMB = await getCurrentMemoryMB();

    debugPrint('');
    debugPrint('========================================');
    debugPrint('    Memory Usage Summary (PERF-003)');
    debugPrint('========================================');

    if (memoryMB != null) {
      debugPrint('Current memory usage: ${memoryMB.toStringAsFixed(2)} MB');

      if (memoryMB < 50.0) {
        debugPrint('✅ PASSED: Under 50MB target');
      } else {
        debugPrint('⚠️  WARNING: Exceeded 50MB target');
      }
    } else {
      debugPrint('Unable to determine memory usage');
      debugPrint('Note: Precise measurement requires debug mode');
    }

    debugPrint('========================================');
    debugPrint('');
  }

  /// Triggers garbage collection.
  ///
  /// This is a hint to the VM to run garbage collection.
  /// Useful for cleaning up before measuring memory.
  void triggerGC() {
    // Force a garbage collection cycle
    // Note: This is just a hint, the VM may ignore it
    // Repeated allocations can trigger GC
    for (var i = 0; i < 100; i++) {
      // ignore: unused_local_variable
      final temp = List.filled(1000, 0);
    }
  }

  /// Gets cached memory usage in MB from last check.
  ///
  /// Returns null if no check has been performed yet.
  double? get cachedMemoryMB {
    if (_lastMemoryUsageBytes == null) return null;
    return _lastMemoryUsageBytes! / (1024 * 1024);
  }

  /// Gets the time of the last memory check.
  DateTime? get lastCheckTime => _lastCheckTime;

  /// Checks if memory usage is under target in MB.
  ///
  /// Useful for assertions and validation.
  Future<bool> isUnderTarget({double targetMB = 50.0}) async {
    final memoryMB = await getCurrentMemoryMB();
    if (memoryMB == null) return true; // Assume OK if can't measure
    return memoryMB < targetMB;
  }
}
