import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Sfx {
  pop('pop.wav'),
  tap('tap.wav'),
  place('place.wav'),
  success('success.wav'),
  star('star.wav'),
  welcome('welcome.wav'),
  wrong('wrong.wav');

  const Sfx(this.file);
  final String file;
}

/// Efek suara interaksi. Satu [AudioPlayer] per efek (mode low-latency),
/// dipicu tanpa `await` agar thread UI tidak pernah menunggu audio.
class SfxService {
  final Map<Sfx, AudioPlayer> _players = {};
  Future<void>? _loading;

  Future<void> preload() => _loading ??= _preload();

  Future<void> _preload() async {
    try {
      // Efek suara bercampur dengan TTS, tidak merebut audio focus.
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers, respectSilence: false).build(),
      );
      await AudioCache.instance.loadAll([for (final s in Sfx.values) 'sounds/${s.file}']);
      for (final s in Sfx.values) {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setVolume(0.8);
        _players[s] = player;
      }
    } catch (e) {
      debugPrint('SfxService.preload gagal: $e');
    }
  }

  /// Fire-and-forget: tidak pernah memblokir pemanggil.
  void play(Sfx sfx) {
    final player = _players[sfx];
    if (player == null) {
      unawaited(preload());
      return;
    }
    unawaited(
      player.play(AssetSource('sounds/${sfx.file}')).catchError((Object e) {
        debugPrint('SfxService.play($sfx) gagal: $e');
      }),
    );
  }

  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
    _players.clear();
  }
}

final sfxServiceProvider = Provider<SfxService>((ref) {
  final service = SfxService();
  ref.onDispose(service.dispose);
  return service;
});
