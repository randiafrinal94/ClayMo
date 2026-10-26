import 'package:flutter/widgets.dart' show Size;
import 'package:claymo/app.dart';
import 'package:claymo/core/database/app_database.dart';
import 'package:claymo/core/storage/preferences.dart';
import 'package:claymo/features/album/presentation/album_screen.dart';
import 'package:claymo/features/home/presentation/home_screen.dart';
import 'package:claymo/features/phonics/presentation/phonics_screen.dart';
import 'package:claymo/features/quiz/presentation/quiz_screen.dart';
import 'package:claymo/features/progress/application/progress_provider.dart';
import 'package:claymo/features/progress/data/progress_repository.dart';
import 'package:claymo/features/spelling/application/spelling_controller.dart';
import 'package:claymo/features/spelling/presentation/spelling_screen.dart';
import 'package:claymo/features/splash/presentation/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> _settle(WidgetTester tester) async {
  // Logo beranimasi berulang, jadi pumpAndSettle tidak akan selesai.
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 600));
  }
}

/// Ukuran ponsel umum; permukaan tes bawaan (800x600) memicu bingkai ponsel layar lebar.
Future<void> _pumpApp(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  // I/O database asli tidak bisa jalan di zona palsu testWidgets.
  final (db, userId, progress) = (await tester.runAsync(() async {
    final db = await AppDatabase.open(path: inMemoryDatabasePath);
    final repo = ProgressRepository(db);
    final userId = await repo.ensureDefaultUser();
    return (db, userId, await repo.load(userId));
  }))!;
  addTearDown(() => tester.runAsync(db.close));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        activeUserIdProvider.overrideWithValue(userId),
        initialProgressProvider.overrideWithValue(progress),
      ],
      child: const ClaymoApp(),
    ),
  );
}

Future<void> _pumpAppToHome(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  await _pumpApp(tester, size: size);
  await tester.pump(splashDuration);
  await tester.pump(const Duration(milliseconds: 700)); // transisi ke beranda
  await _settle(tester);
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('splash tampil dulu, lalu pindah mulus ke beranda setelah 3 detik', (tester) async {
    await _pumpApp(tester);

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    await tester.pump(splashDuration - const Duration(milliseconds: 100));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));
    await _settle(tester);

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('beranda tampil dalam Bahasa Indonesia lalu berganti ke English seketika', (tester) async {
    await _pumpAppToHome(tester);

    expect(find.text('Mengeja'), findsOneWidget);
    expect(find.text('Tebak Gambar'), findsOneWidget);

    await tester.tap(find.text('🇺🇸 EN'));
    await _settle(tester);

    expect(find.text('Spelling'), findsOneWidget);
    expect(find.text('Picture Quiz'), findsOneWidget);
    expect(find.text('Mengeja'), findsNothing);
  });

  testWidgets('mode mengeja: menyusun kata dengan benar memberi bintang', (tester) async {
    await _pumpAppToHome(tester);

    await tester.tap(find.text('Mengeja'));
    await _settle(tester);

    expect(find.byType(SpellingScreen), findsOneWidget);
    expect(find.text('Kata 1 dari 16'), findsOneWidget);

    final container = ProviderScope.containerOf(tester.element(find.byType(SpellingScreen)));
    final letters = container.read(spellingProvider).current.letters;

    // Huruf salah (bukan bagian kata) tidak mengisi slot.
    final wrong = container.read(spellingProvider).tiles.firstWhere((t) => !letters.contains(t.letter));
    await tester.tap(find.text(wrong.letter).last);
    await tester.pump(const Duration(milliseconds: 100));
    expect(container.read(spellingProvider).slots.whereType<String>(), isEmpty);

    for (final letter in letters) {
      await tester.tap(find.text(letter).last);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _settle(tester);
    // Tulis bintang ke SQLite berjalan di zona asli; beri waktu selesai agar timer lock-nya hilang.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));

    // Bintang pertama membuka stiker pertama: tunggu toast "Stiker baru!" tampil lalu hilang.
    await tester.pump(const Duration(seconds: 4));

    expect(container.read(spellingProvider).completed, isTrue);
    expect(find.text('Hebat!'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // bintang di StarsChip
  });

  testWidgets('navigasi bawah membuka kelima tab tanpa overflow di layar sempit', (tester) async {
    await _pumpAppToHome(tester, size: const Size(360, 640));

    final tabs = <String, Type>{
      'Eja': SpellingScreen,
      'Huruf': PhonicsScreen,
      'Tebak': QuizScreen,
      'Album': AlbumScreen,
      'Beranda': HomeScreen,
    };
    for (final MapEntry(key: label, value: screen) in tabs.entries) {
      await tester.tap(find.text(label).last);
      await _settle(tester);
      expect(find.byType(screen), findsOneWidget, reason: 'tab $label');
    }
  });

  testWidgets('layar lebar tampil dalam bingkai ponsel tanpa error', (tester) async {
    await _pumpAppToHome(tester, size: const Size(1200, 900));

    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.tap(find.text('Album').last);
    await _settle(tester);
    expect(find.byType(AlbumScreen), findsOneWidget);
  });
}
