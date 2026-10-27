import 'package:claymo/core/audio/phonetics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndonesianPhonetics', () {
    test('abjad A-Z dipetakan ke ejaan fonetik Indonesia dengan koma lembut', () {
      const expected = {
        'A': 'a,', 'B': 'bee,', 'C': 'cee,', 'D': 'dee,', 'E': 'ee,', 'F': 'ef,', 'G': 'gee,',
        'H': 'haa,', 'I': 'i,', 'J': 'jee,', 'K': 'kaa,', 'L': 'el,', 'M': 'em,', 'N': 'en,',
        'O': 'o,', 'P': 'pee,', 'Q': 'qii,', 'R': 'err,', 'S': 'es,', 'T': 'tee,', 'U': 'u,',
        'V': 'fee,', 'W': 'wee,', 'X': 'eks,', 'Y': 'yee,', 'Z': 'zet,',
      };
      expect(expected.length, 26);
      expected.forEach((letter, spelled) {
        expect(IndonesianPhonetics.letter(letter), spelled, reason: letter);
        expect(IndonesianPhonetics.letter(letter.toLowerCase()), spelled, reason: letter.toLowerCase());
      });
    });

    test('suku kata terbuka diberi koma lembut', () {
      for (final s in ['Ba', 'Ca', 'Da', 'Ga', 'Ha', 'Ku', 'Mo', 'Nya', 'Nga']) {
        expect(IndonesianPhonetics.syllables(s), '${s.toLowerCase()},', reason: s);
      }
    });

    test('suku kata berakhiran e digandakan menjadi e-taling', () {
      for (final c in 'bcdfghjklmnprstvwyz'.split('')) {
        expect(IndonesianPhonetics.syllables('${c.toUpperCase()}e'), '${c}ee,', reason: c);
      }
      expect(IndonesianPhonetics.syllables('Nye'), 'nyee,');
    });

    test('suku kata berakhiran i digandakan agar "Hi" bukan "Hai"', () {
      expect(IndonesianPhonetics.syllables('Hi'), 'hii,');
      expect(IndonesianPhonetics.syllables('Bi'), 'bii,');
      expect(IndonesianPhonetics.syllables('Ti'), 'tii,');
      expect(IndonesianPhonetics.syllables('Si'), 'sii,');
    });

    test('deret suku kata dan koma yang sudah ada tidak tergandakan', () {
      expect(IndonesianPhonetics.syllables('Ba Bi Bu Be Bo'), 'ba, bii, bu, bee, bo,');
      expect(IndonesianPhonetics.syllables('ba, bi,'), 'ba, bii,');
    });

    test('kata utuh tidak disentuh', () {
      expect(IndonesianPhonetics.syllables('meja'), 'meja');
      expect(IndonesianPhonetics.syllables('kucing'), 'kucing');
      expect(IndonesianPhonetics.syllables('apel'), 'apel');
      expect(IndonesianPhonetics.syllables('bibir'), 'bibir');
    });
  });
}
