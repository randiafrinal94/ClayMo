import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/database_factory.dart';
import 'core/storage/preferences.dart';
import 'features/progress/application/progress_provider.dart';
import 'features/progress/data/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  final prefs = await SharedPreferences.getInstance();
  initDatabaseFactory();
  final db = await AppDatabase.open();

  // Bintang versi lama disimpan di SharedPreferences; pindahkan sekali ke SQLite.
  const legacyStarsKey = 'stars';
  final repository = ProgressRepository(db);
  final userId = await repository.ensureDefaultUser(legacyStars: prefs.getInt(legacyStarsKey) ?? 0);
  await prefs.remove(legacyStarsKey);
  final progress = await repository.load(userId);

  runApp(
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
