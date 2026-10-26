import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../features/language/application/language_provider.dart';
import '../../features/language/domain/app_language.dart';
import 'phonetics.dart';

/// Text-to-Speech bilingual. Bahasa diambil dari [languageProvider] saat
/// setiap ucapan, sehingga pergantian ID/EN langsung mengubah suara.
class TtsService {
  TtsService({required this._currentLanguage});

  final AppLanguage Function() _currentLanguage;
  final FlutterTts _tts = FlutterTts();

  // Rate flutter_tts (0..1). Indonesia 0.45–0.48 agar jelas didengar anak-anak.
  static const double _rateId = 0.46;
  static const double _rateEn = 0.47;
  static const double _slowDelta = 0.08;
  static const double _pitchId = 1.0;
  static const double _pitchEn = 1.1; // intonasi lebih ceria

  Future<void>? _initFuture;
  AppLanguage? _configuredLanguage;
  double? _configuredRate;

  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    try {
      await _tts.awaitSpeakCompletion(false);
      if (!kIsWeb && Platform.isIOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ], IosTextToSpeechAudioMode.defaultMode);
      }
      await _tts.setVolume(1.0);
    } catch (e) {
      debugPrint('TtsService.init gagal: $e');
    }
  }

  Future<void> _configure(AppLanguage language, {required bool slow}) async {
    final baseRate = language == AppLanguage.id ? _rateId : _rateEn;
    final rate = slow ? baseRate - _slowDelta : baseRate;

    if (_configuredLanguage != language) {
      await _tts.setLanguage(language.ttsLocale);
      await _tts.setPitch(language == AppLanguage.id ? _pitchId : _pitchEn);
      await _selectVoice(language);
      _configuredLanguage = language;
    }
    if (_configuredRate != rate) {
      await _tts.setSpeechRate(rate);
      _configuredRate = rate;
    }
  }

  /// Pilih voice native yang cocok dengan locale (jika engine menyediakan).
  Future<void> _selectVoice(AppLanguage language) async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;
      final wanted = language.ttsLocale.toLowerCase();
      for (final v in voices) {
        if (v is! Map) continue;
        final locale = '${v['locale']}'.toLowerCase().replaceAll('_', '-');
        final features = '${v['features']}'.toLowerCase();
        if (locale == wanted && !features.contains('notinstalled')) {
          await _tts.setVoice({'name': '${v['name']}', 'locale': '${v['locale']}'});
          return;
        }
      }
    } catch (_) {
      // Tidak semua platform/engine mendukung daftar voice; setLanguage sudah cukup.
    }
  }

  Future<void> _speak(String text, {bool slow = false, AppLanguage? language}) async {
    if (text.trim().isEmpty) return;
    final lang = language ?? _currentLanguage();
    try {
      await init();
      await _tts.stop();
      await _configure(lang, slow: slow);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TtsService.speak gagal: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // API publik
  // ---------------------------------------------------------------------------

  /// Satu kata utuh, mis. "kucing" / "ball". [slow] untuk tombol "dengarkan".
  Future<void> speakWord(String word, {bool slow = false}) => _speak(word.toLowerCase(), slow: slow);

  /// Kalimat UI terlokalisasi ("Hebat!", "Gambar apa ini?").
  Future<void> speakPhrase(String phrase, {AppLanguage? language}) => _speak(phrase, language: language);

  /// Nama satu huruf.
  Future<void> speakLetter(String letter) => _speak(_letterText(letter));

  /// Huruf + contoh kata: "bee , bola" / "B. buh. B is for ball."
  Future<void> speakLetterIntro(String letter, String exampleWord) {
    final word = exampleWord.toLowerCase();
    return switch (_currentLanguage()) {
      AppLanguage.id => _speak('${_letterText(letter)}, $word', slow: true),
      AppLanguage.en => _speak(
        '${letter.toUpperCase()}. ${EnglishPhonetics.sound(letter)}. '
        '${letter.toUpperCase()} is for $word.',
        slow: true,
      ),
    };
  }

  /// Satu suku kata Indonesia, mis. "Be" -> "bee ".
  Future<void> speakSyllable(String syllable) => _speak(IndonesianPhonetics.syllables(syllable), slow: true);

  /// Deret suku kata: "Ba Bi Bu Be Bo".
  Future<void> speakSyllables(List<String> syllables) =>
      _speak(syllables.map(IndonesianPhonetics.syllables).join(', '), slow: true);

  /// Blending fonik EN: "c... a... t... cat".
  Future<void> speakPhonicsWord(String word) {
    final sounds = word.toLowerCase().split('').map(EnglishPhonetics.sound).join('. ');
    return _speak('$sounds. ${word.toLowerCase()}', slow: true);
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> dispose() => stop();

  String _letterText(String letter) => switch (_currentLanguage()) {
    AppLanguage.id => IndonesianPhonetics.letter(letter),
    AppLanguage.en => letter.toUpperCase(),
  };
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService(currentLanguage: () => ref.read(languageProvider));
  ref.onDispose(service.dispose);
  return service;
});
