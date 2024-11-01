enum Language { en, fr }

class TextManager {
  // Prepare the singleton
  static final TextManager _singleton = TextManager._();
  static TextManager get instance => _singleton;
  TextManager._();

  // The current language
  Language language = Language.fr;

  // The title
  String get title => language == Language.en ? 'Flight Time' : 'Temps de vol';

  // The MainDrawer related texts
  String get camera => language == Language.en ? 'Camera' : 'Caméra';

  String get playback => language == Language.en ? 'Playback' : 'Lecture';

  // The Recording related texts
  String get recordingVideo =>
      language == Language.en ? 'Video recording' : 'Enregistrement video';

  String get preparingTrial => language == Language.en
      ? 'Preparing the video'
      : 'Préparation de la vidéo';

  String get visualizingVideo => language == Language.en
      ? 'Visualizing video'
      : 'Visionnement de la vidéo';

  // Save trial dialog texts
  String get saveTrial =>
      language == Language.en ? 'Save Trial' : 'Sauvegarder l\'essai';

  String get athleteName =>
      language == Language.en ? 'Athlete name' : 'Nom de l\'athlète';

  String get trialName =>
      language == Language.en ? 'Trial name' : 'Nom de l\'essai';

  // Show trial texts
  String get flightTime => language == Language.en ? 'Time' : 'Temps';

  String get flightHeight => language == Language.en ? 'Height' : 'Hauteur';

  String get areYouSureDelete => language == Language.en
      ? 'Do you really want to delete the video?'
      : 'Voulez-vous vraiment supprimer la vidéo?';

  // Misc texts
  String get areYouSureQuit => language == Language.en
      ? 'Do you really want to quit?'
      : 'Voulez-vous vraiment quitter?';

  String get youWillLoseYourProgress => language == Language.en
      ? 'You will lose your progress.'
      : 'Vous perdrez votre progression.';

  // The texts for the buttons
  String get confirm => language == Language.en ? 'Confirm' : 'Confirmer';

  String get cancel => language == Language.en ? 'Cancel' : 'Annuler';

  String get quit => language == Language.en ? 'Quit' : 'Quitter';

  String get no => language == Language.en ? 'No' : 'Non';

  String get yes => language == Language.en ? 'Yes' : 'Oui';

  String get unclassified =>
      language == Language.en ? 'Unclassified' : 'Non classés';
}
