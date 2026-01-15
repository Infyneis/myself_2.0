import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';
import 'package:myself_2_0/features/settings/presentation/screens/settings_screen.dart';
import 'package:myself_2_0/generated/l10n/app_localizations.dart';

import 'mocks/mock_repositories.dart';

void main() {
  testWidgets('Debug test', (tester) async {
    final mockSettingsRepository = MockSettingsRepository();
    mockSettingsRepository.settings = const Settings(
      language: 'fr',
      hasCompletedOnboarding: true,
    );

    final settingsProvider = SettingsProvider(
      repository: mockSettingsRepository,
      widgetDataSync: null,
    );
    await settingsProvider.loadSettings();

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settingsProvider,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          locale: const Locale('fr'),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to see Language section at the bottom
    final listFinder = find.byType(ListView);
    await tester.drag(listFinder, const Offset(0, -1000));
    await tester.pumpAndSettle();

    // Debug: Print all Text widgets after scrolling
    final textWidgets = find.byType(Text);
    debugPrint('Found ${textWidgets.evaluate().length} Text widgets after scrolling');
    for (final element in textWidgets.evaluate()) {
      final widget = element.widget as Text;
      debugPrint('Text: "${widget.data}"');
    }

    expect(find.text('Français'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
