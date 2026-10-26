import '../../language/domain/app_language.dart';

/// Snapshot progres anak aktif yang disimpan di memori agar UI bisa sinkron.
class ProgressState {
  const ProgressState({this.stars = 0, this.spelledWords = const {}, this.unlockedStickerIds = const {}});

  final int stars;

  /// Kata yang sudah berhasil dieja, per bahasa.
  final Map<AppLanguage, Set<String>> spelledWords;
  final Set<String> unlockedStickerIds;

  Set<String> spelledIn(AppLanguage language) => spelledWords[language] ?? const {};

  ProgressState copyWith({int? stars, Map<AppLanguage, Set<String>>? spelledWords, Set<String>? unlockedStickerIds}) =>
      ProgressState(
        stars: stars ?? this.stars,
        spelledWords: spelledWords ?? this.spelledWords,
        unlockedStickerIds: unlockedStickerIds ?? this.unlockedStickerIds,
      );
}

/// Satu baris riwayat kuis.
class QuizResult {
  const QuizResult({
    required this.language,
    required this.score,
    required this.total,
    required this.starsEarned,
    required this.playedAt,
  });

  final AppLanguage language;
  final int score;
  final int total;
  final int starsEarned;
  final DateTime playedAt;
}
