// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Claymo';

  @override
  String get tagline => 'Learning to read is fun!';

  @override
  String get spelling => 'Spelling';

  @override
  String get spellingSubtitle => 'Build words with letters';

  @override
  String get phonics => 'Letters & Phonics';

  @override
  String get phonicsSubtitle => 'Learn letter sounds';

  @override
  String get quiz => 'Picture Quiz';

  @override
  String get quizSubtitle => 'Pick the right word';

  @override
  String get listen => 'Listen';

  @override
  String get next => 'Next';

  @override
  String get wellDone => 'Great job!';

  @override
  String get tryAgain => 'Let\'s try again!';

  @override
  String get back => 'Back';

  @override
  String get alphabet => 'Alphabet';

  @override
  String get syllables => 'Syllables';

  @override
  String get phonicsWords => 'Phonics Words';

  @override
  String get spellingHint => 'Tap the letters to spell the word';

  @override
  String get syllableHint => 'Tap a syllable to hear it';

  @override
  String get phonicsHint => 'Tap a word to hear it sounded out';

  @override
  String get playRow => 'Play all syllables';

  @override
  String get quizPrompt => 'What is this?';

  @override
  String questionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get roundComplete => 'You did amazing!';

  @override
  String roundScore(int score, int total) {
    return '$score of $total correct';
  }

  @override
  String get playAgain => 'Play again';

  @override
  String get backHome => 'Back home';

  @override
  String get switchGreeting => 'Hello! Let\'s learn English!';

  @override
  String get languageLabel => 'Language';

  @override
  String get starsLabel => 'Stars';

  @override
  String wordProgress(int current, int total) {
    return 'Word $current of $total';
  }

  @override
  String get loading => 'Loading';

  @override
  String get navHome => 'Home';

  @override
  String get navSpell => 'Spell';

  @override
  String get navLetters => 'Letters';

  @override
  String get navQuiz => 'Guess';

  @override
  String get navAlbum => 'Album';

  @override
  String get heroTitle => 'Hello, Claymo Friend!';

  @override
  String get heroSubtitle => 'Let\'s learn to read and spell!';

  @override
  String get menuLetters => 'Letters';

  @override
  String get menuLettersSubtitle => 'A–Z & phonics';

  @override
  String get albumTitle => 'Sticker Album';

  @override
  String get albumSubtitle => 'My collection';

  @override
  String get slow => 'Slow';

  @override
  String get listenQuestion => 'Hear Question';

  @override
  String get playAll => 'Read All';

  @override
  String get syllableTouch => 'Touch a word to hear it';

  @override
  String albumStars(int count) {
    return '$count ⭐ collected';
  }

  @override
  String albumNext(int count, String emoji, String name) {
    return '$count ⭐ more for the $emoji $name sticker';
  }

  @override
  String get albumDone => 'Wow! All stickers collected! 🎉';

  @override
  String stickerUnlocked(String emoji, String name) {
    return 'New sticker! $emoji $name';
  }

  @override
  String get quizThinking => 'What is this? 🤔';
}
