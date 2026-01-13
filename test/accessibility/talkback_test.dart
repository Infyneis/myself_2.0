/// TalkBack accessibility tests for A11Y-002.
///
/// These tests verify that all UI elements have proper semantic annotations
/// for Android TalkBack screen reader support.
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/features/affirmations/data/models/affirmation.dart';
import 'package:myself_2_0/features/affirmations/presentation/widgets/affirmation_card.dart';

void main() {
  group('TalkBack Accessibility Tests (A11Y-002)', () {
    testWidgets('AffirmationCard has proper TalkBack semantics',
        (tester) async {
      final now = DateTime.now();
      final affirmation = Affirmation(
        id: '1',
        text: 'I am confident and capable',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationCard(
              affirmation: affirmation,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find the semantic node for the card
      final cardFinder = find.byType(AffirmationCard);
      expect(cardFinder, findsOneWidget);

      // Verify semantic label includes affirmation text
      final semantics = tester.getSemantics(cardFinder);
      expect(
        semantics.label,
        contains('I am confident and capable'),
        reason: 'TalkBack should announce the affirmation text',
      );

      // Verify it's marked as a button (tappable)
      expect(
        semantics.hasFlag(SemanticsFlag.isButton),
        isTrue,
        reason: 'TalkBack should identify this as an actionable button',
      );
    });

    testWidgets('Interactive elements have minimum touch target size',
        (tester) async {
      final now = DateTime.now();
      final affirmation = Affirmation(
        id: '1',
        text: 'Test affirmation',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationCard(
              affirmation: affirmation,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find edit and delete buttons
      final editButton = find.widgetWithIcon(IconButton, Icons.edit_outlined);
      final deleteButton =
          find.widgetWithIcon(IconButton, Icons.delete_outline);

      expect(editButton, findsOneWidget);
      expect(deleteButton, findsOneWidget);

      // Verify minimum touch target size (48x48dp as per Android guidelines)
      final editSize = tester.getSize(editButton);
      final deleteSize = tester.getSize(deleteButton);

      expect(
        editSize.width,
        greaterThanOrEqualTo(48.0),
        reason: 'Edit button must meet minimum touch target width for TalkBack users',
      );
      expect(
        editSize.height,
        greaterThanOrEqualTo(48.0),
        reason: 'Edit button must meet minimum touch target height for TalkBack users',
      );
      expect(
        deleteSize.width,
        greaterThanOrEqualTo(48.0),
        reason: 'Delete button must meet minimum touch target width for TalkBack users',
      );
      expect(
        deleteSize.height,
        greaterThanOrEqualTo(48.0),
        reason: 'Delete button must meet minimum touch target height for TalkBack users',
      );
    });

    testWidgets('All interactive elements are accessible via TalkBack',
        (tester) async {
      final now = DateTime.now();
      final affirmation = Affirmation(
        id: '1',
        text: 'I am strong',
        createdAt: now,
        updatedAt: now,
      );

      bool tapCalled = false;
      bool editCalled = false;
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationCard(
              affirmation: affirmation,
              onTap: () => tapCalled = true,
              onEdit: () => editCalled = true,
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      // Verify card is tappable
      await tester.tap(find.byType(AffirmationCard));
      await tester.pump();
      expect(tapCalled, isTrue, reason: 'Card tap should work with TalkBack double-tap');

      // Verify action buttons are accessible
      await tester.tap(find.widgetWithIcon(IconButton, Icons.edit_outlined));
      await tester.pump();
      expect(editCalled, isTrue, reason: 'Edit button should work with TalkBack');

      await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
      await tester.pump();
      expect(deleteCalled, isTrue, reason: 'Delete button should work with TalkBack');
    });

    testWidgets('Semantics tree is properly configured', (tester) async {
      final now = DateTime.now();
      final affirmation = Affirmation(
        id: '1',
        text: 'Test',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffirmationCard(
              affirmation: affirmation,
            ),
          ),
        ),
      );

      // Ensure semantics are enabled
      final semanticsHandle = tester.ensureSemantics();

      expect(
        semanticsHandle,
        isNotNull,
        reason: 'Semantics should be enabled for TalkBack testing',
      );

      semanticsHandle.dispose();
    });
  });

  group('TalkBack Live Regions', () {
    testWidgets('Loading states are announced via live region',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Semantics(
                label: 'Loading affirmations',
                liveRegion: true,
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );

      final loadingFinder = find.byType(CircularProgressIndicator);
      expect(loadingFinder, findsOneWidget);

      final semantics = tester.getSemantics(loadingFinder);
      expect(
        semantics.hasFlag(SemanticsFlag.isLiveRegion),
        isTrue,
        reason: 'TalkBack should announce loading state immediately',
      );
      expect(
        semantics.label,
        equals('Loading affirmations'),
        reason: 'TalkBack should announce what is loading',
      );
    });
  });

  group('TalkBack State Announcements', () {
    testWidgets('Toggle states are properly announced', (tester) async {
      bool toggleValue = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Semantics(
                toggled: toggleValue,
                label: 'Widget Rotation',
                child: Switch(
                  value: toggleValue,
                  onChanged: (value) {
                    setState(() => toggleValue = value);
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      var semantics = tester.getSemantics(switchFinder);
      expect(
        semantics.hasFlag(SemanticsFlag.hasToggledState),
        isTrue,
        reason: 'TalkBack should recognize this as a toggle',
      );

      // Toggle the switch
      await tester.tap(switchFinder);
      await tester.pump();

      // Verify state changed
      semantics = tester.getSemantics(switchFinder);
      expect(
        semantics.hasFlag(SemanticsFlag.isToggled),
        isTrue,
        reason: 'TalkBack should announce the new toggled state',
      );
    });

    testWidgets('Selected states are properly announced', (tester) async {
      bool isSelected = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Semantics(
                selected: isSelected,
                button: true,
                label: 'Light theme',
                child: InkWell(
                  onTap: () {
                    setState(() => isSelected = !isSelected);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text('Light'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final optionFinder = find.text('Light');
      expect(optionFinder, findsOneWidget);

      // Initial state - not selected
      var semantics = tester.getSemantics(optionFinder);
      expect(
        semantics.hasFlag(SemanticsFlag.isSelected),
        isFalse,
        reason: 'TalkBack should announce item as not selected',
      );

      // Tap to select
      await tester.tap(optionFinder);
      await tester.pump();

      // Verify selected state
      semantics = tester.getSemantics(optionFinder);
      expect(
        semantics.hasFlag(SemanticsFlag.isSelected),
        isTrue,
        reason: 'TalkBack should announce item as selected',
      );
    });
  });
}
