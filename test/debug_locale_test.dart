import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';
import 'package:myself_2_0/features/settings/presentation/screens/settings_screen.dart';
import 'package:myself_2_0/features/affirmations/presentation/providers/affirmation_provider.dart';
import 'package:myself_2_0/generated/l10n/app_localizations.dart';

import 'mocks/mock_repositories.dart';

void main() {
  testWidgets('Debug locale test - scroll to language section', (tester) async {
    final mockSettingsRepository = MockSettingsRepository();
    final mockAffirmationRepository = MockAffirmationRepository();
    final mockWidgetDataSync = MockWidgetDataSync();

    mockSettingsRepository.settings = const Settings(
      language: 'fr',
      hasCompletedOnboarding: true,
    );

    final settingsProvider = SettingsProvider(
      repository: mockSettingsRepository,
      widgetDataSync: mockWidgetDataSync,
    );

    final affirmationProvider = AffirmationProvider(
      repository: mockAffirmationRepository,
      getRandomAffirmationUseCase: null,
      widgetDataSync: mockWidgetDataSync,
    );

    await settingsProvider.loadSettings();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
          ChangeNotifierProvider<AffirmationProvider>.value(value: affirmationProvider),
        ],
        child: Consumer<SettingsProvider>(
          builder: (context, provider, _) {
            return MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('fr')],
              locale: Locale(provider.language),
              home: const SettingsScreen(),
            );
          },
        ),
      ),
    );
    
    await tester.pumpAndSettle();

    // Scroll all the way down
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    // Assertion after scroll
    expect(find.text('Français'), findsOneWidget);
  });
}
