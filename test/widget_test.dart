// Basic Flutter widget test for Myself 2.0.
//
// This test verifies the basic app structure is working.

import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/app.dart';

void main() {
  testWidgets('App renders successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyselfApp());

    // Verify that the app renders without errors.
    // The home screen shows placeholder text during INFRA-002.
    expect(find.text('Home Screen - Coming Soon'), findsOneWidget);
  });
}
