import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/sfx_service.dart';
import '../../../core/audio/tts_service.dart';
import '../../../data/word_bank.dart';
import '../../language/application/language_provider.dart';
import '../../progress/application/progress_provider.dart';

class QuizQuestion {
  const QuizQuestion({required this.answer, required this.options});

  final WordItem answer;
  final List<WordItem> options;
}

class QuizState {
  const QuizState({
    required this.questions,
    this.index = 0,
    this.score = 0,
    this.wrongOptions = const {},
    this.lastWrong,
    this.wrongTick = 0,
    this.solved = false,
    this.finished = false,
  });

  final List<QuizQuestion> questions;
  final int index;

  /// Jumlah jawaban benar pada percobaan pertama.
  final int score;

  /// Opsi yang sudah salah dipilih pada soal ini.
  final Set<String> wrongOptions;

  /// Opsi yang terakhir salah dipilih + penghitung untuk memicu animasi goyang.
  final String? lastWrong;
  final int wrongTick;
  final bool solved;
  final bool finished;

  QuizQuestion get current => questions[index];
  int get total => questions.length;

  /// 1–3 bintang untuk layar hasil.
  int get rating {
    final ratio = score / total;
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.6) return 2;
    return 1;
  }

  QuizState copyWith({
    int? index,
    int? score,
    Set<String>? wrongOptions,
    String? lastWrong,
    int? wrongTick,
    bool? solved,
    bool? finished,
  }) => QuizState(
    questions: questions,
    index: index ?? this.index,
    score: score ?? this.score,
    wrongOptions: wrongOptions ?? this.wrongOptions,
    lastWrong: lastWrong ?? this.lastWrong,
    wrongTick: wrongTick ?? this.wrongTick,
    solved: solved ?? this.solved,
    finished: finished ?? this.finished,
  );
}

class QuizController extends Notifier<QuizState> {
  static const roundSize = 6;
  static const optionCount = 3;

  final Random _random = Random();

  /// Dibangun ulang saat bahasa berganti => soal ikut berganti bahasa.
  @override
  QuizState build() => _newRound();

  QuizState _newRound() {
    final pool = [...WordBank.words(ref.watch(languageProvider))]..shuffle(_random);
    final answers = pool.take(roundSize).toList();
    final questions = [
      for (final answer in answers)
        QuizQuestion(
          answer: answer,
          options: ([
            answer,
            ...(pool.where((w) => w.word != answer.word).toList()..shuffle(_random)).take(optionCount - 1),
          ]..shuffle(_random)),
        ),
    ];
    return QuizState(questions: questions);
  }

  void restart() => state = _newRound();

  /// Mengembalikan true jika benar.
  bool choose(WordItem option) {
    final s = state;
    if (s.solved || s.finished || s.wrongOptions.contains(option.word)) return false;

    final sfx = ref.read(sfxServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final correct = option.word == s.current.answer.word;

    if (correct) {
      final firstTry = s.wrongOptions.isEmpty;
      state = s.copyWith(solved: true, score: firstTry ? s.score + 1 : s.score);
      sfx.play(Sfx.success);
      if (firstTry) {
        ref.read(progressProvider.notifier).addStars();
        Future<void>.delayed(const Duration(milliseconds: 450), () => sfx.play(Sfx.star));
      }
      tts.speakWord(option.word);
    } else {
      state = s.copyWith(
        wrongOptions: {...s.wrongOptions, option.word},
        lastWrong: option.word,
        wrongTick: s.wrongTick + 1,
      );
      sfx.play(Sfx.wrong);
      tts.speakWord(option.word);
    }
    return correct;
  }

  void next() {
    final s = state;
    if (s.index + 1 >= s.total) {
      state = s.copyWith(finished: true);
      ref.read(sfxServiceProvider).play(Sfx.success);
      ref
          .read(progressProvider.notifier)
          .saveQuizResult(language: ref.read(languageProvider), score: s.score, total: s.total, starsEarned: s.score);
    } else {
      state = s.copyWith(index: s.index + 1, wrongOptions: {}, wrongTick: 0, solved: false);
    }
  }
}

final quizProvider = NotifierProvider.autoDispose<QuizController, QuizState>(QuizController.new);
