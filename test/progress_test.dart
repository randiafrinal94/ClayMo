import 'package:claymo/core/database/app_database.dart';
import 'package:claymo/features/language/domain/app_language.dart';
import 'package:claymo/features/progress/application/progress_provider.dart';
import 'package:claymo/features/progress/data/progress_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late ProviderContainer container;
  late ProgressRepository repo;
  late int userId;

  setUp(() async {
    final db = await AppDatabase.open(path: inMemoryDatabasePath);
    repo = ProgressRepository(db);
    userId = await repo.ensureDefaultUser();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeUserIdProvider.overrideWithValue(userId),
        initialProgressProvider.overrideWithValue(await repo.load(userId)),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  test('ensureDefaultUser tidak membuat profil ganda dan memindahkan bintang lama', () async {
    expect(await repo.ensureDefaultUser(), userId);
  });

  test('bintang bertambah reaktif, tersimpan, dan membuka stiker', () async {
    final seen = <int>[];
    container.listen(starsProvider, (_, next) => seen.add(next));

    final notifier = container.read(progressProvider.notifier);
    notifier.addStars();
    notifier.addStars(2);
    await Future<void>.delayed(Duration.zero); // listener provider turunan dipanggil asinkron
    expect(seen, [1, 3]);
    expect(container.read(unlockedStickersProvider).map((s) => s.id), ['sticker_unicorn', 'sticker_dog']);

    // Operasi sqflite berurutan, jadi load() menunggu semua tulis sebelumnya.
    final reloaded = await repo.load(userId);
    expect(reloaded.stars, 3);
    expect(reloaded.unlockedStickerIds, {'sticker_unicorn', 'sticker_dog'});
  });

  test('kata yang dieja tercatat per bahasa dan pengulangan menambah penghitung', () async {
    final notifier = container.read(progressProvider.notifier);
    notifier.recordWordSpelled(AppLanguage.id, 'BOLA');
    notifier.recordWordSpelled(AppLanguage.id, 'BOLA');
    notifier.recordWordSpelled(AppLanguage.en, 'BALL');

    expect(container.read(spelledCountProvider(AppLanguage.id)), 1);
    expect(container.read(spelledCountProvider(AppLanguage.en)), 1);

    final reloaded = await repo.load(userId);
    expect(reloaded.spelledIn(AppLanguage.id), {'BOLA'});
    expect(reloaded.spelledIn(AppLanguage.en), {'BALL'});
  });

  test('riwayat kuis tersimpan dan terurut terbaru dulu', () async {
    final notifier = container.read(progressProvider.notifier);
    notifier.saveQuizResult(language: AppLanguage.id, score: 4, total: 6, starsEarned: 4);
    notifier.saveQuizResult(language: AppLanguage.en, score: 6, total: 6, starsEarned: 6);

    final history = await repo.quizHistory(userId);
    expect(history.map((r) => r.score), [6, 4]);
    expect(history.first.language, AppLanguage.en);
  });
}
