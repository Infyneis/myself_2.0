// Unit tests for SettingsProvider.
//
// Tests state management functionality for settings.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart';
import 'package:myself_2_0/features/settings/data/settings_repository.dart';
import 'package:myself_2_0/features/settings/presentation/providers/settings_provider.dart';

// Mock classes
class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;
  late SettingsProvider provider;

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(RefreshMode.onUnlock);
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    provider = SettingsProvider(repository: mockRepository);
  });

  group('SettingsProvider', () {
    group('loadSettings', () {
      test('should load settings from repository', () async {
        // Arrange
        const settings = Settings(
          themeMode: ThemeMode.dark,
          refreshMode: RefreshMode.hourly,
          language: 'en',
          fontSizeMultiplier: 1.2,
          widgetRotationEnabled: false,
        );
        when(() => mockRepository.getSettings()).thenAnswer((_) async => settings);

        // Act
        await provider.loadSettings();

        // Assert
        expect(provider.settings, equals(settings));
        expect(provider.themeMode, equals(ThemeMode.dark));
        expect(provider.refreshMode, equals(RefreshMode.hourly));
        expect(provider.language, equals('en'));
        expect(provider.fontSizeMultiplier, equals(1.2));
        expect(provider.widgetRotationEnabled, isFalse);
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
      });

      test('should set error when loading fails', () async {
        // Arrange
        when(() => mockRepository.getSettings()).thenThrow(Exception('Load failed'));

        // Act
        await provider.loadSettings();

        // Assert
        expect(provider.error, contains('Failed to load settings'));
      });
    });

    group('setThemeMode', () {
      test('should update theme mode', () async {
        // Arrange
        when(() => mockRepository.updateThemeMode(ThemeMode.dark))
            .thenAnswer((_) async {});

        // Act
        await provider.setThemeMode(ThemeMode.dark);

        // Assert
        expect(provider.themeMode, equals(ThemeMode.dark));
        verify(() => mockRepository.updateThemeMode(ThemeMode.dark)).called(1);
      });

      test('should set error when update fails', () async {
        // Arrange
        when(() => mockRepository.updateThemeMode(any()))
            .thenThrow(Exception('Update failed'));

        // Act
        await provider.setThemeMode(ThemeMode.dark);

        // Assert
        expect(provider.error, contains('Failed to update theme'));
      });
    });

    group('setRefreshMode', () {
      test('should update refresh mode', () async {
        // Arrange
        when(() => mockRepository.updateRefreshMode(RefreshMode.daily))
            .thenAnswer((_) async {});

        // Act
        await provider.setRefreshMode(RefreshMode.daily);

        // Assert
        expect(provider.refreshMode, equals(RefreshMode.daily));
        verify(() => mockRepository.updateRefreshMode(RefreshMode.daily)).called(1);
      });
    });

    group('setLanguage', () {
      test('should update language', () async {
        // Arrange
        when(() => mockRepository.updateLanguage('en'))
            .thenAnswer((_) async {});

        // Act
        await provider.setLanguage('en');

        // Assert
        expect(provider.language, equals('en'));
        verify(() => mockRepository.updateLanguage('en')).called(1);
      });
    });

    group('setFontSizeMultiplier', () {
      test('should update font size multiplier', () async {
        // Arrange
        when(() => mockRepository.updateFontSizeMultiplier(1.5))
            .thenAnswer((_) async {});

        // Act
        await provider.setFontSizeMultiplier(1.5);

        // Assert
        expect(provider.fontSizeMultiplier, equals(1.5));
        verify(() => mockRepository.updateFontSizeMultiplier(1.5)).called(1);
      });
    });

    group('setWidgetRotationEnabled', () {
      test('should update widget rotation setting', () async {
        // Arrange
        when(() => mockRepository.updateWidgetRotationEnabled(false))
            .thenAnswer((_) async {});

        // Act
        await provider.setWidgetRotationEnabled(false);

        // Assert
        expect(provider.widgetRotationEnabled, isFalse);
        verify(() => mockRepository.updateWidgetRotationEnabled(false)).called(1);
      });
    });

    group('resetToDefaults', () {
      test('should reset settings to defaults', () async {
        // Arrange
        when(() => mockRepository.resetToDefaults()).thenAnswer((_) async {});

        // First change some settings
        when(() => mockRepository.updateThemeMode(ThemeMode.dark))
            .thenAnswer((_) async {});
        await provider.setThemeMode(ThemeMode.dark);

        // Act
        await provider.resetToDefaults();

        // Assert
        expect(provider.settings, equals(Settings.defaultSettings));
        verify(() => mockRepository.resetToDefaults()).called(1);
      });
    });
  });
}
