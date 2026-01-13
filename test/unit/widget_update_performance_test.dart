/// Performance tests for widget update operations.
///
/// These tests verify PERF-002: Widget updates complete within 500ms.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/utils/performance_monitor.dart';
import 'package:myself_2_0/widgets/native_widget/widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PERF-002: Widget Update Performance Tests', () {
    late WidgetService widgetService;

    setUp(() {
      widgetService = WidgetService();
    });

    test('updateWidget completes within 500ms', () async {
      final monitor = PerformanceMonitor.start();

      await widgetService.updateWidget(
        affirmationText: 'I am confident and capable',
        affirmationId: 'test-id-123',
      );

      monitor.stop();

      expect(
        monitor.elapsedMs,
        lessThan(500),
        reason: 'Widget update should complete within 500ms (PERF-002)',
      );
    });

    test('shareSettings completes within 500ms', () async {
      final monitor = PerformanceMonitor.start();

      await widgetService.shareSettings(
        themeMode: 'light',
        widgetRotationEnabled: true,
        fontSizeMultiplier: 1.0,
        refreshMode: 'onUnlock',
      );

      monitor.stop();

      expect(
        monitor.elapsedMs,
        lessThan(500),
        reason: 'Settings share should complete within 500ms (PERF-002)',
      );
    });

    test('shareAffirmationsList completes within 500ms with 10 affirmations',
        () async {
      final monitor = PerformanceMonitor.start();

      final affirmations = List.generate(
        10,
        (i) => {
          'id': 'test-$i',
          'text': 'Affirmation $i: I am worthy and capable',
          'displayCount': i,
          'isActive': true,
        },
      );

      await widgetService.shareAffirmationsList(affirmations);

      monitor.stop();

      expect(
        monitor.elapsedMs,
        lessThan(500),
        reason:
            'Sharing 10 affirmations should complete within 500ms (PERF-002)',
      );
    });

    test('shareAffirmationsList completes within 500ms with 50 affirmations',
        () async {
      final monitor = PerformanceMonitor.start();

      final affirmations = List.generate(
        50,
        (i) => {
          'id': 'test-$i',
          'text': 'Affirmation $i: I am strong, confident, and capable',
          'displayCount': i,
          'isActive': true,
        },
      );

      await widgetService.shareAffirmationsList(affirmations);

      monitor.stop();

      expect(
        monitor.elapsedMs,
        lessThan(500),
        reason:
            'Sharing 50 affirmations should complete within 500ms (PERF-002)',
      );
    });

    test('shareAllWidgetData completes within 500ms', () async {
      final monitor = PerformanceMonitor.start();

      final affirmations = List.generate(
        25,
        (i) => {
          'id': 'test-$i',
          'text': 'Affirmation $i: I embrace my journey',
          'displayCount': i,
          'isActive': true,
        },
      );

      await widgetService.shareAllWidgetData(
        affirmationText: 'I am confident and capable',
        affirmationId: 'current-123',
        themeMode: 'dark',
        widgetRotationEnabled: true,
        fontSizeMultiplier: 1.2,
        refreshMode: 'hourly',
        affirmationsList: affirmations,
      );

      monitor.stop();

      expect(
        monitor.elapsedMs,
        lessThan(500),
        reason:
            'Comprehensive widget data share should complete within 500ms (PERF-002)',
      );
    });

    test('clearWidget completes within 500ms', () async {
      final monitor = PerformanceMonitor.start();

      await widgetService.clearWidget();

      monitor.stop();

      expect(
        monitor.elapsedMs,
        lessThan(500),
        reason: 'Widget clear should complete within 500ms (PERF-002)',
      );
    });

    test('refreshWidget completes within 500ms', () async {
      final monitor = PerformanceMonitor.start();

      await widgetService.refreshWidget();

      monitor.stop();

      expect(
        monitor.elapsedMs,
        lessThan(500),
        reason: 'Widget refresh should complete within 500ms (PERF-002)',
      );
    });

    test('multiple sequential updates complete within 500ms each', () async {
      // Simulate rapid updates (e.g., user quickly adding multiple affirmations)
      for (int i = 0; i < 3; i++) {
        final monitor = PerformanceMonitor.start();

        await widgetService.updateWidget(
          affirmationText: 'Affirmation $i',
          affirmationId: 'test-$i',
        );

        monitor.stop();

        expect(
          monitor.elapsedMs,
          lessThan(500),
          reason:
              'Sequential update $i should complete within 500ms (PERF-002)',
        );
      }
    });

    test('clearAllWidgetData completes within 500ms', () async {
      final monitor = PerformanceMonitor.start();

      await widgetService.clearAllWidgetData();

      monitor.stop();

      expect(
        monitor.elapsedMs,
        lessThan(500),
        reason:
            'Clearing all widget data should complete within 500ms (PERF-002)',
      );
    });

    test('PerformanceMonitor.isUnder() correctly validates 500ms threshold',
        () {
      final monitor = PerformanceMonitor.start();

      // Simulate some work
      for (int i = 0; i < 1000; i++) {
        // Light computation
        i * 2;
      }

      monitor.stop();

      // Should definitely be under 500ms for such light work
      expect(
        monitor.isUnder(500),
        isTrue,
        reason: 'Light computation should be under 500ms',
      );
    });

    test('Performance monitor tracks checkpoints correctly', () {
      final monitor = PerformanceMonitor.start();

      monitor.logCheckpoint('Step 1');
      monitor.logCheckpoint('Step 2');
      monitor.logCheckpoint('Step 3');

      monitor.stop();

      expect(monitor.isStopped, isTrue);
      expect(monitor.elapsedMs, greaterThanOrEqualTo(0));
    });
  });

  group('PerformanceMonitor', () {
    test('start() initializes monitor correctly', () {
      final monitor = PerformanceMonitor.start();

      expect(monitor.isStopped, isFalse);
      expect(monitor.elapsedMs, greaterThanOrEqualTo(0));
    });

    test('stop() marks monitor as stopped', () {
      final monitor = PerformanceMonitor.start();

      expect(monitor.isStopped, isFalse);

      monitor.stop();

      expect(monitor.isStopped, isTrue);
    });

    test('elapsed time increases over time', () async {
      final monitor = PerformanceMonitor.start();

      final elapsed1 = monitor.elapsedMs;
      await Future.delayed(const Duration(milliseconds: 10));
      final elapsed2 = monitor.elapsedMs;

      expect(elapsed2, greaterThan(elapsed1));
    });

    test('elapsed time is frozen after stop()', () async {
      final monitor = PerformanceMonitor.start();

      await Future.delayed(const Duration(milliseconds: 10));
      monitor.stop();

      final elapsed1 = monitor.elapsedMs;
      await Future.delayed(const Duration(milliseconds: 10));
      final elapsed2 = monitor.elapsedMs;

      // After stop, elapsed time should not change
      expect(elapsed1, equals(elapsed2));
    });

    test('isUnder() correctly checks threshold', () {
      final monitor = PerformanceMonitor.start();

      monitor.stop();

      // Should be under 1 second
      expect(monitor.isUnder(1000), isTrue);

      // Might not be under 1ms (depends on system timing precision)
      // But should definitely be under 100ms for just creating and stopping
      expect(monitor.isUnder(100), isTrue);
    });

    test('logCheckpoint() records checkpoints', () {
      final monitor = PerformanceMonitor.start();

      // This shouldn't throw
      monitor.logCheckpoint('Test checkpoint 1');
      monitor.logCheckpoint('Test checkpoint 2');
      monitor.logCheckpoint('Test checkpoint 3');

      monitor.stop();

      expect(monitor.elapsedMs, greaterThanOrEqualTo(0));
    });
  });
}
