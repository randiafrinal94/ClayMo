import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/progress/domain/sticker.dart';

/// Di-override di `main()` dengan database yang sudah dibuka.
final appDatabaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('appDatabaseProvider harus di-override di main()'),
);

/// Pembuka database SQLite lokal (lihat `schema.md`).
abstract final class AppDatabase {
  static const fileName = 'claymo.db';
  static const version = 1;

  /// [path] default ke direktori database platform; gunakan [inMemoryDatabasePath] untuk tes.
  static Future<Database> open({String? path}) async {
    final dbPath = path ?? p.join(await getDatabasesPath(), fileName);
    return openDatabase(
      dbPath,
      version: version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await createSchema(db);
        await seedStickers(db);
      },
      // Katalog stiker bisa bertambah antar rilis aplikasi.
      onOpen: seedStickers,
    );
  }

  static Future<void> createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        avatar_id TEXT NOT NULL DEFAULT 'avatar_bear',
        total_stars INTEGER NOT NULL DEFAULT 0,
        preferred_language TEXT NOT NULL DEFAULT 'id' CHECK (preferred_language IN ('id', 'en')),
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // --- Tabel di bawah disimpulkan dari ringkasan relasi di schema.md ---

    await db.execute('''
      CREATE TABLE stickers (
        id TEXT PRIMARY KEY,
        emoji TEXT NOT NULL,
        name_id TEXT NOT NULL,
        name_en TEXT NOT NULL,
        required_stars INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE word_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        language TEXT NOT NULL CHECK (language IN ('id', 'en')),
        word TEXT NOT NULL,
        times_spelled INTEGER NOT NULL DEFAULT 1,
        first_spelled_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        last_spelled_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        UNIQUE (user_id, language, word)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_stickers (
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        sticker_id TEXT NOT NULL REFERENCES stickers(id) ON DELETE CASCADE,
        unlocked_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        PRIMARY KEY (user_id, sticker_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        language TEXT NOT NULL CHECK (language IN ('id', 'en')),
        score INTEGER NOT NULL,
        total INTEGER NOT NULL,
        stars_earned INTEGER NOT NULL,
        played_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      )
    ''');
    await db.execute('CREATE INDEX idx_quiz_history_user ON quiz_history (user_id, played_at DESC)');
  }

  static Future<void> seedStickers(Database db) async {
    final batch = db.batch();
    for (final s in StickerCatalog.all) {
      batch.insert('stickers', s.toRow(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
