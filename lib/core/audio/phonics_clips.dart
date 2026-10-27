import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Klip suara manusia (pre-recorded) untuk huruf & suku kata Bahasa Indonesia.
///
/// Struktur aset (nama file huruf kecil):
/// - `assets/audio/phonics/letters/b.mp3`
/// - `assets/audio/phonics/syllables/ba.mp3`
///
/// Klip yang ada selalu diutamakan daripada TTS karena akurasinya terjamin;
/// yang belum ada otomatis jatuh ke TTS dengan kamus fonetik.
class PhonicsClips {
  static const _root = 'assets/audio/phonics';
  static const _extensions = ['mp3', 'm4a', 'wav'];

  Future<Set<String>>? _assets;
  AudioPlayer? _player;
  Completer<void>? _playing;

  /// Path aset klip huruf, atau `null` bila belum direkam.
  Future<String?> letter(String letter) => _find('letters', letter);

  /// Path aset klip suku kata, atau `null` bila belum direkam.
  Future<String?> syllable(String syllable) => _find('syllables', syllable);

  Future<String?> _find(String folder, String name) async {
    final key = name.trim().toLowerCase();
    if (key.isEmpty) return null;
    final assets = await (_assets ??= _loadAssets());
    for (final ext in _extensions) {
      final path = '$_root/$folder/$key.$ext';
      if (assets.contains(path)) return path;
    }
    return null;
  }

  Future<Set<String>> _loadAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest.listAssets().where((a) => a.startsWith('$_root/')).toSet();
    } catch (e) {
      debugPrint('PhonicsClips: manifest aset gagal dimuat: $e');
      return const {};
    }
  }

  /// Putar klip sampai selesai (atau sampai dihentikan [stop]).
  Future<void> play(String assetPath) async {
    await stop();
    final player = _player ??= AudioPlayer();
    final done = _playing = Completer<void>();
    final sub = player.onPlayerComplete.listen((_) {
      if (!done.isCompleted) done.complete();
    });
    try {
      // AudioCache sudah berawalan "assets/".
      await player.play(AssetSource(assetPath.substring('assets/'.length)));
      await done.future;
    } finally {
      await sub.cancel();
    }
  }

  Future<void> stop() async {
    final playing = _playing;
    _playing = null;
    if (playing != null && !playing.isCompleted) playing.complete();
    try {
      await _player?.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stop();
    await _player?.dispose();
    _player = null;
  }
}
