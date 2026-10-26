import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../language/domain/app_language.dart';
import '../data/progress_repository.dart';
import '../domain/progress_state.dart';
import '../domain/sticker.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(appDatabaseProvider)),
);

/// Id profil anak yang aktif. Di-override di `main()`.
final activeUserIdProvider = Provider<int>(
  (ref) => throw UnimplementedError('activeUserIdProvider harus di-override di main()'),
);

/// Progres awal yang sudah dibaca dari SQLite sebelum `runApp`. Di-override di `main()`.
final initialProgressProvider = Provider<ProgressState>(
  (ref) => throw UnimplementedError('initialProgressProvider harus di-override di main()'),
);

/// Progres anak aktif. State diperbarui seketika (UI reaktif), lalu ditulis ke SQLite;
/// operasi sqflite berjalan berurutan sehingga urutan tulis terjaga.
class ProgressNotifier extends Notifier<ProgressState> {
  @override
  ProgressState build() => ref.read(initialProgressProvider);

  ProgressRepository get _repo => ref.read(progressRepositoryProvider);
  int get _userId => ref.read(activeUserIdProvider);

  void addStars([int amount = 1]) {
    state = state.copyWith(stars: state.stars + amount);
    _persist(_repo.addStars(_userId, amount));
    _unlockEarnedStickers();
  }

  void recordWordSpelled(AppLanguage language, String word) {
    final words = {...state.spelledIn(language), word};
    state = state.copyWith(spelledWords: {...state.spelledWords, language: words});
    _persist(_repo.recordWordSpelled(_userId, language, word));
  }

  void saveQuizResult({
    required AppLanguage language,
    required int score,
    required int total,
    required int starsEarned,
  }) {
    _persist(_repo.saveQuizResult(_userId, language: language, score: score, total: total, starsEarned: starsEarned));
  }

  void _unlockEarnedStickers() {
    final newlyUnlocked = [
      for (final s in StickerCatalog.all)
        if (s.requiredStars <= state.stars && !state.unlockedStickerIds.contains(s.id)) s.id,
    ];
    if (newlyUnlocked.isEmpty) return;
    state = state.copyWith(unlockedStickerIds: {...state.unlockedStickerIds, ...newlyUnlocked});
    _persist(_repo.unlockStickers(_userId, newlyUnlocked));
  }

  void _persist(Future<Object?> write) {
    unawaited(
      write.catchError((Object e, StackTrace st) {
        debugPrint('Gagal menyimpan progres: $e\n$st');
        return null;
      }),
    );
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressState>(ProgressNotifier.new);

/// Total bintang; hanya rebuild saat jumlahnya berubah.
final starsProvider = Provider<int>((ref) => ref.watch(progressProvider.select((s) => s.stars)));

final unlockedStickersProvider = Provider<List<Sticker>>((ref) {
  final unlocked = ref.watch(progressProvider.select((s) => s.unlockedStickerIds));
  return [
    for (final s in StickerCatalog.all)
      if (unlocked.contains(s.id)) s,
  ];
});

/// Jumlah kata yang sudah dieja pada bahasa tertentu.
final spelledCountProvider = Provider.family<int, AppLanguage>(
  (ref, language) => ref.watch(progressProvider.select((s) => s.spelledIn(language).length)),
);

final quizHistoryProvider = FutureProvider.autoDispose<List<QuizResult>>(
  (ref) => ref.watch(progressRepositoryProvider).quizHistory(ref.watch(activeUserIdProvider)),
);
