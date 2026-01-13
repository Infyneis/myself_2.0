/// Widget tests for DeleteConfirmationDialog.
///
/// Tests for FUNC-004 and UI-016: Delete confirmation dialog functionality.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/features/affirmations/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:myself_2_0/core/theme/app_theme.dart';

void main() {
  Widget createTestApp({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: child,
    );
  }

  group('DeleteConfirmationDialog', () {
    testWidgets('displays dialog with correct title and content',
        (tester) async {
      // Arrange
      const affirmationText = 'I am confident and capable';

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                DeleteConfirmationDialog.show(
                  context: context,
                  affirmationText: affirmationText,
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Delete Affirmation'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this affirmation?'),
        findsOneWidget,
      );
      expect(find.text('"$affirmationText"'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
    });

    testWidgets('displays cancel and delete buttons', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                DeleteConfirmationDialog.show(
                  context: context,
                  affirmationText: 'Test affirmation',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('returns false when cancel is pressed', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await DeleteConfirmationDialog.show(
                  context: context,
                  affirmationText: 'Test affirmation',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isFalse);
    });

    testWidgets('returns true when delete is pressed', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await DeleteConfirmationDialog.show(
                  context: context,
                  affirmationText: 'Test affirmation',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isTrue);
    });

    testWidgets('returns false when dismissed by tapping barrier',
        (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await DeleteConfirmationDialog.show(
                  context: context,
                  affirmationText: 'Test affirmation',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap outside the dialog to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isFalse);
    });

    testWidgets('truncates long affirmation text with ellipsis',
        (tester) async {
      // Arrange
      const longText =
          'This is a very long affirmation text that exceeds fifty characters and should be truncated with an ellipsis';

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                DeleteConfirmationDialog.show(
                  context: context,
                  affirmationText: longText,
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - should show truncated text with ellipsis
      expect(
        find.textContaining('This is a very long affirmation'),
        findsOneWidget,
      );
      expect(find.textContaining('...'), findsOneWidget);
    });

    testWidgets('displays warning icon', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                DeleteConfirmationDialog.show(
                  context: context,
                  affirmationText: 'Test affirmation',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                DeleteConfirmationDialog.show(
                  context: context,
                  affirmationText: 'Test affirmation',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - dialog should display correctly in dark mode
      expect(find.text('Delete Affirmation'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
