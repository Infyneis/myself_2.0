/// Tests for WidgetService.
///
/// Tests the widget service integration with home_widget package.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/widgets/native_widget/widget_service.dart';

void main() {
  group('WidgetService', () {
    late WidgetService widgetService;

    setUp(() {
      widgetService = WidgetService();
    });

    test('should create a singleton instance', () {
      final instance1 = WidgetService();
      final instance2 = WidgetService();
      expect(instance1, same(instance2));
    });

    test('should initialize without throwing', () async {
      // This test verifies that the initialize method doesn't crash
      // Actual widget functionality requires native platform setup
      await expectLater(
        widgetService.initialize(),
        completes,
      );
    });

    test('should handle updateWidget calls gracefully', () async {
      // Widget operations should not throw errors even without native setup
      final result = await widgetService.updateWidget(
        affirmationText: 'Test affirmation',
        affirmationId: 'test-id',
      );

      // Result might be false due to no native setup, but should not crash
      expect(result, isA<bool>());
    });

    test('should handle clearWidget calls gracefully', () async {
      final result = await widgetService.clearWidget();
      expect(result, isA<bool>());
    });

    test('should handle refreshWidget calls gracefully', () async {
      final result = await widgetService.refreshWidget();
      expect(result, isA<bool>());
    });

    test('should handle isWidgetActive calls gracefully', () async {
      final result = await widgetService.isWidgetActive();
      expect(result, isA<bool>());
    });

    test('should handle getCurrentAffirmation calls gracefully', () async {
      final result = await widgetService.getCurrentAffirmation();
      // Result might be null, but should not crash
      expect(result, isA<String?>());
    });

    test('should handle getCurrentAffirmationId calls gracefully', () async {
      final result = await widgetService.getCurrentAffirmationId();
      expect(result, isA<String?>());
    });

    // WIDGET-002: Data sharing tests
    group('Data Sharing (WIDGET-002)', () {
      test('should handle shareSettings calls gracefully', () async {
        final result = await widgetService.shareSettings(
          themeMode: 'light',
          widgetRotationEnabled: true,
          fontSizeMultiplier: 1.0,
        );
        expect(result, isA<bool>());
      });

      test('should handle getThemeMode calls gracefully', () async {
        final result = await widgetService.getThemeMode();
        expect(result, isA<String?>());
      });

      test('should handle getWidgetRotationEnabled calls gracefully', () async {
        final result = await widgetService.getWidgetRotationEnabled();
        expect(result, isA<bool?>());
      });

      test('should handle getFontSizeMultiplier calls gracefully', () async {
        final result = await widgetService.getFontSizeMultiplier();
        expect(result, isA<double?>());
      });

      test('should handle shareAffirmationsList calls gracefully', () async {
        final affirmations = [
          {'id': '1', 'text': 'Affirmation 1'},
          {'id': '2', 'text': 'Affirmation 2'},
        ];
        final result = await widgetService.shareAffirmationsList(affirmations);
        expect(result, isA<bool>());
      });

      test('should handle shareAffirmationsList with empty list', () async {
        final result = await widgetService.shareAffirmationsList([]);
        expect(result, isA<bool>());
      });

      test('should handle getAffirmationsList calls gracefully', () async {
        final result = await widgetService.getAffirmationsList();
        expect(result, isA<List<Map<String, dynamic>>>());
      });

      test('should handle getAffirmationsCount calls gracefully', () async {
        final result = await widgetService.getAffirmationsCount();
        expect(result, isA<int>());
      });

      test('should handle getHasAffirmations calls gracefully', () async {
        final result = await widgetService.getHasAffirmations();
        expect(result, isA<bool>());
      });

      test('should handle shareAllWidgetData calls gracefully', () async {
        final result = await widgetService.shareAllWidgetData(
          affirmationText: 'Test affirmation',
          affirmationId: 'test-id',
          themeMode: 'dark',
          widgetRotationEnabled: false,
          fontSizeMultiplier: 1.2,
          affirmationsList: [
            {'id': '1', 'text': 'Affirmation 1'},
          ],
        );
        expect(result, isA<bool>());
      });

      test('should handle shareAllWidgetData without affirmations', () async {
        final result = await widgetService.shareAllWidgetData(
          themeMode: 'system',
          widgetRotationEnabled: true,
          fontSizeMultiplier: 1.0,
        );
        expect(result, isA<bool>());
      });

      test('should handle clearAllWidgetData calls gracefully', () async {
        final result = await widgetService.clearAllWidgetData();
        expect(result, isA<bool>());
      });

      test('should handle complex affirmation data in list', () async {
        final affirmations = [
          {
            'id': 'abc-123',
            'text': 'I am confident and capable',
            'isActive': true,
            'displayCount': 5,
          },
          {
            'id': 'def-456',
            'text': 'I embrace challenges\nand grow from them',
            'isActive': true,
            'displayCount': 3,
          },
        ];
        final result = await widgetService.shareAffirmationsList(affirmations);
        expect(result, isA<bool>());
      });
    });
  });
}
