/// Performance monitoring utilities for tracking app operations.
///
/// Provides tools for measuring and logging performance of various
/// operations to ensure performance requirements are met:
/// - PERF-001: Cold start < 2 seconds
/// - PERF-002: Widget updates < 500ms
library;

import 'package:flutter/foundation.dart';

/// Performance monitoring utility for tracking operation timing.
///
/// This class helps measure operation performance and ensures
/// the app meets performance requirements.
///
/// Usage for app startup (PERF-001):
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
///
/// Usage for widget updates (PERF-002):
/// ```dart
/// final monitor = PerformanceMonitor.start();
/// await widgetService.updateWidget(...);
/// monitor.stop();
/// if (monitor.elapsedMs > 500) {
///   debugPrint('⚠️ Widget update exceeded 500ms target');
/// }
/// ```
class PerformanceMonitor {
  /// Creates a new performance monitor and starts timing.
  PerformanceMonitor.start()
      : _startTime = DateTime.now(),
        _stopTime = null;

  final DateTime _startTime;
  DateTime? _stopTime;
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

  /// Stops the performance monitor.
  ///
  /// This is useful for measuring discrete operations.
  void stop() {
    _stopTime = DateTime.now();
  }

  /// Logs a summary of all checkpoints and total startup time.
  ///
  /// Highlights if the startup time exceeds the 2-second target.
  void logSummary() {
    if (!kDebugMode) return;

    final totalDuration = (_stopTime ?? DateTime.now()).difference(_startTime);
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

  /// Logs a summary for widget update operations.
  ///
  /// Highlights if the update time exceeds the 500ms target (PERF-002).
  void logWidgetUpdateSummary({required String operation}) {
    if (!kDebugMode) return;

    final totalDuration = (_stopTime ?? DateTime.now()).difference(_startTime);
    final totalMs = totalDuration.inMilliseconds;

    final passed = totalMs < 500;
    final icon = passed ? '✅' : '⚠️';

    debugPrint(
      'Widget Update [$operation]: ${totalMs}ms $icon ${passed ? "PASSED" : "WARNING: Exceeded 500ms target"}',
    );

    if (_checkpoints.isNotEmpty) {
      for (final checkpoint in _checkpoints) {
        debugPrint(
          '  • ${checkpoint.label.padRight(30)} ${checkpoint.duration.inMilliseconds}ms',
        );
      }
    }
  }

  /// Gets the total elapsed time since start.
  Duration get elapsed => (_stopTime ?? DateTime.now()).difference(_startTime);

  /// Gets the total elapsed time in milliseconds.
  int get elapsedMs => elapsed.inMilliseconds;

  /// Checks if the elapsed time is under a target in milliseconds.
  ///
  /// Useful for assertions and validation.
  bool isUnder(int targetMs) => elapsedMs < targetMs;

  /// Checks if the monitor has been stopped.
  bool get isStopped => _stopTime != null;
}

/// Internal class representing a performance checkpoint.
class _Checkpoint {
  const _Checkpoint(this.label, this.duration);

  final String label;
  final Duration duration;
}
