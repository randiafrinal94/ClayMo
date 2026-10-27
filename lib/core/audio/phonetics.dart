/// Normalisasi fonetik agar mesin TTS melafalkan huruf/suku kata dengan benar.
///
/// Bahasa Indonesia: huruf/suku kata berakhiran "e" (Be, De, Fe, Ce, ...)
/// dilafalkan e-taling (/e/) sesuai KBBI. Mesin TTS cenderung membacanya sebagai
/// pepet /ə/ atau menambahkan desah "h" di akhir, jadi vokalnya dipanjangkan
/// menjadi "ee" dan diberi spasi penutup: `Be` -> `"bee "`.
abstract final class IndonesianPhonetics {
  /// Nama huruf alfabet Indonesia (A–Z) dalam bentuk yang aman untuk TTS.
  ///
  /// Huruf tunggal tidak pernah dikirim mentah ("B", "H") karena TTS Android
  /// sering membacanya sebagai huruf/singkatan Inggris.
  static const Map<String, String> letterNames = {
    'a': 'a ',
    'b': 'bee ',
    'c': 'cee ',
    'd': 'dee ',
    'e': 'e ',
    'f': 'ef ',
    'g': 'gee ',
    'h': 'haa ',
    'i': 'i ',
    'j': 'jee ',
    'k': 'kaa ',
    'l': 'el ',
    'm': 'em ',
    'n': 'en ',
    'o': 'o ',
    'p': 'pee ',
    'q': 'qii ',
    'r': 'er ',
    's': 'es ',
    't': 'tee ',
    'u': 'u ',
    'v': 'vee ',
    'w': 'wee ',
    'x': 'eks ',
    'y': 'yee ',
    'z': 'zet ',
  };

  // Token utuh berupa 0–2 konsonan + "e": e, be, ce, nge, nye, ...
  static final RegExp _talingToken = RegExp(
    r'(?<![A-Za-z])([bcdfghjklmnpqrstvwxyz]{0,2})e(?![A-Za-z])',
    caseSensitive: false,
  );

  // Token utuh berupa 1–2 konsonan + "i": hi, bi, pi, ngi, nyi, ...
  // (vokal "i" lepas tidak disentuh; itu nama huruf, bukan suku kata.)
  static final RegExp _iToken = RegExp(r'(?<![A-Za-z])([bcdfghjklmnpqrstvwxyz]{1,2})i(?![A-Za-z])', caseSensitive: false);

  /// Nama huruf (mis. `B` -> `"bee "`).
  static String letter(String letter) {
    final key = letter.trim().toLowerCase();
    return letterNames[key] ?? key;
  }

  /// Normalisasi teks yang berisi huruf/suku kata lepas
  /// (`"Ba Bi Bu Be Bo"` -> `"ba bii  bu bee  bo"`).
  /// - "e" → "ee " agar terbaca e-taling tanpa desah "h".
  /// - "i" → "ii " agar "Hi" tidak terbaca sapaan Inggris "Hai".
  /// Kata utuh seperti "kucing" atau "meja" tidak disentuh.
  static String syllables(String text) => text
      .toLowerCase()
      .replaceAllMapped(_talingToken, (m) => '${m[1]}ee ')
      .replaceAllMapped(_iToken, (m) => '${m[1]}ii ');
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
