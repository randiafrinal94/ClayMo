import 'package:claymo/core/audio/phonetics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndonesianPhonetics', () {
    test('huruf berakhiran E dipetakan ke e-taling', () {
      expect(IndonesianPhonetics.letter('B'), 'bee ');
      expect(IndonesianPhonetics.letter('d'), 'dee ');
      expect(IndonesianPhonetics.letter('C'), 'cee ');
      expect(IndonesianPhonetics.letter('V'), 'fee ');
      expect(IndonesianPhonetics.letter('K'), 'ka');
    });

    test('suku kata berakhiran e dinormalisasi', () {
      expect(IndonesianPhonetics.syllables('Be'), 'bee ');
      expect(IndonesianPhonetics.syllables('Fe'), 'fee ');
      expect(IndonesianPhonetics.syllables('Nye'), 'nyee ');
      expect(IndonesianPhonetics.syllables('Ba Bi Bu Be Bo'), 'ba bi bu bee  bo');
    });

    test('kata utuh tidak disentuh', () {
      expect(IndonesianPhonetics.syllables('meja'), 'meja');
      expect(IndonesianPhonetics.syllables('kucing'), 'kucing');
      expect(IndonesianPhonetics.syllables('apel'), 'apel');
    });
  });
}
