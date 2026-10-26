import '../features/language/domain/app_language.dart';

/// Satu kata belajar + ilustrasi (emoji) sederhana.
class WordItem {
  const WordItem(this.word, this.emoji);

  /// Selalu huruf kapital untuk tampilan.
  final String word;
  final String emoji;

  List<String> get letters => word.split('');
}

/// Huruf alfabet + contoh kata untuk eksplorasi fonik.
class LetterExample {
  const LetterExample(this.letter, this.word, this.emoji);

  final String letter;
  final String word;
  final String emoji;
}

/// Keluarga kata fonik Inggris (word family), mis. "-at": cat, hat, bat.
class PhonicsGroup {
  const PhonicsGroup(this.title, this.words);

  final String title;
  final List<WordItem> words;
}

abstract final class WordBank {
  static List<WordItem> words(AppLanguage language) => switch (language) {
    AppLanguage.id => _wordsId,
    AppLanguage.en => _wordsEn,
  };

  static List<LetterExample> alphabet(AppLanguage language) => switch (language) {
    AppLanguage.id => _alphabetId,
    AppLanguage.en => _alphabetEn,
  };

  /// Konsonan untuk deret suku kata Indonesia (Ba-Bi-Bu-Be-Bo, ...).
  static const List<String> syllableConsonants = [
    'B',
    'C',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'R',
    'S',
    'T',
    'W',
    'Y',
    'Z', //
  ];
  static const List<String> syllableVowels = ['a', 'i', 'u', 'e', 'o'];

  static List<String> syllableRow(String consonant) => [for (final v in syllableVowels) '$consonant$v'];

  static List<PhonicsGroup> get phonicsGroups => _phonicsGroups;

  // ---------------------------------------------------------------------------
  // Bahasa Indonesia (maks. 6 huruf agar muat di slot)
  // ---------------------------------------------------------------------------
  static const _wordsId = [
    WordItem('BOLA', '⚽'),
    WordItem('KUCING', '🐱'),
    WordItem('BUKU', '📚'),
    WordItem('IKAN', '🐟'),
    WordItem('AYAM', '🐔'),
    WordItem('TOPI', '🧢'),
    WordItem('SAPI', '🐄'),
    WordItem('BUNGA', '🌸'),
    WordItem('MATA', '👀'),
    WordItem('RUMAH', '🏠'),
    WordItem('MOBIL', '🚗'),
    WordItem('BULAN', '🌙'),
    WordItem('PISANG', '🍌'),
    WordItem('KUDA', '🐴'),
    WordItem('APEL', '🍎'),
    WordItem('BEBEK', '🦆'),
  ];

  static const _wordsEn = [
    WordItem('BALL', '⚽'),
    WordItem('CAT', '🐱'),
    WordItem('DOG', '🐶'),
    WordItem('SUN', '☀️'),
    WordItem('FISH', '🐟'),
    WordItem('BOOK', '📚'),
    WordItem('CAR', '🚗'),
    WordItem('STAR', '⭐'),
    WordItem('TREE', '🌳'),
    WordItem('MOON', '🌙'),
    WordItem('APPLE', '🍎'),
    WordItem('DUCK', '🦆'),
    WordItem('HAT', '🎩'),
    WordItem('PIG', '🐷'),
    WordItem('BEE', '🐝'),
    WordItem('BED', '🛏️'),
    WordItem('CAKE', '🎂'),
    WordItem('BIRD', '🐦'),
  ];

  static const _alphabetId = [
    LetterExample('A', 'Ayam', '🐔'),
    LetterExample('B', 'Bola', '⚽'),
    LetterExample('C', 'Cicak', '🦎'),
    LetterExample('D', 'Domba', '🐑'),
    LetterExample('E', 'Elang', '🦅'),
    LetterExample('F', 'Foto', '📷'),
    LetterExample('G', 'Gajah', '🐘'),
    LetterExample('H', 'Hujan', '🌧️'),
    LetterExample('I', 'Ikan', '🐟'),
    LetterExample('J', 'Jeruk', '🍊'),
    LetterExample('K', 'Kucing', '🐱'),
    LetterExample('L', 'Lampu', '💡'),
    LetterExample('M', 'Mobil', '🚗'),
    LetterExample('N', 'Nanas', '🍍'),
    LetterExample('O', 'Ombak', '🌊'),
    LetterExample('P', 'Pisang', '🍌'),
    LetterExample('Q', 'Quran', '📖'),
    LetterExample('R', 'Rumah', '🏠'),
    LetterExample('S', 'Sapi', '🐄'),
    LetterExample('T', 'Topi', '🧢'),
    LetterExample('U', 'Ular', '🐍'),
    LetterExample('V', 'Vas', '🏺'),
    LetterExample('W', 'Wortel', '🥕'),
    LetterExample('X', 'Xilofon', '🎶'),
    LetterExample('Y', 'Yoyo', '🪀'),
    LetterExample('Z', 'Zebra', '🦓'),
  ];

  static const _alphabetEn = [
    LetterExample('A', 'Apple', '🍎'),
    LetterExample('B', 'Ball', '⚽'),
    LetterExample('C', 'Cat', '🐱'),
    LetterExample('D', 'Dog', '🐶'),
    LetterExample('E', 'Egg', '🥚'),
    LetterExample('F', 'Fish', '🐟'),
    LetterExample('G', 'Goat', '🐐'),
    LetterExample('H', 'Hat', '🎩'),
    LetterExample('I', 'Ice cream', '🍦'),
    LetterExample('J', 'Jet', '✈️'),
    LetterExample('K', 'King', '🤴'),
    LetterExample('L', 'Lion', '🦁'),
    LetterExample('M', 'Moon', '🌙'),
    LetterExample('N', 'Nose', '👃'),
    LetterExample('O', 'Orange', '🍊'),
    LetterExample('P', 'Pig', '🐷'),
    LetterExample('Q', 'Queen', '👸'),
    LetterExample('R', 'Rabbit', '🐰'),
    LetterExample('S', 'Sun', '☀️'),
    LetterExample('T', 'Tree', '🌳'),
    LetterExample('U', 'Umbrella', '☂️'),
    LetterExample('V', 'Van', '🚐'),
    LetterExample('W', 'Whale', '🐳'),
    LetterExample('X', 'Fox', '🦊'),
    LetterExample('Y', 'Yarn', '🧶'),
    LetterExample('Z', 'Zebra', '🦓'),
  ];

  static const _phonicsGroups = [
    PhonicsGroup('-at', [WordItem('CAT', '🐱'), WordItem('HAT', '🎩'), WordItem('BAT', '🦇'), WordItem('RAT', '🐀')]),
    PhonicsGroup('-og', [WordItem('DOG', '🐶'), WordItem('LOG', '🪵'), WordItem('FOG', '🌫️'), WordItem('HOG', '🐗')]),
    PhonicsGroup('-un', [WordItem('SUN', '☀️'), WordItem('BUN', '🍞'), WordItem('RUN', '🏃'), WordItem('FUN', '🎉')]),
    PhonicsGroup('-ig', [WordItem('PIG', '🐷'), WordItem('WIG', '💇'), WordItem('DIG', '⛏️'), WordItem('BIG', '🐘')]),
    PhonicsGroup('-ed', [WordItem('BED', '🛏️'), WordItem('RED', '🔴'), WordItem('FED', '🍼')]),
    PhonicsGroup('-ug', [WordItem('BUG', '🐛'), WordItem('HUG', '🤗'), WordItem('MUG', '☕'), WordItem('RUG', '🧶')]),
  ];
}
