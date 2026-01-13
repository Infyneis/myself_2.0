// Unit tests for HiveSettingsRepository.
//
// Tests the Hive-backed implementation of SettingsRepository.
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myself_2_0/features/settings/data/hive_settings_repository.dart';
import 'package:myself_2_0/features/settings/data/settings_model.dart';

// Mock classes
class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late MockBox mockBox;
  late HiveSettingsRepository repository;

  setUp(() {
    mockBox = MockBox();
    repository = HiveSettingsRepository(box: mockBox);
  });

  group('HiveSettingsRepository', () {
    group('getSettings', () {
      test('should return settings from box', () async {
        // Arrange
        when(() => mockBox.get(SettingsKeys.themeMode, defaultValue: any(named: 'defaultValue')))
            .thenReturn(ThemeMode.dark.index);
        when(() => mockBox.get(SettingsKeys.refreshMode, defaultValue: any(named: 'defaultValue')))
            .thenReturn(RefreshMode.hourly.index);
        when(() => mockBox.get(SettingsKeys.language, defaultValue: any(named: 'defaultValue')))
            .thenReturn('en');
        when(() => mockBox.get(SettingsKeys.fontSizeMultiplier, defaultValue: any(named: 'defaultValue')))
            .thenReturn(1.2);
        when(() => mockBox.get(SettingsKeys.widgetRotationEnabled, defaultValue: any(named: 'defaultValue')))
            .thenReturn(false);

        // Act
        final result = await repository.getSettings();

        // Assert
        expect(result.themeMode, equals(ThemeMode.dark));
        expect(result.refreshMode, equals(RefreshMode.hourly));
        expect(result.language, equals('en'));
        expect(result.fontSizeMultiplier, equals(1.2));
        expect(result.widgetRotationEnabled, isFalse);
      });

      test('should return default settings when box is empty', () async {
        // Arrange
        when(() => mockBox.get(SettingsKeys.themeMode, defaultValue: any(named: 'defaultValue')))
            .thenReturn(ThemeMode.system.index);
        when(() => mockBox.get(SettingsKeys.refreshMode, defaultValue: any(named: 'defaultValue')))
            .thenReturn(RefreshMode.onUnlock.index);
        when(() => mockBox.get(SettingsKeys.language, defaultValue: any(named: 'defaultValue')))
            .thenReturn('fr');
        when(() => mockBox.get(SettingsKeys.fontSizeMultiplier, defaultValue: any(named: 'defaultValue')))
            .thenReturn(1.0);
        when(() => mockBox.get(SettingsKeys.widgetRotationEnabled, defaultValue: any(named: 'defaultValue')))
            .thenReturn(true);

        // Act
        final result = await repository.getSettings();

        // Assert
        expect(result, equals(Settings.defaultSettings));
      });
    });

    group('saveSettings', () {
      test('should save all settings to box', () async {
        // Arrange
        const settings = Settings(
          themeMode: ThemeMode.dark,
          refreshMode: RefreshMode.daily,
          language: 'en',
          fontSizeMultiplier: 1.3,
          widgetRotationEnabled: false,
        );
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        await repository.saveSettings(settings);

        // Assert
        verify(() => mockBox.put(SettingsKeys.themeMode, ThemeMode.dark.index)).called(1);
        verify(() => mockBox.put(SettingsKeys.refreshMode, RefreshMode.daily.index)).called(1);
        verify(() => mockBox.put(SettingsKeys.language, 'en')).called(1);
        verify(() => mockBox.put(SettingsKeys.fontSizeMultiplier, 1.3)).called(1);
        verify(() => mockBox.put(SettingsKeys.widgetRotationEnabled, false)).called(1);
      });
    });

    group('updateThemeMode', () {
      test('should update theme mode in box', () async {
        // Arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        await repository.updateThemeMode(ThemeMode.light);

        // Assert
        verify(() => mockBox.put(SettingsKeys.themeMode, ThemeMode.light.index)).called(1);
      });
    });

    group('updateRefreshMode', () {
      test('should update refresh mode in box', () async {
        // Arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        await repository.updateRefreshMode(RefreshMode.daily);

        // Assert
        verify(() => mockBox.put(SettingsKeys.refreshMode, RefreshMode.daily.index)).called(1);
      });
    });

    group('updateLanguage', () {
      test('should update language in box', () async {
        // Arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        await repository.updateLanguage('en');

        // Assert
        verify(() => mockBox.put(SettingsKeys.language, 'en')).called(1);
      });
    });

    group('updateFontSizeMultiplier', () {
      test('should update font size multiplier in box', () async {
        // Arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        await repository.updateFontSizeMultiplier(1.4);

        // Assert
        verify(() => mockBox.put(SettingsKeys.fontSizeMultiplier, 1.4)).called(1);
      });
    });

    group('updateWidgetRotationEnabled', () {
      test('should update widget rotation setting in box', () async {
        // Arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        await repository.updateWidgetRotationEnabled(false);

        // Assert
        verify(() => mockBox.put(SettingsKeys.widgetRotationEnabled, false)).called(1);
      });
    });

    group('resetToDefaults', () {
      test('should save default settings to box', () async {
        // Arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        // Act
        await repository.resetToDefaults();

        // Assert
        verify(() => mockBox.put(SettingsKeys.themeMode, Settings.defaultSettings.themeMode.index)).called(1);
        verify(() => mockBox.put(SettingsKeys.refreshMode, Settings.defaultSettings.refreshMode.index)).called(1);
        verify(() => mockBox.put(SettingsKeys.language, Settings.defaultSettings.language)).called(1);
        verify(() => mockBox.put(SettingsKeys.fontSizeMultiplier, Settings.defaultSettings.fontSizeMultiplier)).called(1);
        verify(() => mockBox.put(SettingsKeys.widgetRotationEnabled, Settings.defaultSettings.widgetRotationEnabled)).called(1);
      });
    });
  });
}
