enum Language { en, fr }

class Texts {
  // Prepare the singleton
  static final Texts _singleton = Texts._internal();
  static Texts get instance => _singleton;
  Texts._internal();

  // The current language
  Language language = Language.fr;

  // The Recording related texts
  String get recordingVideo =>
      language == Language.en ? 'Video recording' : 'Enregistrement video';

  String get preparingTrial =>
      language == Language.en ? 'Preparing trial' : 'Préparation de l\'essai';

  String get visualizingVideo => language == Language.en
      ? 'Visualizing video'
      : 'Visionnement de la vidéo';

  // Misc texts
  String get areYouSureToQuit => language == Language.en
      ? 'Are you sure to quit?'
      : 'Voulez-vous vraiment quitter?';

  String get youWillLoseYourProgress => language == Language.en
      ? 'You will lose your progress.'
      : 'Vous perdrez votre progression.';

  // The texts for the buttons
  String get cancel => language == Language.en ? 'Cancel' : 'Annuler';

  String get quit => language == Language.en ? 'Quit' : 'Quitter';
}
