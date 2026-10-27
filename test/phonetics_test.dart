import 'package:claymo/core/audio/phonetics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndonesianPhonetics', () {
    test('abjad A-Z dipetakan ke ejaan fonetik Indonesia', () {
      const expected = {
        'A': 'a ', 'B': 'bee ', 'C': 'cee ', 'D': 'dee ', 'E': 'e ', 'F': 'ef ', 'G': 'gee ',
        'H': 'haa ', 'I': 'i ', 'J': 'jee ', 'K': 'kaa ', 'L': 'el ', 'M': 'em ', 'N': 'en ',
        'O': 'o ', 'P': 'pee ', 'Q': 'qii ', 'R': 'er ', 'S': 'es ', 'T': 'tee ', 'U': 'u ',
        'V': 'vee ', 'W': 'wee ', 'X': 'eks ', 'Y': 'yee ', 'Z': 'zet ',
      };
      expect(expected.length, 26);
      expected.forEach((letter, spelled) {
        expect(IndonesianPhonetics.letter(letter), spelled, reason: letter);
        expect(IndonesianPhonetics.letter(letter.toLowerCase()), spelled, reason: letter.toLowerCase());
      });
    });

    test('suku kata berakhiran e dinormalisasi', () {
      for (final c in 'bcdfghjklmnprstvwyz'.split('')) {
        expect(IndonesianPhonetics.syllables('${c.toUpperCase()}e'), '${c}ee ', reason: c);
      }
      expect(IndonesianPhonetics.syllables('Nye'), 'nyee ');
    });

    test('suku kata berakhiran i digandakan agar "Hi" bukan "Hai"', () {
      expect(IndonesianPhonetics.syllables('Hi'), 'hii ');
      expect(IndonesianPhonetics.syllables('Bi'), 'bii ');
      expect(IndonesianPhonetics.syllables('Pi'), 'pii ');
      expect(IndonesianPhonetics.syllables('Ba Bi Bu Be Bo'), 'ba bii  bu bee  bo');
    });

    test('kata utuh dan vokal lepas tidak disentuh', () {
      expect(IndonesianPhonetics.syllables('meja'), 'meja');
      expect(IndonesianPhonetics.syllables('kucing'), 'kucing');
      expect(IndonesianPhonetics.syllables('apel'), 'apel');
      expect(IndonesianPhonetics.syllables('bibir'), 'bibir');
      expect(IndonesianPhonetics.syllables('i'), 'i');
    });
  });
}
