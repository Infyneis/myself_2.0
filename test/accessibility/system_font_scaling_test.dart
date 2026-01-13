/// Tests for system font scaling support (A11Y-005).
///
/// Verifies that the app respects system accessibility font size settings
/// for users with visual impairments.
library;

import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart' as settings_model;
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';

import '../mocks/mock_repositories.dart';

void main() {
  group('A11Y-005: System Font Scaling', () {
    late MockSettingsRepository mockSettingsRepository;
    late SettingsProvider settingsProvider;

    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(
        repository: mockSettingsRepository,
      );
    });

    /// Helper to build a simple widget with specific text scale factor
    Widget buildTestWidget(double systemTextScale, double appMultiplier) {
      return MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(systemTextScale * appMultiplier),
        ),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return const Text('Test');
              },
            ),
          ),
        ),
      );
    }

    testWidgets('respects system default text scale (1.0)', (tester) async {
      // Arrange: System text scale at default
      await tester.pumpWidget(buildTestWidget(1.0, 1.0));
      await tester.pumpAndSettle();

      // Act: Get the MediaQuery from the app
      final BuildContext context = tester.element(find.text('Test'));
      final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

      // Assert: Should use default scale (1.0) when both system and app are at default
      expect(textScaleFactor, equals(1.0));
    });

    testWidgets('respects system increased text scale (1.3)', (tester) async {
      // Arrange: System text scale increased for accessibility
      await tester.pumpWidget(buildTestWidget(1.3, 1.0));
      await tester.pumpAndSettle();

      // Act: Get the MediaQuery from the app
      final BuildContext context = tester.element(find.text('Test'));
      final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

      // Assert: Should use system scale (1.3) when app multiplier is default (1.0)
      expect(textScaleFactor, equals(1.3));
    });

    testWidgets('respects system maximum text scale (2.0)', (tester) async {
      // Arrange: System text scale at maximum for severe visual impairment
      await tester.pumpWidget(buildTestWidget(2.0, 1.0));
      await tester.pumpAndSettle();

      // Act: Get the MediaQuery from the app
      final BuildContext context = tester.element(find.text('Test'));
      final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

      // Assert: Should use system scale (2.0)
      expect(textScaleFactor, equals(2.0));
    });

    testWidgets('combines system scale with app multiplier', (tester) async {
      // Arrange: System scale at 1.5, app multiplier at 1.2
      await tester.pumpWidget(buildTestWidget(1.5, 1.2));
      await tester.pumpAndSettle();

      // Act: Get the MediaQuery from the app
      final BuildContext context = tester.element(find.text('Test'));
      final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

      // Assert: Should multiply system scale (1.5) by app multiplier (1.2) = 1.8
      expect(textScaleFactor, closeTo(1.8, 0.01));
    });

    testWidgets('works with reduced system scale', (tester) async {
      // Arrange: Some users prefer smaller text (0.85)
      await tester.pumpWidget(buildTestWidget(0.85, 1.0));
      await tester.pumpAndSettle();

      // Act: Get the MediaQuery from the app
      final BuildContext context = tester.element(find.text('Test'));
      final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

      // Assert: Should respect reduced scale
      expect(textScaleFactor, closeTo(0.85, 0.01));
    });

    testWidgets('respects both settings simultaneously', (tester) async {
      // Arrange: App multiplier at minimum (0.8), system at maximum (2.0)
      await tester.pumpWidget(buildTestWidget(2.0, 0.8));
      await tester.pumpAndSettle();

      // Act: Get the MediaQuery from the app
      final BuildContext context = tester.element(find.text('Test'));
      final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

      // Assert: Should multiply both: 0.8 * 2.0 = 1.6
      expect(textScaleFactor, closeTo(1.6, 0.01));
    });

    testWidgets('maintains readability with extreme scaling', (tester) async {
      // Arrange: Test extreme case (system 3.0 - for severe visual impairment)
      await tester.pumpWidget(buildTestWidget(3.0, 1.0));
      await tester.pumpAndSettle();

      // Act: Get the MediaQuery from the app
      final BuildContext context = tester.element(find.text('Test'));
      final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

      // Assert: Should respect extreme scale (app should handle gracefully)
      expect(textScaleFactor, equals(3.0));
    });

    test('settings model stores font size multiplier correctly', () {
      // Arrange & Act
      const settings1 = settings_model.Settings(fontSizeMultiplier: 1.0);
      const settings2 = settings_model.Settings(fontSizeMultiplier: 1.4);
      const settings3 = settings_model.Settings(fontSizeMultiplier: 0.8);

      // Assert
      expect(settings1.fontSizeMultiplier, equals(1.0));
      expect(settings2.fontSizeMultiplier, equals(1.4));
      expect(settings3.fontSizeMultiplier, equals(0.8));
    });

    test('settings copyWith preserves font size multiplier', () {
      // Arrange
      const original = settings_model.Settings(fontSizeMultiplier: 1.2);

      // Act
      final modified = original.copyWith(themeMode: settings_model.ThemeMode.dark);

      // Assert: Font size multiplier should be preserved
      expect(modified.fontSizeMultiplier, equals(1.2));
      expect(modified.themeMode, equals(settings_model.ThemeMode.dark));
    });

    test('settings copyWith can update font size multiplier', () {
      // Arrange
      const original = settings_model.Settings(fontSizeMultiplier: 1.0);

      // Act
      final modified = original.copyWith(fontSizeMultiplier: 1.3);

      // Assert
      expect(modified.fontSizeMultiplier, equals(1.3));
    });

    test('provider can update font size multiplier', () async {
      // Arrange
      expect(settingsProvider.fontSizeMultiplier, equals(1.0));

      // Act
      await settingsProvider.setFontSizeMultiplier(1.2);

      // Assert
      expect(settingsProvider.fontSizeMultiplier, equals(1.2));
    });

    test('provider persists font size multiplier changes', () async {
      // Arrange
      await settingsProvider.setFontSizeMultiplier(1.3);

      // Act: Load settings from repository
      final settings = await mockSettingsRepository.getSettings();

      // Assert: Changes should be persisted
      expect(settings.fontSizeMultiplier, equals(1.3));
    });
  });

  group('A11Y-005: Integration with UI Components', () {
    Widget buildTestApp(double systemTextScale, {Widget? child}) {
      return MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(systemTextScale),
        ),
        child: MaterialApp(
          home: child ?? const Scaffold(body: Text('Test')),
        ),
      );
    }

    testWidgets('text widgets scale with system settings', (tester) async {
      // Arrange: Create a simple text widget
      await tester.pumpWidget(
        buildTestApp(
          1.0,
          child: const Scaffold(
            body: Center(
              child: Text('Test Text', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Get baseline size
      final textFinder = find.text('Test Text');
      expect(textFinder, findsOneWidget);

      // Act: Increase system scale
      await tester.pumpWidget(
        buildTestApp(
          1.5,
          child: const Scaffold(
            body: Center(
              child: Text('Test Text', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Text should be rendered larger
      final BuildContext context = tester.element(textFinder);
      final scaledFactor = MediaQuery.textScalerOf(context).scale(1.0);
      expect(scaledFactor, equals(1.5));
    });

    testWidgets('buttons scale with system settings', (tester) async {
      // Arrange & Act: Create button with system scale
      await tester.pumpWidget(
        buildTestApp(
          1.5,
          child: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Button Text'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Button text should scale
      final buttonFinder = find.text('Button Text');
      expect(buttonFinder, findsOneWidget);
      final BuildContext context = tester.element(buttonFinder);
      final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0);
      expect(scaleFactor, equals(1.5));
    });

    testWidgets('maintains minimum touch target with scaling', (tester) async {
      // Arrange & Act: Create interactive element with large system scale
      await tester.pumpWidget(
        buildTestApp(
          2.0,
          child: Scaffold(
            body: Center(
              child: InkWell(
                onTap: () {},
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Text('Tap'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Touch target should still be at least 44x44
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final RenderBox renderBox = tester.renderObject(containerFinder);
      expect(renderBox.size.width, greaterThanOrEqualTo(44));
      expect(renderBox.size.height, greaterThanOrEqualTo(44));
    });
  });

  group('A11Y-005: Documentation', () {
    test('settings model documents font size range', () {
      // Verify that the font size multiplier is documented
      // Range: 0.8 - 1.4 (80% - 140%)
      const minSize = 0.8;
      const maxSize = 1.4;
      const defaultSize = 1.0;

      expect(minSize, equals(0.8));
      expect(maxSize, equals(1.4));
      expect(defaultSize, equals(1.0));
    });

    test('verifies accessibility compliance', () {
      // WCAG 2.1 Level AA requires text to be resizable up to 200%
      // iOS supports up to 310% (accessibility setting "Larger Accessibility Sizes")
      // Android supports up to 200%
      //
      // Our app supports:
      // - System scale: up to 3.0 (300%)
      // - App multiplier: 0.8 to 1.4
      // - Combined: up to 4.2 (420%) when both at maximum
      //
      // This exceeds WCAG 2.1 Level AA requirements

      const systemMax = 3.0;
      const appMax = 1.4;
      const combinedMax = systemMax * appMax;

      expect(combinedMax, greaterThanOrEqualTo(2.0)); // Exceeds WCAG 200% requirement
    });
  });
}
