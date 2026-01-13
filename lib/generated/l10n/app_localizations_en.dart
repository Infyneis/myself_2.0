// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Myself 2.0';

  @override
  String get myAffirmations => 'My Affirmations';

  @override
  String get myAffirmationsHint => 'Navigate to view all your affirmations';

  @override
  String get settings => 'Settings';

  @override
  String get settingsHint => 'Navigate to app settings';

  @override
  String get tapToRefresh => 'Tap to refresh';

  @override
  String get swipeToRefresh => 'Swipe to refresh';

  @override
  String get refresh => 'Refresh';

  @override
  String get refreshAffirmation => 'Refresh affirmation';

  @override
  String get showNewAffirmation => 'Show a new affirmation';

  @override
  String get createFirstAffirmation => 'Create Your First Affirmation';

  @override
  String get affirmations => 'Affirmations';

  @override
  String get addAffirmation => 'Add Affirmation';

  @override
  String get createNewAffirmation => 'Create a new affirmation';

  @override
  String get editAffirmation => 'Edit affirmation';

  @override
  String get deleteAffirmation => 'Delete affirmation';

  @override
  String get newAffirmation => 'New Affirmation';

  @override
  String get editAffirmationTitle => 'Edit Affirmation';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get affirmationPlaceholder => 'Enter your affirmation...';

  @override
  String charactersRemaining(int count) {
    return '$count characters remaining';
  }

  @override
  String charactersOver(int count) {
    return '$count characters over limit';
  }

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Are you sure you want to leave?';

  @override
  String get leave => 'Leave';

  @override
  String get stayAndEdit => 'Stay and Edit';

  @override
  String get affirmationCannotBeEmpty => 'Affirmation cannot be empty';

  @override
  String get affirmationTooLong => 'Affirmation exceeds 280 characters';

  @override
  String get affirmationSaved => 'Affirmation saved successfully';

  @override
  String get deleteAffirmationTitle => 'Delete Affirmation?';

  @override
  String get deleteAffirmationMessage =>
      'Are you sure you want to delete this affirmation? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get affirmationDeleted => 'Affirmation deleted';

  @override
  String get noAffirmationsYet => 'No Affirmations Yet';

  @override
  String get createFirstAffirmationMessage =>
      'Start your journey by creating your first affirmation. It will appear here and on your home widget.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get chooseTheme => 'Choose your preferred theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightDescription => 'Bright and clear';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkDescription => 'Easy on the eyes';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemDescription => 'Matches your device';

  @override
  String get fontSize => 'Font Size';

  @override
  String get fontSizeDescription => 'Adjust text size for better readability';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeDefault => 'Default';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeExtraLarge => 'Extra Large';

  @override
  String get widgetSettings => 'Widget Settings';

  @override
  String get refreshMode => 'Refresh Mode';

  @override
  String get refreshModeDescription => 'When to show a new affirmation';

  @override
  String get refreshModeUnlock => 'Every Unlock';

  @override
  String get refreshModeUnlockDescription =>
      'New affirmation each time you unlock your phone';

  @override
  String get refreshModeHourly => 'Hourly';

  @override
  String get refreshModeHourlyDescription => 'New affirmation every hour';

  @override
  String get refreshModeDaily => 'Daily';

  @override
  String get refreshModeDailyDescription => 'New affirmation once a day';

  @override
  String get widgetRotation => 'Widget Rotation';

  @override
  String get widgetRotationDescription =>
      'Allow affirmations to change on home widget';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose your preferred language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get welcomeTitle => 'Welcome to Myself 2.0';

  @override
  String get welcomeSubtitle => 'Transform through repetition and intention';

  @override
  String get welcomeDescription =>
      'Myself 2.0 helps you become who you want to be through the power of daily affirmations.\n\nSee yourself, become yourself.';

  @override
  String get letsBegin => 'Let\'s Begin';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get firstAffirmationCreated =>
      'You\'ve created your first affirmation';

  @override
  String get continueButton => 'Continue';

  @override
  String get widgetSetupTitle => 'Add to Your Home Screen';

  @override
  String get widgetSetupDescription =>
      'See your affirmations every time you unlock your phone by adding the Myself widget to your home screen.';

  @override
  String get widgetSetupIosInstructions =>
      '1. Long press on your home screen\n2. Tap the + button in the top corner\n3. Search for \"Myself\"\n4. Choose your preferred widget size\n5. Tap \"Add Widget\"';

  @override
  String get widgetSetupAndroidInstructions =>
      '1. Long press on your home screen\n2. Tap \"Widgets\"\n3. Find \"Myself\" in the list\n4. Long press and drag to your home screen\n5. Choose your preferred size';

  @override
  String get gotIt => 'Got It';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get errorLoadingAffirmations => 'Error loading affirmations';

  @override
  String get errorSavingAffirmation => 'Error saving affirmation';

  @override
  String get errorDeletingAffirmation => 'Error deleting affirmation';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get affirmationCard => 'Affirmation card';

  @override
  String get closeButton => 'Close';

  @override
  String get backButton => 'Back';

  @override
  String get widgetSetupStepIos1Title => 'Long press on your home screen';

  @override
  String get widgetSetupStepIos1Desc =>
      'Press and hold any empty area on your home screen';

  @override
  String get widgetSetupStepIos2Title => 'Tap the + button';

  @override
  String get widgetSetupStepIos2Desc =>
      'Look for the plus icon in the top-left corner';

  @override
  String get widgetSetupStepIos3Title => 'Search for \"Myself 2.0\"';

  @override
  String get widgetSetupStepIos3Desc => 'Find our app in the widget gallery';

  @override
  String get widgetSetupStepIos4Title => 'Choose your widget size';

  @override
  String get widgetSetupStepIos4Desc => 'Select small, medium, or large';

  @override
  String get widgetSetupStepIos5Title => 'Add Widget';

  @override
  String get widgetSetupStepIos5Desc => 'Tap \"Add Widget\" and you\'re done!';

  @override
  String get widgetSetupStepAndroid1Title => 'Long press on your home screen';

  @override
  String get widgetSetupStepAndroid1Desc =>
      'Press and hold any empty area on your home screen';

  @override
  String get widgetSetupStepAndroid2Title => 'Tap \"Widgets\"';

  @override
  String get widgetSetupStepAndroid2Desc =>
      'Select the widgets option from the menu';

  @override
  String get widgetSetupStepAndroid3Title => 'Find \"Myself 2.0\"';

  @override
  String get widgetSetupStepAndroid3Desc => 'Scroll or search for our app';

  @override
  String get widgetSetupStepAndroid4Title => 'Drag the widget';

  @override
  String get widgetSetupStepAndroid4Desc =>
      'Hold and drag the widget to your home screen';

  @override
  String get widgetSetupStepAndroid5Title => 'Release to place';

  @override
  String get widgetSetupStepAndroid5Desc =>
      'Drop it where you want and you\'re done!';
}
