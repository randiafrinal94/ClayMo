import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../features/language/application/language_provider.dart';
import '../../features/language/domain/app_language.dart';
import 'phonetics.dart';
import 'phonics_clips.dart';

/// Kesiapan voice native Bahasa Indonesia di perangkat.
enum IndonesianVoiceStatus {
  /// Voice id-ID terpasang dan terkunci.
  ready,

  /// Engine tidak punya voice id-ID terpasang: orang tua perlu mengunduhnya.
  missing,

  /// Tidak bisa dipastikan (platform non-mobile / engine tidak menjawab).
  unknown,
}

/// Mesin suara hybrid bilingual. Bahasa diambil dari [languageProvider] saat
/// setiap ucapan, sehingga pergantian ID/EN langsung mengubah suara.
///
/// Huruf & suku kata Indonesia memakai klip rekaman ([PhonicsClips]) bila
/// tersedia; selebihnya TTS dengan teks yang dinormalisasi [IndonesianPhonetics].
class TtsService {
  TtsService({required this._currentLanguage, required this._clips});

  final AppLanguage Function() _currentLanguage;
  final PhonicsClips _clips;
  final FlutterTts _tts = FlutterTts();

  /// Google TTS jauh lebih presisi untuk fonem Indonesia dibanding engine pihak ketiga.
  static const _googleEngine = 'com.google.android.tts';

  // Rate flutter_tts (0..1). Indonesia 0.42: moderat agar suku kata jelas bagi
  // anak-anak. Pitch ID dijaga 1.0 (>1.05 membuat vokal cempreng).
  static const double _rateId = 0.42;
  static const double _rateEn = 0.47;
  static const double _slowDeltaEn = 0.08;
  static const double _pitchId = 1.0;
  static const double _pitchEn = 1.1; // intonasi lebih ceria
  static const _clipGap = Duration(milliseconds: 150);

  Future<void>? _initFuture;
  AppLanguage? _configuredLanguage;
  double? _configuredRate;

  /// Engine Android yang sedang aktif (null = bawaan sistem).
  String? _engine;
  Map<String, String>? _idVoice;
  IndonesianVoiceStatus _idStatus = IndonesianVoiceStatus.unknown;

