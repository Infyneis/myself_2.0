// Basic Flutter widget test for Myself 2.0.
//
// This test verifies the basic app structure is working.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:myself_2_0/app.dart';
import 'package:myself_2_0/features/affirmations/data/repositories/affirmation_repository.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart';
import 'package:myself_2_0/features/settings/data/settings_repository.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';

// Mock classes
class MockAffirmationRepository extends Mock implements AffirmationRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockAffirmationRepository mockAffirmationRepository;
  late MockSettingsRepository mockSettingsRepository;
  late AffirmationProvider affirmationProvider;
  late SettingsProvider settingsProvider;

  setUp(() {
    mockAffirmationRepository = MockAffirmationRepository();
    mockSettingsRepository = MockSettingsRepository();

    // Set up mock responses
    when(() => mockAffirmationRepository.getAll()).thenAnswer((_) async => []);
    when(() => mockSettingsRepository.getSettings())
        .thenAnswer((_) async => Settings.defaultSettings);

    affirmationProvider = AffirmationProvider(
      repository: mockAffirmationRepository,
    );
    settingsProvider = SettingsProvider(
      repository: mockSettingsRepository,
    );
  });

  testWidgets('App renders successfully with providers', (WidgetTester tester) async {
    // Build our app with providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AffirmationProvider>.value(
            value: affirmationProvider,
          ),
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
        ],
        child: const MyselfApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app renders without errors by checking for any widget
    // The app should render, even if we can't find specific text
    expect(find.byType(MyselfApp), findsOneWidget);
  });
}
