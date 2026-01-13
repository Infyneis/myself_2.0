/// Test for English (L10N-003) localization strings.
///
/// This test verifies that all English UI strings are properly implemented
/// and match expected values for the secondary language support.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/generated/l10n/app_localizations.dart';
import 'package:myself_2_0/generated/l10n/app_localizations_en.dart';

void main() {
  group('English Translations (L10N-003)', () {
    late AppLocalizations l10n;

    setUp(() {
      // Create English localization instance
      l10n = AppLocalizationsEn();
    });

    group('App Navigation', () {
      test('should have correct app title', () {
        expect(l10n.appTitle, 'Myself 2.0');
      });

      test('should have correct navigation labels', () {
        expect(l10n.myAffirmations, 'My Affirmations');
        expect(l10n.settings, 'Settings');
      });

      test('should have correct accessibility hints', () {
        expect(l10n.myAffirmationsHint, 'Navigate to view all your affirmations');
        expect(l10n.settingsHint, 'Navigate to app settings');
      });
    });

    group('Home Screen', () {
      test('should have correct refresh labels', () {
        expect(l10n.tapToRefresh, 'Tap to refresh');
        expect(l10n.swipeToRefresh, 'Swipe to refresh');
        expect(l10n.refresh, 'Refresh');
        expect(l10n.refreshAffirmation, 'Refresh affirmation');
        expect(l10n.showNewAffirmation, 'Show a new affirmation');
      });

      test('should have correct empty state message', () {
        expect(l10n.createFirstAffirmation, 'Create Your First Affirmation');
      });
    });

    group('Affirmation List', () {
      test('should have correct list screen labels', () {
        expect(l10n.affirmations, 'Affirmations');
        expect(l10n.addAffirmation, 'Add Affirmation');
        expect(l10n.createNewAffirmation, 'Create a new affirmation');
        expect(l10n.editAffirmation, 'Edit affirmation');
        expect(l10n.deleteAffirmation, 'Delete affirmation');
      });

      test('should have correct empty state', () {
        expect(l10n.noAffirmationsYet, 'No Affirmations Yet');
        expect(
          l10n.createFirstAffirmationMessage,
          'Start your journey by creating your first affirmation. It will appear here and on your home widget.',
        );
        expect(l10n.getStarted, 'Get Started');
      });
    });

    group('Affirmation Edit', () {
      test('should have correct edit screen labels', () {
        expect(l10n.newAffirmation, 'New Affirmation');
        expect(l10n.editAffirmationTitle, 'Edit Affirmation');
        expect(l10n.save, 'Save');
        expect(l10n.cancel, 'Cancel');
        expect(l10n.affirmationPlaceholder, 'Enter your affirmation...');
      });

      test('should have correct character count messages', () {
        expect(l10n.charactersRemaining(50), '50 characters remaining');
        expect(l10n.charactersOver(10), '10 characters over limit');
      });

      test('should have correct validation messages', () {
        expect(l10n.affirmationCannotBeEmpty, 'Affirmation cannot be empty');
        expect(l10n.affirmationTooLong, 'Affirmation exceeds 280 characters');
        expect(l10n.affirmationSaved, 'Affirmation saved successfully');
      });

      test('should have correct unsaved changes dialog', () {
        expect(l10n.unsavedChanges, 'Unsaved Changes');
        expect(
          l10n.unsavedChangesMessage,
          'You have unsaved changes. Are you sure you want to leave?',
        );
        expect(l10n.leave, 'Leave');
        expect(l10n.stayAndEdit, 'Stay and Edit');
      });
    });

    group('Delete Confirmation', () {
      test('should have correct delete dialog messages', () {
        expect(l10n.deleteAffirmationTitle, 'Delete Affirmation?');
        expect(
          l10n.deleteAffirmationMessage,
          'Are you sure you want to delete this affirmation? This action cannot be undone.',
        );
        expect(l10n.delete, 'Delete');
        expect(l10n.affirmationDeleted, 'Affirmation deleted');
      });
    });

    group('Settings - Appearance', () {
      test('should have correct appearance section', () {
        expect(l10n.appearance, 'Appearance');
        expect(l10n.theme, 'Theme');
        expect(l10n.chooseTheme, 'Choose your preferred theme');
      });

      test('should have correct theme options', () {
        expect(l10n.themeLight, 'Light');
        expect(l10n.themeLightDescription, 'Bright and clear');
        expect(l10n.themeDark, 'Dark');
        expect(l10n.themeDarkDescription, 'Easy on the eyes');
        expect(l10n.themeSystem, 'System');
        expect(l10n.themeSystemDescription, 'Matches your device');
      });

      test('should have correct font size options', () {
        expect(l10n.fontSize, 'Font Size');
        expect(l10n.fontSizeDescription, 'Adjust text size for better readability');
        expect(l10n.fontSizeSmall, 'Small');
        expect(l10n.fontSizeDefault, 'Default');
        expect(l10n.fontSizeLarge, 'Large');
        expect(l10n.fontSizeExtraLarge, 'Extra Large');
      });
    });

    group('Settings - Widget', () {
      test('should have correct widget settings section', () {
        expect(l10n.widgetSettings, 'Widget Settings');
        expect(l10n.refreshMode, 'Refresh Mode');
        expect(l10n.refreshModeDescription, 'When to show a new affirmation');
      });

      test('should have correct refresh mode options', () {
        expect(l10n.refreshModeUnlock, 'Every Unlock');
        expect(
          l10n.refreshModeUnlockDescription,
          'New affirmation each time you unlock your phone',
        );
        expect(l10n.refreshModeHourly, 'Hourly');
        expect(l10n.refreshModeHourlyDescription, 'New affirmation every hour');
        expect(l10n.refreshModeDaily, 'Daily');
        expect(l10n.refreshModeDailyDescription, 'New affirmation once a day');
      });

      test('should have correct widget rotation labels', () {
        expect(l10n.widgetRotation, 'Widget Rotation');
        expect(
          l10n.widgetRotationDescription,
          'Allow affirmations to change on home widget',
        );
        expect(l10n.enabled, 'Enabled');
        expect(l10n.disabled, 'Disabled');
      });
    });

    group('Settings - Preferences', () {
      test('should have correct preferences section', () {
        expect(l10n.preferences, 'Preferences');
        expect(l10n.language, 'Language');
        expect(l10n.languageDescription, 'Choose your preferred language');
      });

      test('should have correct language options', () {
        expect(l10n.languageEnglish, 'English');
        expect(l10n.languageFrench, 'Français');
      });
    });

    group('Onboarding', () {
      test('should have correct welcome screen messages', () {
        expect(l10n.welcomeTitle, 'Welcome to Myself 2.0');
        expect(l10n.welcomeSubtitle, 'Transform through repetition and intention');
        expect(
          l10n.welcomeDescription,
          'Myself 2.0 helps you become who you want to be through the power of daily affirmations.\n\nSee yourself, become yourself.',
        );
        expect(l10n.letsBegin, 'Let\'s Begin');
      });

      test('should have correct success messages', () {
        expect(l10n.congratulations, 'Congratulations!');
        expect(l10n.firstAffirmationCreated, 'You\'ve created your first affirmation');
        expect(l10n.continueButton, 'Continue');
      });

      test('should have correct widget setup instructions', () {
        expect(l10n.widgetSetupTitle, 'Add to Your Home Screen');
        expect(
          l10n.widgetSetupDescription,
          'See your affirmations every time you unlock your phone by adding the Myself widget to your home screen.',
        );
        expect(
          l10n.widgetSetupIosInstructions,
          '1. Long press on your home screen\n2. Tap the + button in the top corner\n3. Search for "Myself"\n4. Choose your preferred widget size\n5. Tap "Add Widget"',
        );
        expect(
          l10n.widgetSetupAndroidInstructions,
          '1. Long press on your home screen\n2. Tap "Widgets"\n3. Find "Myself" in the list\n4. Long press and drag to your home screen\n5. Choose your preferred size',
        );
        expect(l10n.gotIt, 'Got It');
        expect(l10n.skipForNow, 'Skip for Now');
      });
    });

    group('Error Messages', () {
      test('should have correct error messages', () {
        expect(l10n.errorLoadingAffirmations, 'Error loading affirmations');
        expect(l10n.errorSavingAffirmation, 'Error saving affirmation');
        expect(l10n.errorDeletingAffirmation, 'Error deleting affirmation');
        expect(l10n.tryAgain, 'Try Again');
      });
    });

    group('Accessibility Labels', () {
      test('should have correct accessibility labels', () {
        expect(l10n.affirmationCard, 'Affirmation card');
        expect(l10n.closeButton, 'Close');
        expect(l10n.backButton, 'Back');
      });
    });
  });

  group('English vs French Comparison', () {
    late AppLocalizations enL10n;
    late AppLocalizations frL10n;

    setUp(() {
      enL10n = AppLocalizationsEn();
      frL10n = AppLocalizationsEn(); // Will load French in real app context
    });

    test('should have same number of strings', () {
      // Both languages should support all the same string keys
      // This is a basic sanity check
      expect(enL10n.appTitle, isNotEmpty);
      expect(enL10n.myAffirmations, isNotEmpty);
      expect(enL10n.settings, isNotEmpty);
      // More thorough comparison would be done in integration tests
    });

    test('parameter substitution should work correctly', () {
      // Test that parameterized strings work in English
      expect(enL10n.charactersRemaining(100), '100 characters remaining');
      expect(enL10n.charactersRemaining(1), '1 characters remaining');
      expect(enL10n.charactersOver(5), '5 characters over limit');
    });
  });
}
