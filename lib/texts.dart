enum Language { en, fr }

class Texts {
  // Prepare the singleton
  static final Texts _singleton = Texts._();
  static Texts get instance => _singleton;
  Texts._();

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

  // Save trial dialog texts
  String get saveTrial =>
      language == Language.en ? 'Save Trial' : 'Sauvegarder l\'essai';

  String get athleteName =>
      language == Language.en ? 'Athlete name' : 'Nom de l\'athlète';

  String get trialName =>
      language == Language.en ? 'Trial name' : 'Nom de l\'essai';

  // Misc texts
  String get areYouSureToQuit => language == Language.en
      ? 'Are you sure to quit?'
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
}
