import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Claymo'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In id, this message translates to:
  /// **'Belajar membaca itu seru!'**
  String get tagline;

  /// No description provided for @spelling.
  ///
  /// In id, this message translates to:
  /// **'Mengeja'**
  String get spelling;

  /// No description provided for @spellingSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Susun huruf jadi kata'**
  String get spellingSubtitle;

  /// No description provided for @phonics.
  ///
  /// In id, this message translates to:
  /// **'Huruf & Suku Kata'**
  String get phonics;

  /// No description provided for @phonicsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kenali bunyi huruf'**
  String get phonicsSubtitle;

  /// No description provided for @quiz.
  ///
  /// In id, this message translates to:
  /// **'Tebak Gambar'**
  String get quiz;

  /// No description provided for @quizSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih kata yang benar'**
  String get quizSubtitle;

  /// No description provided for @listen.
  ///
  /// In id, this message translates to:
  /// **'Dengarkan'**
  String get listen;

  /// No description provided for @next.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get next;

  /// No description provided for @wellDone.
  ///
  /// In id, this message translates to:
  /// **'Hebat!'**
  String get wellDone;

  /// No description provided for @tryAgain.
  ///
  /// In id, this message translates to:
  /// **'Ayo coba lagi!'**
  String get tryAgain;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @alphabet.
  ///
  /// In id, this message translates to:
  /// **'Alfabet'**
  String get alphabet;

  /// No description provided for @syllables.
  ///
  /// In id, this message translates to:
  /// **'Suku Kata'**
  String get syllables;

  /// No description provided for @phonicsWords.
  ///
  /// In id, this message translates to:
  /// **'Kata Fonik'**
  String get phonicsWords;

  /// No description provided for @spellingHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk huruf untuk menyusun kata'**
  String get spellingHint;

  /// No description provided for @syllableHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk suku kata untuk mendengarnya'**
  String get syllableHint;

  /// No description provided for @phonicsHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk kata untuk mendengar bunyinya'**
  String get phonicsHint;

  /// No description provided for @playRow.
  ///
  /// In id, this message translates to:
  /// **'Putar semua suku kata'**
  String get playRow;

  /// No description provided for @quizPrompt.
  ///
  /// In id, this message translates to:
  /// **'Gambar apa ini?'**
  String get quizPrompt;

  /// No description provided for @questionProgress.
  ///
  /// In id, this message translates to:
  /// **'Soal {current} dari {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @roundComplete.
  ///
  /// In id, this message translates to:
  /// **'Kamu hebat sekali!'**
  String get roundComplete;

  /// No description provided for @roundScore.
  ///
  /// In id, this message translates to:
  /// **'{score} dari {total} benar'**
  String roundScore(int score, int total);

  /// No description provided for @playAgain.
  ///
  /// In id, this message translates to:
  /// **'Main lagi'**
  String get playAgain;

  /// No description provided for @backHome.
  ///
  /// In id, this message translates to:
  /// **'Ke beranda'**
  String get backHome;

  /// No description provided for @switchGreeting.
  ///
  /// In id, this message translates to:
  /// **'Halo! Ayo belajar bahasa Indonesia!'**
  String get switchGreeting;

  /// No description provided for @languageLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get languageLabel;

  /// No description provided for @starsLabel.
  ///
  /// In id, this message translates to:
  /// **'Bintang'**
  String get starsLabel;

  /// No description provided for @wordProgress.
  ///
  /// In id, this message translates to:
  /// **'Kata {current} dari {total}'**
  String wordProgress(int current, int total);

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat'**
  String get loading;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navHome;

  /// No description provided for @navSpell.
  ///
  /// In id, this message translates to:
  /// **'Eja'**
  String get navSpell;

  /// No description provided for @navLetters.
  ///
  /// In id, this message translates to:
  /// **'Huruf'**
  String get navLetters;

  /// No description provided for @navQuiz.
  ///
  /// In id, this message translates to:
  /// **'Tebak'**
  String get navQuiz;

  /// No description provided for @navAlbum.
  ///
  /// In id, this message translates to:
  /// **'Album'**
  String get navAlbum;

  /// No description provided for @heroTitle.
  ///
  /// In id, this message translates to:
  /// **'Halo, Teman Claymo!'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ayo belajar membaca dan mengeja!'**
  String get heroSubtitle;

  /// No description provided for @menuLetters.
  ///
  /// In id, this message translates to:
  /// **'Huruf'**
  String get menuLetters;

  /// No description provided for @menuLettersSubtitle.
  ///
  /// In id, this message translates to:
  /// **'A–Z & suku kata'**
  String get menuLettersSubtitle;

  /// No description provided for @albumTitle.
  ///
  /// In id, this message translates to:
  /// **'Album Stiker'**
  String get albumTitle;

  /// No description provided for @albumSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Koleksiku'**
  String get albumSubtitle;

  /// No description provided for @slow.
  ///
  /// In id, this message translates to:
  /// **'Pelan'**
  String get slow;

  /// No description provided for @listenQuestion.
  ///
  /// In id, this message translates to:
  /// **'Dengar Soal'**
  String get listenQuestion;

  /// No description provided for @playAll.
  ///
  /// In id, this message translates to:
  /// **'Baca Semua'**
  String get playAll;

  /// No description provided for @syllableTouch.
  ///
  /// In id, this message translates to:
  /// **'Sentuh suku kata untuk mendengarnya'**
  String get syllableTouch;

  /// No description provided for @albumStars.
  ///
  /// In id, this message translates to:
  /// **'{count} ⭐ terkumpul'**
  String albumStars(int count);

  /// No description provided for @albumNext.
  ///
  /// In id, this message translates to:
  /// **'{count} ⭐ lagi untuk stiker {emoji} {name}'**
  String albumNext(int count, String emoji, String name);

  /// No description provided for @albumDone.
  ///
  /// In id, this message translates to:
  /// **'Wow! Semua stiker terkumpul! 🎉'**
  String get albumDone;

  /// No description provided for @stickerUnlocked.
  ///
  /// In id, this message translates to:
  /// **'Stiker baru! {emoji} {name}'**
  String stickerUnlocked(String emoji, String name);

  /// No description provided for @quizThinking.
  ///
  /// In id, this message translates to:
  /// **'Gambar apa ini? 🤔'**
  String get quizThinking;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
