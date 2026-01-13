// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Moi-même 2.0';

  @override
  String get myAffirmations => 'Mes Affirmations';

  @override
  String get myAffirmationsHint => 'Naviguer pour voir toutes vos affirmations';

  @override
  String get settings => 'Paramètres';

  @override
  String get settingsHint => 'Naviguer vers les paramètres de l\'application';

  @override
  String get tapToRefresh => 'Appuyez pour actualiser';

  @override
  String get swipeToRefresh => 'Balayez pour actualiser';

  @override
  String get refresh => 'Actualiser';

  @override
  String get refreshAffirmation => 'Actualiser l\'affirmation';

  @override
  String get showNewAffirmation => 'Afficher une nouvelle affirmation';

  @override
  String get createFirstAffirmation => 'Créer Votre Première Affirmation';

  @override
  String get affirmations => 'Affirmations';

  @override
  String get addAffirmation => 'Ajouter une Affirmation';

  @override
  String get createNewAffirmation => 'Créer une nouvelle affirmation';

  @override
  String get editAffirmation => 'Modifier l\'affirmation';

  @override
  String get deleteAffirmation => 'Supprimer l\'affirmation';

  @override
  String get newAffirmation => 'Nouvelle Affirmation';

  @override
  String get editAffirmationTitle => 'Modifier l\'Affirmation';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get affirmationPlaceholder => 'Entrez votre affirmation...';

  @override
  String charactersRemaining(int count) {
    return '$count caractères restants';
  }

  @override
  String charactersOver(int count) {
    return '$count caractères au-delà de la limite';
  }

  @override
  String get unsavedChanges => 'Modifications Non Enregistrées';

  @override
  String get unsavedChangesMessage =>
      'Vous avez des modifications non enregistrées. Êtes-vous sûr de vouloir quitter ?';

  @override
  String get leave => 'Quitter';

  @override
  String get stayAndEdit => 'Rester et Modifier';

  @override
  String get affirmationCannotBeEmpty => 'L\'affirmation ne peut pas être vide';

  @override
  String get affirmationTooLong => 'L\'affirmation dépasse 280 caractères';

  @override
  String get affirmationSaved => 'Affirmation enregistrée avec succès';

  @override
  String get deleteAffirmationTitle => 'Supprimer l\'Affirmation ?';

  @override
  String get deleteAffirmationMessage =>
      'Êtes-vous sûr de vouloir supprimer cette affirmation ? Cette action ne peut pas être annulée.';

  @override
  String get delete => 'Supprimer';

  @override
  String get affirmationDeleted => 'Affirmation supprimée';

  @override
  String get noAffirmationsYet => 'Aucune Affirmation Pour le Moment';

  @override
  String get createFirstAffirmationMessage =>
      'Commencez votre voyage en créant votre première affirmation. Elle apparaîtra ici et sur votre widget d\'accueil.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get chooseTheme => 'Choisissez votre thème préféré';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeLightDescription => 'Lumineux et net';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeDarkDescription => 'Doux pour les yeux';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeSystemDescription => 'Correspond à votre appareil';

  @override
  String get fontSize => 'Taille de Police';

  @override
  String get fontSizeDescription =>
      'Ajustez la taille du texte pour une meilleure lisibilité';

  @override
  String get fontSizeSmall => 'Petit';

  @override
  String get fontSizeDefault => 'Par Défaut';

  @override
  String get fontSizeLarge => 'Grand';

  @override
  String get fontSizeExtraLarge => 'Très Grand';

  @override
  String get widgetSettings => 'Paramètres du Widget';

  @override
  String get refreshMode => 'Mode d\'Actualisation';

  @override
  String get refreshModeDescription =>
      'Quand afficher une nouvelle affirmation';

  @override
  String get refreshModeUnlock => 'À Chaque Déverrouillage';

  @override
  String get refreshModeUnlockDescription =>
      'Nouvelle affirmation à chaque fois que vous déverrouillez votre téléphone';

  @override
  String get refreshModeHourly => 'Toutes les Heures';

  @override
  String get refreshModeHourlyDescription =>
      'Nouvelle affirmation toutes les heures';

  @override
  String get refreshModeDaily => 'Quotidien';

  @override
  String get refreshModeDailyDescription =>
      'Nouvelle affirmation une fois par jour';

  @override
  String get widgetRotation => 'Rotation du Widget';

  @override
  String get widgetRotationDescription =>
      'Permettre aux affirmations de changer sur le widget d\'accueil';

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String get preferences => 'Préférences';

  @override
  String get language => 'Langue';

  @override
  String get languageDescription => 'Choisissez votre langue préférée';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get welcomeTitle => 'Bienvenue dans Moi-même 2.0';

  @override
  String get welcomeSubtitle =>
      'Se transformer par la répétition et l\'intention';

  @override
  String get welcomeDescription =>
      'Moi-même 2.0 vous aide à devenir qui vous voulez être grâce au pouvoir des affirmations quotidiennes.\n\nVoyez-vous, devenez vous-même.';

  @override
  String get letsBegin => 'Commençons';

  @override
  String get congratulations => 'Félicitations !';

  @override
  String get firstAffirmationCreated =>
      'Vous avez créé votre première affirmation';

  @override
  String get continueButton => 'Continuer';

  @override
  String get widgetSetupTitle => 'Ajouter à Votre Écran d\'Accueil';

  @override
  String get widgetSetupDescription =>
      'Voyez vos affirmations chaque fois que vous déverrouillez votre téléphone en ajoutant le widget Moi-même à votre écran d\'accueil.';

  @override
  String get widgetSetupIosInstructions =>
      '1. Appuyez longuement sur votre écran d\'accueil\n2. Appuyez sur le bouton + dans le coin supérieur\n3. Recherchez \"Moi-même\"\n4. Choisissez la taille de widget préférée\n5. Appuyez sur \"Ajouter Widget\"';

  @override
  String get widgetSetupAndroidInstructions =>
      '1. Appuyez longuement sur votre écran d\'accueil\n2. Appuyez sur \"Widgets\"\n3. Trouvez \"Moi-même\" dans la liste\n4. Appuyez longuement et faites glisser vers votre écran d\'accueil\n5. Choisissez votre taille préférée';

  @override
  String get gotIt => 'Compris';

  @override
  String get skipForNow => 'Passer Pour l\'Instant';

  @override
  String get errorLoadingAffirmations =>
      'Erreur lors du chargement des affirmations';

  @override
  String get errorSavingAffirmation =>
      'Erreur lors de l\'enregistrement de l\'affirmation';

  @override
  String get errorDeletingAffirmation =>
      'Erreur lors de la suppression de l\'affirmation';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get affirmationCard => 'Carte d\'affirmation';

  @override
  String get closeButton => 'Fermer';

  @override
  String get backButton => 'Retour';
}
