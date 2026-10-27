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

  // Rate flutter_tts (0..1). Indonesia 0.42–0.46: moderat agar suku kata jelas
  // bagi anak-anak. Pitch ID dijaga 1.0 (>1.05 membuat vokal cempreng).
  static const double _rateId = 0.46;
  static const double _rateIdSlow = 0.42;
  static const double _rateEn = 0.47;
  static const double _slowDeltaEn = 0.08;
  static const double _pitchId = 1.0;
  static const double _pitchEn = 1.1; // intonasi lebih ceria

  Future<void>? _initFuture;
  AppLanguage? _configuredLanguage;
  double? _configuredRate;

  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    try {
      // speak() selesai saat suara selesai diputar (sinkronisasi state UI).
      await _tts.awaitSpeakCompletion(true);
      await _tts.awaitSynthCompletion(true);
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

  /// Kunci bahasa + voice native, lalu atur prosodi. Mengembalikan `false`
  /// bila engine tidak menyediakan bahasa tersebut.
  Future<bool> _configure(AppLanguage language, {required bool slow}) async {
    final isId = language == AppLanguage.id;
    final baseRate = isId ? _rateId : _rateEn;
    final rate = slow ? (isId ? _rateIdSlow : baseRate - _slowDeltaEn) : baseRate;

    if (_configuredLanguage != language) {
      await _tts.setLanguage(language.ttsLocale);
      await _tts.setPitch(isId ? _pitchId : _pitchEn);
      final voiceSet = await _selectVoice(language);
      // Indonesia wajib tersedia: tanpa itu engine jatuh ke aksen Inggris.
      final available = _isTrue(await _tts.isLanguageAvailable(language.ttsLocale));
      final ready = isId ? available : (available || voiceSet);
      // Bahasa yang belum siap dicek ulang di ucapan berikutnya (voice bisa
      // dipasang pengguna kapan saja).
      _configuredLanguage = ready ? language : null;
      _configuredRate = null; // setLanguage/setVoice dapat mereset rate engine
      if (!ready) return false;
    }
    if (_configuredRate != rate) {
      await _tts.setSpeechRate(rate);
      _configuredRate = rate;
    }
    return true;
  }

  static bool _isTrue(Object? v) => v == true || v == 1 || v == '1' || v == 'true';

  /// Pilih voice native terbaik untuk locale bahasa dan kunci via `setVoice`.
  /// Mengembalikan `true` bila ada voice bermatching locale yang berhasil di-set.
  Future<bool> _selectVoice(AppLanguage language) async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return false;
      final wanted = _normalizeLocale(language.ttsLocale);

      Map<String, String>? best;
      var bestScore = -1;
      for (final v in voices) {
        if (v is! Map) continue;
        if (_normalizeLocale('${v['locale']}') != wanted) continue;
        if ('${v['features']}'.toLowerCase().contains('notinstalled')) continue;
        final score = _voiceScore('${v['name']}', language);
        if (score > bestScore) {
          bestScore = score;
          best = {'name': '${v['name']}', 'locale': '${v['locale']}'};
        }
      }
      if (best == null) return false;
      await _tts.setVoice(best);
      return true;
    } catch (_) {
      // Tidak semua platform/engine mendukung daftar voice; setLanguage sudah cukup.
      return false;
    }
  }

  static String _normalizeLocale(String locale) => locale.toLowerCase().replaceAll('_', '-');

  /// Voice Indonesia asli (Google `id-id-x-*`, Apple Damayanti, varian neural)
  /// diutamakan; voice lokal (offline) lebih stabil daripada yang butuh jaringan.
  static int _voiceScore(String name, AppLanguage language) {
    if (language != AppLanguage.id) return 0;
    final n = name.toLowerCase();
    var score = 0;
    if (n.contains('id-id-x')) score += 4;
    if (n.contains('indonesian') || n.contains('damayanti')) score += 3;
    if (n.contains('neural') || n.contains('enhanced') || n.contains('premium')) score += 2;
    if (n.contains('local')) score += 1;
    if (n.contains('network')) score -= 1;
    return score;
  }

  Future<void> _speak(String text, {bool slow = false, AppLanguage? language}) async {
    if (text.trim().isEmpty) return;
    final lang = language ?? _currentLanguage();
    try {
      await init();
      // Hentikan ucapan sebelumnya agar buffer audio tidak bertabrakan.
      await _tts.stop();
      if (!await _configure(lang, slow: slow)) {
        debugPrint('TtsService: bahasa ${lang.ttsLocale} tidak tersedia di engine TTS.');
        return;
      }
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
