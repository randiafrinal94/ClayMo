// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Claymo';

  @override
  String get tagline => 'Belajar membaca itu seru!';

  @override
  String get spelling => 'Mengeja';

  @override
  String get spellingSubtitle => 'Susun huruf jadi kata';

  @override
  String get phonics => 'Huruf & Suku Kata';

  @override
  String get phonicsSubtitle => 'Kenali bunyi huruf';

  @override
  String get quiz => 'Tebak Gambar';

  @override
  String get quizSubtitle => 'Pilih kata yang benar';

  @override
  String get listen => 'Dengarkan';

  @override
  String get next => 'Lanjut';

  @override
  String get wellDone => 'Hebat!';

  @override
  String get tryAgain => 'Ayo coba lagi!';

  @override
  String get back => 'Kembali';

  @override
  String get alphabet => 'Alfabet';

  @override
  String get syllables => 'Suku Kata';

  @override
  String get phonicsWords => 'Kata Fonik';

  @override
  String get spellingHint => 'Ketuk huruf untuk menyusun kata';

  @override
  String get syllableHint => 'Ketuk suku kata untuk mendengarnya';

  @override
  String get phonicsHint => 'Ketuk kata untuk mendengar bunyinya';

  @override
  String get playRow => 'Putar semua suku kata';

  @override
  String get quizPrompt => 'Gambar apa ini?';

  @override
  String questionProgress(int current, int total) {
    return 'Soal $current dari $total';
  }

  @override
  String get roundComplete => 'Kamu hebat sekali!';

  @override
  String roundScore(int score, int total) {
    return '$score dari $total benar';
  }

  @override
  String get playAgain => 'Main lagi';

  @override
  String get backHome => 'Ke beranda';

  @override
  String get switchGreeting => 'Halo! Ayo belajar bahasa Indonesia!';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get starsLabel => 'Bintang';

  @override
  String wordProgress(int current, int total) {
    return 'Kata $current dari $total';
  }

  @override
  String get loading => 'Memuat';

  @override
  String get navHome => 'Beranda';

  @override
  String get navSpell => 'Eja';

  @override
  String get navLetters => 'Huruf';

  @override
  String get navQuiz => 'Tebak';

  @override
  String get navAlbum => 'Album';

  @override
  String get heroTitle => 'Halo, Teman Claymo!';

  @override
  String get heroSubtitle => 'Ayo belajar membaca dan mengeja!';

  @override
  String get menuLetters => 'Huruf';

  @override
  String get menuLettersSubtitle => 'A–Z & suku kata';

  @override
  String get albumTitle => 'Album Stiker';

  @override
  String get albumSubtitle => 'Koleksiku';

  @override
  String get slow => 'Pelan';

  @override
  String get listenQuestion => 'Dengar Soal';

  @override
  String get playAll => 'Baca Semua';

  @override
  String get syllableTouch => 'Sentuh suku kata untuk mendengarnya';

  @override
  String albumStars(int count) {
    return '$count ⭐ terkumpul';
  }

  @override
  String albumNext(int count, String emoji, String name) {
    return '$count ⭐ lagi untuk stiker $emoji $name';
  }

  @override
  String get albumDone => 'Wow! Semua stiker terkumpul! 🎉';

  @override
  String stickerUnlocked(String emoji, String name) {
    return 'Stiker baru! $emoji $name';
  }

  @override
  String get quizThinking => 'Gambar apa ini? 🤔';
}
