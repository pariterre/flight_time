import 'package:flight_time/models/custom_callback.dart';

enum Language { en, fr }

class TranslatableString {
  final String en;
  final String fr;

  TranslatableString({required this.en, required this.fr});

  String get value => TextManager.instance.language == Language.en ? en : fr;
}

class TextManager {
  // Prepare the singleton
  static final TextManager _singleton = TextManager._();
  static TextManager get instance => _singleton;
  TextManager._();

  // The current language
  Language _language = Language.fr;
  Language get language => _language;
  set language(Language value) {
    _language = value;
    onLanguageChanged.notifyListeners();
  }

  final onLanguageChanged = CustomCallback<void Function()>();

  // The title
  TranslatableString get title =>
      TranslatableString(en: 'Flight Time', fr: 'Temps de vol');

  // The MainDrawer related texts
  TranslatableString get camera =>
      TranslatableString(en: 'Camera', fr: 'Caméra');

  TranslatableString get playback =>
      TranslatableString(en: 'Playback', fr: 'Lecture');

  // The Recording related texts
  TranslatableString get recordingVideo =>
      TranslatableString(en: 'Video recording', fr: 'Enregistrement video');

  TranslatableString get preparingTrial => TranslatableString(
      en: 'Preparing the video', fr: 'Préparation de la vidéo');

  TranslatableString get visualizingVideo => TranslatableString(
      en: 'Visualizing video', fr: 'Visionnement de la vidéo');

  // Save trial dialog texts
  TranslatableString get saveTrial =>
      TranslatableString(en: 'Save Trial', fr: 'Sauvegarder l\'essai');

  TranslatableString get athleteName =>
      TranslatableString(en: 'Athlete name', fr: 'Nom de l\'athlète');

  TranslatableString get trialName =>
      TranslatableString(en: 'Trial name', fr: 'Nom de l\'essai');

  // Show trial texts
  TranslatableString get flightTime =>
      TranslatableString(en: 'Time', fr: 'Temps');

  TranslatableString get flightHeight =>
      TranslatableString(en: 'Height', fr: 'Hauteur');

  TranslatableString get areYouSureDelete => TranslatableString(
      en: 'Do you really want to delete the video?',
      fr: 'Voulez-vous vraiment supprimer la vidéo?');

  // Misc texts
  TranslatableString get areYouSureQuit => TranslatableString(
      en: 'Do you really want to quit?', fr: 'Voulez-vous vraiment quitter?');

  TranslatableString get youWillLoseYourProgress => TranslatableString(
      en: 'You will lose your progress.',
      fr: 'Vous perdrez votre progression.');

  // The texts for the buttons
  TranslatableString get confirm =>
      TranslatableString(en: 'Confirm', fr: 'Confirmer');

  TranslatableString get cancel =>
      TranslatableString(en: 'Cancel', fr: 'Annuler');

  TranslatableString get quit => TranslatableString(en: 'Quit', fr: 'Quitter');

  TranslatableString get no => TranslatableString(en: 'No', fr: 'Non');

  TranslatableString get yes => TranslatableString(en: 'Yes', fr: 'Oui');

  TranslatableString get unclassified =>
      TranslatableString(en: 'Unclassified', fr: 'Non classés');
}
