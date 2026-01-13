import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The application title displayed in the app bar
  ///
  /// In en, this message translates to:
  /// **'Myself 2.0'**
  String get appTitle;

  /// Label for button to view all affirmations
  ///
  /// In en, this message translates to:
  /// **'My Affirmations'**
  String get myAffirmations;

  /// Accessibility hint for affirmations list button
  ///
  /// In en, this message translates to:
  /// **'Navigate to view all your affirmations'**
  String get myAffirmationsHint;

  /// Label for settings button and screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Accessibility hint for settings button
  ///
  /// In en, this message translates to:
  /// **'Navigate to app settings'**
  String get settingsHint;

  /// Instruction to tap for a new affirmation
  ///
  /// In en, this message translates to:
  /// **'Tap to refresh'**
  String get tapToRefresh;

  /// Instruction to swipe for a new affirmation
  ///
  /// In en, this message translates to:
  /// **'Swipe to refresh'**
  String get swipeToRefresh;

  /// Label for refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Accessibility label for refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh affirmation'**
  String get refreshAffirmation;

  /// Accessibility hint for refresh button
  ///
  /// In en, this message translates to:
  /// **'Show a new affirmation'**
  String get showNewAffirmation;

  /// Button label prompting user to create first affirmation
  ///
  /// In en, this message translates to:
  /// **'Create Your First Affirmation'**
  String get createFirstAffirmation;

  /// Title for affirmations list screen
  ///
  /// In en, this message translates to:
  /// **'Affirmations'**
  String get affirmations;

  /// Label for button to add a new affirmation
  ///
  /// In en, this message translates to:
  /// **'Add Affirmation'**
  String get addAffirmation;

  /// Accessibility hint for add affirmation button
  ///
  /// In en, this message translates to:
  /// **'Create a new affirmation'**
  String get createNewAffirmation;

  /// Label for edit affirmation button
  ///
  /// In en, this message translates to:
  /// **'Edit affirmation'**
  String get editAffirmation;

  /// Label for delete affirmation button
  ///
  /// In en, this message translates to:
  /// **'Delete affirmation'**
  String get deleteAffirmation;

  /// Title for creating a new affirmation
  ///
  /// In en, this message translates to:
  /// **'New Affirmation'**
  String get newAffirmation;

  /// Title for editing an existing affirmation
  ///
  /// In en, this message translates to:
  /// **'Edit Affirmation'**
  String get editAffirmationTitle;

  /// Label for save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Label for cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Placeholder text for affirmation input field
  ///
  /// In en, this message translates to:
  /// **'Enter your affirmation...'**
  String get affirmationPlaceholder;

  /// Shows how many characters are left
  ///
  /// In en, this message translates to:
  /// **'{count} characters remaining'**
  String charactersRemaining(int count);

  /// Shows how many characters over the limit
  ///
  /// In en, this message translates to:
  /// **'{count} characters over limit'**
  String charactersOver(int count);

  /// Dialog title for unsaved changes warning
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// Message asking user to confirm leaving with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave?'**
  String get unsavedChangesMessage;

  /// Button to leave screen without saving
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// Button to stay on screen and continue editing
  ///
  /// In en, this message translates to:
  /// **'Stay and Edit'**
  String get stayAndEdit;

  /// Error message when trying to save empty affirmation
  ///
  /// In en, this message translates to:
  /// **'Affirmation cannot be empty'**
  String get affirmationCannotBeEmpty;

  /// Error message when affirmation is too long
  ///
  /// In en, this message translates to:
  /// **'Affirmation exceeds 280 characters'**
  String get affirmationTooLong;

  /// Success message after saving affirmation
  ///
  /// In en, this message translates to:
  /// **'Affirmation saved successfully'**
  String get affirmationSaved;

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Affirmation?'**
  String get deleteAffirmationTitle;

  /// Message asking user to confirm deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this affirmation? This action cannot be undone.'**
  String get deleteAffirmationMessage;

  /// Button to confirm deletion
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Message shown after affirmation is deleted
  ///
  /// In en, this message translates to:
  /// **'Affirmation deleted'**
  String get affirmationDeleted;

  /// Title shown when user has no affirmations
  ///
  /// In en, this message translates to:
  /// **'No Affirmations Yet'**
  String get noAffirmationsYet;

  /// Message encouraging user to create first affirmation
  ///
  /// In en, this message translates to:
  /// **'Start your journey by creating your first affirmation. It will appear here and on your home widget.'**
  String get createFirstAffirmationMessage;

  /// Button label to start creating affirmations
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Section header for appearance settings
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Label for theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Description for theme setting
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme'**
  String get chooseTheme;

  /// Label for light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Description for light theme
  ///
  /// In en, this message translates to:
  /// **'Bright and clear'**
  String get themeLightDescription;

  /// Label for dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Description for dark theme
  ///
  /// In en, this message translates to:
  /// **'Easy on the eyes'**
  String get themeDarkDescription;

  /// Label for system theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Description for system theme
  ///
  /// In en, this message translates to:
  /// **'Matches your device'**
  String get themeSystemDescription;

  /// Label for font size setting
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Description for font size setting
  ///
  /// In en, this message translates to:
  /// **'Adjust text size for better readability'**
  String get fontSizeDescription;

  /// Label for small font size
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// Label for default font size
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get fontSizeDefault;

  /// Label for large font size
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// Label for extra large font size
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get fontSizeExtraLarge;

  /// Section header for widget settings
  ///
  /// In en, this message translates to:
  /// **'Widget Settings'**
  String get widgetSettings;

  /// Label for refresh mode setting
  ///
  /// In en, this message translates to:
  /// **'Refresh Mode'**
  String get refreshMode;

  /// Description for refresh mode setting
  ///
  /// In en, this message translates to:
  /// **'When to show a new affirmation'**
  String get refreshModeDescription;

  /// Label for unlock refresh mode
  ///
  /// In en, this message translates to:
  /// **'Every Unlock'**
  String get refreshModeUnlock;

  /// Description for unlock refresh mode
  ///
  /// In en, this message translates to:
  /// **'New affirmation each time you unlock your phone'**
  String get refreshModeUnlockDescription;

  /// Label for hourly refresh mode
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get refreshModeHourly;

  /// Description for hourly refresh mode
  ///
  /// In en, this message translates to:
  /// **'New affirmation every hour'**
  String get refreshModeHourlyDescription;

  /// Label for daily refresh mode
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get refreshModeDaily;

  /// Description for daily refresh mode
  ///
  /// In en, this message translates to:
  /// **'New affirmation once a day'**
  String get refreshModeDailyDescription;

  /// Label for widget rotation setting
  ///
  /// In en, this message translates to:
  /// **'Widget Rotation'**
  String get widgetRotation;

  /// Description for widget rotation setting
  ///
  /// In en, this message translates to:
  /// **'Allow affirmations to change on home widget'**
  String get widgetRotationDescription;

  /// Label for enabled state
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Label for disabled state
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Section header for preferences
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Label for language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Description for language setting
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageDescription;

  /// Label for English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Label for French language option
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Title for welcome screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Myself 2.0'**
  String get welcomeTitle;

  /// Subtitle for welcome screen
  ///
  /// In en, this message translates to:
  /// **'Transform through repetition and intention'**
  String get welcomeSubtitle;

  /// Description on welcome screen
  ///
  /// In en, this message translates to:
  /// **'Myself 2.0 helps you become who you want to be through the power of daily affirmations.\n\nSee yourself, become yourself.'**
  String get welcomeDescription;

  /// Button to start onboarding
  ///
  /// In en, this message translates to:
  /// **'Let\'s Begin'**
  String get letsBegin;

  /// Success message title
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Success message for creating first affirmation
  ///
  /// In en, this message translates to:
  /// **'You\'ve created your first affirmation'**
  String get firstAffirmationCreated;

  /// Button to continue onboarding
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Title for widget setup instructions
  ///
  /// In en, this message translates to:
  /// **'Add to Your Home Screen'**
  String get widgetSetupTitle;

  /// Description for widget setup
  ///
  /// In en, this message translates to:
  /// **'See your affirmations every time you unlock your phone by adding the Myself widget to your home screen.'**
  String get widgetSetupDescription;

  /// Instructions for adding widget on iOS
  ///
  /// In en, this message translates to:
  /// **'1. Long press on your home screen\n2. Tap the + button in the top corner\n3. Search for \"Myself\"\n4. Choose your preferred widget size\n5. Tap \"Add Widget\"'**
  String get widgetSetupIosInstructions;

  /// Instructions for adding widget on Android
  ///
  /// In en, this message translates to:
  /// **'1. Long press on your home screen\n2. Tap \"Widgets\"\n3. Find \"Myself\" in the list\n4. Long press and drag to your home screen\n5. Choose your preferred size'**
  String get widgetSetupAndroidInstructions;

  /// Button to acknowledge widget setup instructions
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;

  /// Button to skip widget setup
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// Error message when affirmations fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading affirmations'**
  String get errorLoadingAffirmations;

  /// Error message when affirmation fails to save
  ///
  /// In en, this message translates to:
  /// **'Error saving affirmation'**
  String get errorSavingAffirmation;

  /// Error message when affirmation fails to delete
  ///
  /// In en, this message translates to:
  /// **'Error deleting affirmation'**
  String get errorDeletingAffirmation;

  /// Button to retry an action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Accessibility label for affirmation card
  ///
  /// In en, this message translates to:
  /// **'Affirmation card'**
  String get affirmationCard;

  /// Accessibility label for close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// Accessibility label for back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// iOS widget setup step 1 title
  ///
  /// In en, this message translates to:
  /// **'Long press on your home screen'**
  String get widgetSetupStepIos1Title;

  /// iOS widget setup step 1 description
  ///
  /// In en, this message translates to:
  /// **'Press and hold any empty area on your home screen'**
  String get widgetSetupStepIos1Desc;

  /// iOS widget setup step 2 title
  ///
  /// In en, this message translates to:
  /// **'Tap the + button'**
  String get widgetSetupStepIos2Title;

  /// iOS widget setup step 2 description
  ///
  /// In en, this message translates to:
  /// **'Look for the plus icon in the top-left corner'**
  String get widgetSetupStepIos2Desc;

  /// iOS widget setup step 3 title
  ///
  /// In en, this message translates to:
  /// **'Search for \"Myself 2.0\"'**
  String get widgetSetupStepIos3Title;

  /// iOS widget setup step 3 description
  ///
  /// In en, this message translates to:
  /// **'Find our app in the widget gallery'**
  String get widgetSetupStepIos3Desc;

  /// iOS widget setup step 4 title
  ///
  /// In en, this message translates to:
  /// **'Choose your widget size'**
  String get widgetSetupStepIos4Title;

  /// iOS widget setup step 4 description
  ///
  /// In en, this message translates to:
  /// **'Select small, medium, or large'**
  String get widgetSetupStepIos4Desc;

  /// iOS widget setup step 5 title
  ///
  /// In en, this message translates to:
  /// **'Add Widget'**
  String get widgetSetupStepIos5Title;

  /// iOS widget setup step 5 description
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Widget\" and you\'re done!'**
  String get widgetSetupStepIos5Desc;

  /// Android widget setup step 1 title
  ///
  /// In en, this message translates to:
  /// **'Long press on your home screen'**
  String get widgetSetupStepAndroid1Title;

  /// Android widget setup step 1 description
  ///
  /// In en, this message translates to:
  /// **'Press and hold any empty area on your home screen'**
  String get widgetSetupStepAndroid1Desc;

  /// Android widget setup step 2 title
  ///
  /// In en, this message translates to:
  /// **'Tap \"Widgets\"'**
  String get widgetSetupStepAndroid2Title;

  /// Android widget setup step 2 description
  ///
  /// In en, this message translates to:
  /// **'Select the widgets option from the menu'**
  String get widgetSetupStepAndroid2Desc;

  /// Android widget setup step 3 title
  ///
  /// In en, this message translates to:
  /// **'Find \"Myself 2.0\"'**
  String get widgetSetupStepAndroid3Title;

  /// Android widget setup step 3 description
  ///
  /// In en, this message translates to:
  /// **'Scroll or search for our app'**
  String get widgetSetupStepAndroid3Desc;

  /// Android widget setup step 4 title
  ///
  /// In en, this message translates to:
  /// **'Drag the widget'**
  String get widgetSetupStepAndroid4Title;

  /// Android widget setup step 4 description
  ///
  /// In en, this message translates to:
  /// **'Hold and drag the widget to your home screen'**
  String get widgetSetupStepAndroid4Desc;

  /// Android widget setup step 5 title
  ///
  /// In en, this message translates to:
  /// **'Release to place'**
  String get widgetSetupStepAndroid5Title;

  /// Android widget setup step 5 description
  ///
  /// In en, this message translates to:
  /// **'Drop it where you want and you\'re done!'**
  String get widgetSetupStepAndroid5Desc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
