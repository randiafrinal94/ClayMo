/// Normalisasi fonetik agar mesin TTS melafalkan huruf/suku kata dengan benar.
///
/// Bahasa Indonesia: huruf/suku kata berakhiran "e" (Be, De, Fe, Ce, ...)
/// dilafalkan e-taling (/e/) sesuai KBBI. Mesin TTS cenderung membacanya sebagai
/// pepet /ə/ atau menambahkan desah "h" di akhir, jadi vokalnya dipanjangkan
/// menjadi "ee" dan diberi spasi penutup: `Be` -> `"bee "`.
abstract final class IndonesianPhonetics {
  /// Nama huruf alfabet Indonesia (A–Z) dalam bentuk yang aman untuk TTS.
  static const Map<String, String> letterNames = {
    'a': 'a',
    'b': 'bee ',
    'c': 'cee ',
    'd': 'dee ',
    'e': 'ee ',
    'f': 'ef ',
    'g': 'gee ',
    'h': 'ha',
    'i': 'i',
    'j': 'jee ',
    'k': 'ka',
    'l': 'el',
    'm': 'em',
    'n': 'en',
    'o': 'o',
    'p': 'pee ',
    'q': 'ki',
    'r': 'er',
    's': 'es',
    't': 'tee ',
    'u': 'u',
    'v': 'fee ',
    'w': 'wee ',
    'x': 'eks',
    'y': 'yee ',
    'z': 'zet',
  };

  // Token utuh berupa 0–2 konsonan + "e": e, be, ce, nge, nye, ...
  static final RegExp _talingToken = RegExp(
    r'(?<![A-Za-z])([bcdfghjklmnpqrstvwxyz]{0,2})e(?![A-Za-z])',
    caseSensitive: false,
  );

  /// Nama huruf (mis. `B` -> `"bee "`).
  static String letter(String letter) {
    final key = letter.trim().toLowerCase();
    return letterNames[key] ?? key;
  }

  /// Normalisasi teks yang berisi huruf/suku kata lepas
  /// (`"Ba Bi Bu Be Bo"` -> `"ba bi bu bee  bo"`).
  /// Kata utuh seperti "kucing" atau "meja" tidak disentuh.
  static String syllables(String text) => text.toLowerCase().replaceAllMapped(_talingToken, (m) => '${m[1]}ee ');
}

/// Bunyi fonik Inggris (bukan nama huruf) untuk membantu blending.
abstract final class EnglishPhonetics {
  static const Map<String, String> letterSounds = {
    'a': 'aah',
    'b': 'buh',
    'c': 'kuh',
    'd': 'duh',
    'e': 'eh',
    'f': 'fff',
    'g': 'guh',
    'h': 'huh',
    'i': 'ih',
    'j': 'juh',
    'k': 'kuh',
    'l': 'lll',
    'm': 'mmm',
    'n': 'nnn',
    'o': 'ah',
    'p': 'puh',
    'q': 'kwuh',
    'r': 'rrr',
    's': 'sss',
    't': 'tuh',
    'u': 'uh',
    'v': 'vvv',
    'w': 'wuh',
    'x': 'ks',
    'y': 'yuh',
    'z': 'zzz',
  };

  static String sound(String letter) => letterSounds[letter.toLowerCase()] ?? letter;
}
