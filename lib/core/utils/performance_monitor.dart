/// Performance monitoring utilities for tracking app initialization.
///
/// Provides tools for measuring and logging app startup performance
/// to ensure PERF-001 requirement (cold start < 2 seconds) is met.
library;

import 'package:flutter/foundation.dart';

/// Performance monitoring utility for tracking app startup time.
///
/// This class helps measure cold start performance and ensures
/// the app meets the PERF-001 requirement of < 2 seconds cold start.
///
/// Usage:
/// ```dart
/// void main() async {
///   final monitor = PerformanceMonitor.start();
///   // ... initialization code ...
///   monitor.logCheckpoint('Hive initialized');
///   // ... more initialization ...
///   monitor.logCheckpoint('App ready');
///   monitor.logSummary();
/// }
/// ```
class PerformanceMonitor {
  /// Creates a new performance monitor and starts timing.
  PerformanceMonitor.start() : _startTime = DateTime.now();

  final DateTime _startTime;
  final List<_Checkpoint> _checkpoints = [];

  /// Logs a checkpoint with a label.
  ///
  /// Records the current time and duration since start.
  void logCheckpoint(String label) {
    final now = DateTime.now();
    final duration = now.difference(_startTime);
    _checkpoints.add(_Checkpoint(label, duration));

    if (kDebugMode) {
      debugPrint(
        'PerformanceMonitor: [$label] +${duration.inMilliseconds}ms',
      );
    }
  }

  /// Logs a summary of all checkpoints and total startup time.
  ///
  /// Highlights if the startup time exceeds the 2-second target.
  void logSummary() {
    if (!kDebugMode) return;

    final totalDuration = DateTime.now().difference(_startTime);
    final totalMs = totalDuration.inMilliseconds;

    debugPrint('');
    debugPrint('========================================');
    debugPrint('    Performance Summary (PERF-001)');
    debugPrint('========================================');
    debugPrint('Total cold start time: ${totalMs}ms');

    if (totalMs < 2000) {
      debugPrint('✅ PASSED: Under 2-second target');
    } else {
      debugPrint('⚠️  WARNING: Exceeded 2-second target');
    }

    debugPrint('');
    debugPrint('Checkpoints:');
    for (final checkpoint in _checkpoints) {
      debugPrint(
        '  • ${checkpoint.label.padRight(40)} ${checkpoint.duration.inMilliseconds}ms',
      );
    }
    debugPrint('========================================');
    debugPrint('');
  }

  /// Gets the total elapsed time since start.
  Duration get elapsed => DateTime.now().difference(_startTime);

  /// Gets the total elapsed time in milliseconds.
  int get elapsedMs => elapsed.inMilliseconds;
}

/// Internal class representing a performance checkpoint.
class _Checkpoint {
  const _Checkpoint(this.label, this.duration);

  final String label;
  final Duration duration;
}
