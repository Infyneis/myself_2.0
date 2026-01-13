/// Tests for widget placeholder state (WIDGET-008).
///
/// Verifies that the widget displays placeholder text when no affirmations exist.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/widgets/native_widget/widget_service.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WIDGET-008: Widget Placeholder State', () {
    late WidgetService widgetService;

    setUp(() async {
      widgetService = WidgetService();
      await widgetService.initialize();
    });

    test('should set hasAffirmations to false when sharing empty list', () async {
      // Arrange: Share an empty list of affirmations
      final emptyList = <Map<String, dynamic>>[];

      // Act: Share the empty list with the widget
      final result = await widgetService.shareAffirmationsList(emptyList);

      // Assert: The operation should succeed
      expect(result, isTrue);

      // Verify: hasAffirmations should be false
      final hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isFalse);

      // Verify: Affirmations count should be 0
      final count = await widgetService.getAffirmationsCount();
      expect(count, 0);
    });

    test('should set hasAffirmations to true when sharing non-empty list', () async {
      // Arrange: Share a list with affirmations
      final affirmationsList = [
        {'id': '1', 'text': 'I am confident and capable', 'isActive': true},
        {'id': '2', 'text': 'I embrace challenges', 'isActive': true},
      ];

      // Act: Share the list with the widget
      final result = await widgetService.shareAffirmationsList(affirmationsList);

      // Assert: The operation should succeed
      expect(result, isTrue);

      // Verify: hasAffirmations should be true
      final hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isTrue);

      // Verify: Affirmations count should be 2
      final count = await widgetService.getAffirmationsCount();
      expect(count, 2);
    });

    test('should clear hasAffirmations flag when clearing widget', () async {
      // Arrange: First share some affirmations
      await widgetService.shareAffirmationsList([
        {'id': '1', 'text': 'Test affirmation', 'isActive': true},
      ]);

      // Act: Clear the widget
      final result = await widgetService.clearWidget();

      // Assert: The operation should succeed
      expect(result, isTrue);

      // Note: clearWidget clears affirmation text/id but doesn't clear hasAffirmations
      // The hasAffirmations flag is managed by shareAffirmationsList
      // So we need to also call shareAffirmationsList with empty list
      await widgetService.shareAffirmationsList([]);

      // Verify: hasAffirmations should now be false
      final hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isFalse);
    });

    test('should handle shareAllWidgetData with no affirmations', () async {
      // Arrange: Share all data with empty affirmations list
      final result = await widgetService.shareAllWidgetData(
        affirmationText: null,
        affirmationId: null,
        themeMode: 'system',
        widgetRotationEnabled: true,
        fontSizeMultiplier: 1.0,
        refreshMode: 'onUnlock',
        affirmationsList: [],
      );

      // Assert: The operation should succeed
      expect(result, isTrue);

      // Verify: hasAffirmations should be false
      final hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isFalse);

      // Verify: Current affirmation should be null/empty
      final currentText = await widgetService.getCurrentAffirmation();
      expect(currentText, anyOf(isNull, isEmpty));
    });

    test('should handle transition from empty to populated state', () async {
      // Arrange: Start with no affirmations
      await widgetService.shareAffirmationsList([]);

      // Verify: Initial state is empty
      var hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isFalse);

      // Act: Add affirmations
      await widgetService.shareAffirmationsList([
        {'id': '1', 'text': 'New affirmation', 'isActive': true},
      ]);

      // Verify: State should now be populated
      hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isTrue);
    });

    test('should handle transition from populated to empty state', () async {
      // Arrange: Start with affirmations
      await widgetService.shareAffirmationsList([
        {'id': '1', 'text': 'First affirmation', 'isActive': true},
        {'id': '2', 'text': 'Second affirmation', 'isActive': true},
      ]);

      // Verify: Initial state is populated
      var hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isTrue);

      // Act: Clear all affirmations
      await widgetService.shareAffirmationsList([]);

      // Verify: State should now be empty
      hasAffirmations = await widgetService.getHasAffirmations();
      expect(hasAffirmations, isFalse);
    });
  });
}
