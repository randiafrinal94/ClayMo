import 'package:sqflite/sqflite.dart';

import '../../language/domain/app_language.dart';
import '../domain/progress_state.dart';

/// Akses SQLite untuk progres belajar satu anak (`userId`).
class ProgressRepository {
  const ProgressRepository(this._db);

  final Database _db;

  static int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// Mengembalikan id profil pertama; membuatnya bila belum ada.
  /// [legacyStars] memindahkan bintang lama dari SharedPreferences ke profil baru.
  Future<int> ensureDefaultUser({String name = 'Claymo', int legacyStars = 0}) async {
    final rows = await _db.query('users', columns: ['id'], orderBy: 'id', limit: 1);
    if (rows.isNotEmpty) return rows.first['id']! as int;
    return _db.insert('users', {'name': name, 'total_stars': legacyStars});
  }

  Future<ProgressState> load(int userId) async {
    final user = await _db.query('users', columns: ['total_stars'], where: 'id = ?', whereArgs: [userId]);
    final words = await _db.query(
      'word_progress',
      columns: ['language', 'word'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final stickers = await _db.query(
      'user_stickers',
      columns: ['sticker_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final spelled = <AppLanguage, Set<String>>{};
    for (final row in words) {
      spelled.putIfAbsent(AppLanguage.fromCode(row['language']! as String), () => {}).add(row['word']! as String);
    }

    return ProgressState(
      stars: user.isEmpty ? 0 : user.first['total_stars']! as int,
      spelledWords: spelled,
      unlockedStickerIds: {for (final r in stickers) r['sticker_id']! as String},
    );
  }

  Future<void> addStars(int userId, int amount) =>
      _db.rawUpdate('UPDATE users SET total_stars = total_stars + ? WHERE id = ?', [amount, userId]);

  /// Mencatat kata yang berhasil dieja; mengulang kata yang sama menambah `times_spelled`.
  Future<void> recordWordSpelled(int userId, AppLanguage language, String word) => _db.rawInsert(
    '''
        INSERT INTO word_progress (user_id, language, word, first_spelled_at, last_spelled_at)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT (user_id, language, word) DO UPDATE SET
          times_spelled = times_spelled + 1,
          last_spelled_at = excluded.last_spelled_at
        ''',
    [userId, language.code, word, _now(), _now()],
  );

  Future<void> unlockStickers(int userId, Iterable<String> stickerIds) async {
    final batch = _db.batch();
    for (final id in stickerIds) {
      batch.insert('user_stickers', {
        'user_id': userId,
        'sticker_id': id,
        'unlocked_at': _now(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  /// Riwayat sesi kuis. Bintangnya sendiri sudah ditambahkan per jawaban lewat [addStars].
  Future<void> saveQuizResult(
    int userId, {
    required AppLanguage language,
    required int score,
    required int total,
    required int starsEarned,
  }) => _db.insert('quiz_history', {
    'user_id': userId,
    'language': language.code,
    'score': score,
    'total': total,
    'stars_earned': starsEarned,
    'played_at': _now(),
  });

  Future<List<QuizResult>> quizHistory(int userId, {int limit = 20}) async {
    final rows = await _db.query(
      'quiz_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'played_at DESC, id DESC',
      limit: limit,
    );
    return [
      for (final r in rows)
        QuizResult(
          language: AppLanguage.fromCode(r['language']! as String),
          score: r['score']! as int,
          total: r['total']! as int,
          starsEarned: r['stars_earned']! as int,
          playedAt: DateTime.fromMillisecondsSinceEpoch((r['played_at']! as int) * 1000),
        ),
    ];
  }
}
