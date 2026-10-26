import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/sfx_service.dart';
import '../../../core/audio/tts_service.dart';
import '../../../data/word_bank.dart';
import '../../language/application/language_provider.dart';
import '../../progress/application/progress_provider.dart';

class SpellTile {
  const SpellTile(this.id, this.letter, {this.placed = false});

  final int id;
  final String letter;
  final bool placed;

  SpellTile asPlaced() => SpellTile(id, letter, placed: true);
}

class SpellingState {
  const SpellingState({
    required this.deck,
    required this.index,
    required this.slots,
    required this.tiles,
    this.wrongTileId,
    this.wrongTick = 0,
  });

  final List<WordItem> deck;
  final int index;

  /// Huruf yang sudah masuk, sejajar dengan `current.letters` (null = kosong).
  final List<String?> slots;
  final List<SpellTile> tiles;

  /// Tile yang terakhir salah ditekan + penghitung untuk memicu animasi goyang.
  final int? wrongTileId;
  final int wrongTick;

  WordItem get current => deck[index];
  bool get completed => slots.every((s) => s != null);

  SpellingState copyWith({
    int? index,
    List<String?>? slots,
    List<SpellTile>? tiles,
    int? wrongTileId,
    int? wrongTick,
  }) => SpellingState(
    deck: deck,
    index: index ?? this.index,
    slots: slots ?? this.slots,
    tiles: tiles ?? this.tiles,
    wrongTileId: wrongTileId ?? this.wrongTileId,
    wrongTick: wrongTick ?? this.wrongTick,
  );
}

class SpellingController extends Notifier<SpellingState> {
  static const _distractorCount = 2;
  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  final Random _random = Random();

  /// Dibangun ulang otomatis saat bahasa berganti => daftar kata ikut berganti.
  @override
  SpellingState build() {
    final language = ref.watch(languageProvider);
    final deck = [...WordBank.words(language)]..shuffle(_random);
    return _startWord(deck, 0);
  }

  SpellingState _startWord(List<WordItem> deck, int index) {
    final letters = deck[index].letters;

    final spare = _alphabet.split('').where((c) => !letters.contains(c)).toList()..shuffle(_random);
    final pool = [...letters, ...spare.take(_distractorCount)]..shuffle(_random);

    return SpellingState(
      deck: deck,
      index: index,
      slots: List<String?>.filled(letters.length, null),
      tiles: [for (var i = 0; i < pool.length; i++) SpellTile(i, pool[i])],
    );
  }

  /// Ketuk kepingan huruf: masuk ke slot kosong terdepan yang sesuai,
  /// atau bergoyang jika huruf itu bukan bagian dari kata.
  void tapTile(int tileId) {
    final s = state;
    if (s.completed) return;
    final tile = s.tiles.firstWhere((t) => t.id == tileId);
    if (tile.placed) return;

    final letters = s.current.letters;
    final slotIndex = [
      for (var i = 0; i < letters.length; i++)
        if (s.slots[i] == null && letters[i] == tile.letter) i,
    ].firstOrNull;

    final sfx = ref.read(sfxServiceProvider);
    final tts = ref.read(ttsServiceProvider);

    if (slotIndex == null) {
      sfx.play(Sfx.wrong);
      state = s.copyWith(wrongTileId: tileId, wrongTick: s.wrongTick + 1);
      return;
    }

    final slots = [...s.slots]..[slotIndex] = tile.letter;
    final tiles = [for (final t in s.tiles) t.id == tileId ? t.asPlaced() : t];
    state = s.copyWith(slots: slots, tiles: tiles);

    if (state.completed) {
      sfx.play(Sfx.success);
      ref.read(progressProvider.notifier)
        ..recordWordSpelled(ref.read(languageProvider), s.current.word)
        ..addStars();
      tts.speakWord(s.current.word, slow: true);
    } else {
      sfx.play(Sfx.place);
      tts.speakLetter(tile.letter);
    }
  }

  void next() {
    final s = state;
    final nextIndex = s.index + 1;
    if (nextIndex >= s.deck.length) {
      final deck = [...s.deck]..shuffle(_random);
      state = _startWord(deck, 0);
    } else {
      state = _startWord(s.deck, nextIndex);
    }
  }

  /// Ucapkan kata dengan kecepatan normal (tombol "Dengar").
  void listen() => ref.read(ttsServiceProvider).speakWord(state.current.word);

  /// Ucapkan kata perlahan (tombol "Pelan").
  void listenSlow() => ref.read(ttsServiceProvider).speakWord(state.current.word, slow: true);
}

final spellingProvider = NotifierProvider.autoDispose<SpellingController, SpellingState>(SpellingController.new);
