/// Normalisasi fonetik agar mesin TTS melafalkan huruf/suku kata dengan benar.
///
/// Mesin TTS cenderung membaca huruf/suku kata pendek dengan model fonetik
/// Inggris ("I" -> "ai", "G" -> "ji"), memotong suku kata terbuka dengan
/// letupan/desah "h", dan menukar e-pepet /ə/ dengan e-taling /e/. Karena itu:
/// - huruf tunggal tidak pernah dikirim mentah, melainkan ejaan Indonesianya;
/// - setiap suku kata diberi koma lembut (`ba,`) agar intonasi turun datar
///   dan vokal "mendarat" tanpa hentian glotal;
/// - vokal "e" digandakan (`bee,`) agar terbaca e-taling seperti pada "sate";
/// - vokal "i" setelah konsonan digandakan (`hii,`) agar "Hi" bukan "Hai".
abstract final class IndonesianPhonetics {
  /// Nama huruf alfabet Indonesia (A–Z) dalam bentuk yang aman untuk TTS.
  static const Map<String, String> letterNames = {
    'a': 'a,',
    'b': 'bee,',
    'c': 'cee,',
    'd': 'dee,',
    'e': 'ee,',
    'f': 'ef,',
    'g': 'gee,',
    'h': 'haa,',
    'i': 'i,',
    'j': 'jee,',
    'k': 'kaa,',
    'l': 'el,',
    'm': 'em,',
    'n': 'en,',
    'o': 'o,',
    'p': 'pee,',
    'q': 'qii,',
    'r': 'err,',
    's': 'es,',
    't': 'tee,',
    'u': 'u,',
    'v': 'fee,',
    'w': 'wee,',
    'x': 'eks,',
    'y': 'yee,',
    'z': 'zet,',
  };

  // Token suku kata terbuka utuh: 0–2 konsonan + 1 vokal (a, ba, nga, nye, ...),
  // termasuk koma yang mungkin sudah ada agar tidak tergandakan.
  static final RegExp _openSyllable = RegExp(
    r'(?<![A-Za-z])([bcdfghjklmnpqrstvwxyz]{0,2})([aiueo]),?(?![A-Za-z])',
    caseSensitive: false,
  );

  /// Nama huruf (mis. `B` -> `"bee,"`).
  static String letter(String letter) {
    final key = letter.trim().toLowerCase();
    return letterNames[key] ?? key;
  }

  /// Normalisasi teks yang berisi huruf/suku kata lepas
  /// (`"Ba Bi Bu Be Bo"` -> `"ba, bii, bu, bee, bo,"`).
  /// Kata utuh seperti "kucing" atau "meja" tidak disentuh.
  static String syllables(String text) => text.toLowerCase().replaceAllMapped(_openSyllable, (m) {
    final consonants = m[1]!;
    final vowel = switch (m[2]!) {
      'e' => 'ee',
      'i' when consonants.isNotEmpty => 'ii',
      final v => v,
    };
    return '$consonants$vowel,';
  });
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