  /// Naik setiap ucapan baru / [stop]; ucapan berurutan berhenti bila usang.
  int _generation = 0;

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
    await _lockIndonesianVoice();
  }

  // ---------------------------------------------------------------------------
  // Deteksi & penguncian voice Indonesia
  // ---------------------------------------------------------------------------

  /// Status voice Indonesia (untuk dialog panduan orang tua).
  Future<IndonesianVoiceStatus> indonesianVoiceStatus() async {
    await init();
    return _idStatus;
  }

  /// Cek ulang, mis. setelah orang tua kembali dari Pengaturan perangkat.
  Future<IndonesianVoiceStatus> recheckIndonesianVoice() async {
    await init();
    await _lockIndonesianVoice();
    _configuredLanguage = null;
    return _idStatus;
  }

  Future<void> _lockIndonesianVoice() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      _idStatus = IndonesianVoiceStatus.unknown;
      return;
    }
    try {
      _idVoice = Platform.isAndroid ? await _pickAndroidEngineForIndonesian() : await _bestVoice(AppLanguage.id);
      final available = _isTrue(await _tts.isLanguageAvailable(AppLanguage.id.ttsLocale));
      _idStatus = _idVoice != null && available ? IndonesianVoiceStatus.ready : IndonesianVoiceStatus.missing;
    } catch (e) {
      debugPrint('TtsService: deteksi voice Indonesia gagal: $e');
      _idStatus = IndonesianVoiceStatus.unknown;
    }
  }

  /// Android: pakai engine pertama yang punya voice id-ID terpasang,
  /// dengan Google TTS diutamakan, lalu engine bawaan, lalu sisanya.
  Future<Map<String, String>?> _pickAndroidEngineForIndonesian() async {
    final engines = [for (final e in (await _tts.getEngines as List?) ?? const []) '$e'];
    final defaultEngine = '${await _tts.getDefaultEngine ?? ''}';
    final order = <String>{
      if (engines.contains(_googleEngine)) _googleEngine,
      if (defaultEngine.isNotEmpty) defaultEngine,
      ...engines,
    };

    var current = _engine ?? defaultEngine;
    for (final engine in order) {
      if (engine != current) {
        await _tts.setEngine(engine);
        current = engine;
      }
      final voice = await _bestVoice(AppLanguage.id);
      if (voice != null) {
        _engine = engine;
        return voice;
      }
    }

    // Tidak ada voice Indonesia di engine mana pun: tetap pakai engine utama
    // agar bahasa lain (EN) tetap bersuara.
    final preferred = order.isEmpty ? current : order.first;
    if (preferred.isNotEmpty && preferred != current) await _tts.setEngine(preferred);
    _engine = preferred;
    return null;
  }

  /// Voice terpasang terbaik untuk locale bahasa, atau `null` bila tidak ada.
  Future<Map<String, String>?> _bestVoice(AppLanguage language) async {
    final voices = await _tts.getVoices;
    if (voices is! List) return null;
    final wanted = _normalizeLocale(language.ttsLocale);

    Map<String, String>? best;
    var bestScore = -1;
    for (final v in voices) {
      if (v is! Map) continue;
      if (_normalizeLocale('${v['locale']}') != wanted) continue;
      if ('${v['features']}'.toLowerCase().contains('notinstalled')) continue;
      final score = _voiceScore(v, language);
      if (score > bestScore) {
        bestScore = score;
        // Locale dikirim balik apa adanya: Android mencocokkan via toLanguageTag().
        best = {'name': '${v['name']}', 'locale': '${v['locale']}'};
      }
    }
    return best;
  }

  static String _normalizeLocale(String locale) => locale.toLowerCase().replaceAll('_', '-');

  static bool _isTrue(Object? v) => v == true || v == 1 || v == '1' || v == 'true';

  /// Voice lokal (offline) lebih stabil daripada yang butuh jaringan. Untuk
  /// Indonesia, voice asli (Google `id-id-x-*`, Apple Damayanti, neural) diutamakan.
  static int _voiceScore(Map<dynamic, dynamic> voice, AppLanguage language) {
    var score = '${voice['network_required']}' == '1' ? 0 : 1;
    if (language != AppLanguage.id) return score;
    final name = '${voice['name']}'.toLowerCase();
    if (name.contains('id-id-x')) score += 4;
    if (name.contains('indonesian') || name.contains('damayanti')) score += 3;
    if (name.contains('neural') || name.contains('enhanced') || name.contains('premium')) score += 2;
    return score;
  }

  /// Kunci bahasa + voice, lalu atur prosodi. Mengembalikan `false` bila
  /// voice Indonesia tidak terpasang (jangan dibacakan dengan aksen asing).
  Future<bool> _configure(AppLanguage language, {required bool slow}) async {
    final isId = language == AppLanguage.id;
    final rate = isId ? _rateId : (slow ? _rateEn - _slowDeltaEn : _rateEn);

    if (_configuredLanguage != language) {
      if (isId && _idStatus == IndonesianVoiceStatus.missing) return false;
      await _tts.setLanguage(language.ttsLocale);
      await _tts.setPitch(isId ? _pitchId : _pitchEn);
      final voice = isId ? _idVoice : await _bestVoice(language);
      if (voice != null) await _tts.setVoice(voice);
      _configuredLanguage = language;
      _configuredRate = null; // setLanguage/setVoice dapat mereset rate engine
    }
    if (_configuredRate != rate) {
      await _tts.setSpeechRate(rate);
      _configuredRate = rate;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Pemutaran
  // ---------------------------------------------------------------------------

  bool get _isId => _currentLanguage() == AppLanguage.id;

  bool _isCurrent(int gen) => gen == _generation;

  /// Jalankan satu ucapan baru: hentikan klip & TTS sebelumnya agar audio
  /// tidak bertumpuk. Error audio tidak pernah sampai ke UI.
  Future<void> _run(Future<void> Function(int gen) body) async {
    final gen = ++_generation;
    try {
      await init();
      await _clips.stop();
      await _tts.stop();
      await body(gen);
    } catch (e) {
      debugPrint('TtsService gagal: $e');
    }
  }

  Future<void> _say(int gen, String text, {bool slow = false, AppLanguage? language}) async {
    if (!_isCurrent(gen) || text.trim().isEmpty) return;
    final lang = language ?? _currentLanguage();
    if (!await _configure(lang, slow: slow)) {
      debugPrint('TtsService: voice ${lang.ttsLocale} belum terpasang di perangkat.');
      return;
    }
    if (_isCurrent(gen)) await _tts.speak(text);
  }

  Future<void> _playClip(int gen, String path) async {
    if (_isCurrent(gen)) await _clips.play(path);
  }

  Future<void> _speak(String text, {bool slow = false, AppLanguage? language}) =>
      _run((gen) => _say(gen, text, slow: slow, language: language));

  // ---------------------------------------------------------------------------
  // API publik
  // ---------------------------------------------------------------------------

  /// Satu kata utuh, mis. "kucing" / "ball". [slow] untuk tombol "dengarkan".
  Future<void> speakWord(String word, {bool slow = false}) => _speak(word.toLowerCase(), slow: slow);

  /// Kalimat UI terlokalisasi ("Hebat!", "Gambar apa ini?").
  Future<void> speakPhrase(String phrase, {AppLanguage? language}) => _speak(phrase, language: language);

  /// Nama satu huruf: klip rekaman bila ada, selain itu "bee," dsb.
  Future<void> speakLetter(String letter) => _run((gen) async {
    final clip = _isId ? await _clips.letter(letter) : null;
    if (clip != null) return _playClip(gen, clip);
    await _say(gen, _letterText(letter));
  });

  /// Huruf + contoh kata: "bee, bola" / "B. buh. B is for ball."
  Future<void> speakLetterIntro(String letter, String exampleWord) => _run((gen) async {
    final word = exampleWord.toLowerCase();
    if (!_isId) {
      final upper = letter.toUpperCase();
      return _say(gen, '$upper. ${EnglishPhonetics.sound(letter)}. $upper is for $word.', slow: true);
    }
    final clip = await _clips.letter(letter);
    if (clip == null) return _say(gen, '${_letterText(letter)} $word', slow: true);
    await _playClip(gen, clip);
    await _say(gen, word, slow: true);
  });

  /// Satu suku kata Indonesia: klip rekaman bila ada, selain itu "Be" -> "bee,".
  Future<void> speakSyllable(String syllable) => _run((gen) async {
    final clip = await _clips.syllable(syllable);
    if (clip != null) return _playClip(gen, clip);
    await _say(gen, IndonesianPhonetics.syllables(syllable), slow: true);
  });

  /// Deret suku kata: "Ba Bi Bu Be Bo". Klip dipakai hanya bila semuanya
  /// tersedia, agar satu deret tidak bercampur suara manusia & TTS.
  Future<void> speakSyllables(List<String> syllables) => _run((gen) async {
    final clips = await Future.wait(syllables.map(_clips.syllable));
    if (clips.isEmpty || clips.contains(null)) {
      return _say(gen, IndonesianPhonetics.syllables(syllables.join(' ')), slow: true);
    }
    for (final (i, clip) in clips.indexed) {
      if (i > 0) await Future<void>.delayed(_clipGap);
      if (!_isCurrent(gen)) return;
      await _playClip(gen, clip!);
    }
  });

  /// Blending fonik EN: "c... a... t... cat".
  Future<void> speakPhonicsWord(String word) {
    final sounds = word.toLowerCase().split('').map(EnglishPhonetics.sound).join('. ');
    return _speak('$sounds. ${word.toLowerCase()}', slow: true);
  }

  Future<void> stop() async {
    _generation++;
    try {
      await _clips.stop();
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stop();
    await _clips.dispose();
  }

  String _letterText(String letter) => switch (_currentLanguage()) {
    AppLanguage.id => IndonesianPhonetics.letter(letter),
    AppLanguage.en => letter.toUpperCase(),
  };
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService(currentLanguage: () => ref.read(languageProvider), clips: PhonicsClips());
  ref.onDispose(service.dispose);
  return service;
});
