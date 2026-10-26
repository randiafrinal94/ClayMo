import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/tts_service.dart';
import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_button.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../core/widgets/clay_pressable.dart';
import '../../../core/widgets/effects.dart';
import '../../../core/widgets/picture_card.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../data/word_bank.dart';
import '../../../l10n/app_localizations.dart';
import '../../language/application/language_provider.dart';
import '../../shell/application/tab_provider.dart';
import '../application/quiz_controller.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));
  int _burst = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _later(const Duration(milliseconds: 600), _askQuestion);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _later(Duration delay, VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (mounted) action();
    });
  }

  void _askQuestion() {
    ref.read(ttsServiceProvider).speakPhrase(ref.read(l10nProvider).quizPrompt);
  }

  void _onChoose(WordItem option) {
    final correct = ref.read(quizProvider.notifier).choose(option);
    if (!correct) return;

    // Hanya soal yang dijawab benar di percobaan pertama memberi bintang + konfeti.
    final firstTry = ref.read(quizProvider).wrongOptions.isEmpty;
    if (firstTry) {
      _confetti.play();
      setState(() => _burst++);
    }
    _later(const Duration(milliseconds: 2200), () {
      ref.read(quizProvider.notifier).next();
      if (ref.read(quizProvider).finished) {
        _confetti.play();
      } else {
        _later(const Duration(milliseconds: 500), _askQuestion);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);

    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: state.finished
              ? _ResultView(
                  key: const ValueKey('result'),
                  state: state,
                  onRestart: () {
                    ref.read(quizProvider.notifier).restart();
                    _later(const Duration(milliseconds: 400), _askQuestion);
                  },
                )
              : _QuestionView(key: ValueKey('q${state.index}'), state: state, onChoose: _onChoose, onAsk: _askQuestion),
        ),
        Positioned.fill(
          child: Stack(
            children: [
              ClayConfetti(controller: _confetti),
              StarBurst(trigger: _burst),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({super.key, required this.state, required this.onChoose, required this.onAsk});

  final QuizState state;
  final void Function(WordItem) onChoose;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final question = state.current;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Column(
        children: [
          ScreenTitle(l.quiz),
          ScreenHint(l.questionProgress(state.index + 1, state.total)),
          PictureCard(emoji: question.answer.emoji),
          const SizedBox(height: 14),
          ClayButton(
            emoji: '🔊',
            label: l.listenQuestion,
            tone: ClayColors.blue,
            height: 48,
            fontSize: 17,
            onTap: onAsk,
          ),
          const SizedBox(height: 14),
          Text(
            l.quizThinking,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ClayColors.text),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < question.options.length; i++) ...[
            _OptionButton(
              item: question.options[i],
              tone: ClayColors.rainbowAt(i + 2),
              state: state,
              onTap: () => onChoose(question.options[i]),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.item, required this.tone, required this.state, required this.onTap});

  final WordItem item;
  final ClayTone tone;
  final QuizState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAnswer = item.word == state.current.answer.word;
    final wasWrong = state.wrongOptions.contains(item.word);
    final showCorrect = state.solved && isAnswer;
    final dimmed = wasWrong || (state.solved && !isAnswer);

    return ShakeOnTrigger(
      trigger: state.lastWrong == item.word ? state.wrongTick : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: dimmed ? 0.45 : 1,
        child: ClayPressable(
          sound: null, // suara diputar controller (success / wrong)
          semanticLabel: item.word,
          onTap: dimmed || state.solved ? null : onTap,
          builder: (context, pressed) => ClayContainer(
            tone: showCorrect
                ? const ClayTone(ClayColors.good)
                : wasWrong
                ? const ClayTone(ClayColors.bad)
                : tone,
            width: double.infinity,
            height: 68,
            radius: 26,
            pressed: pressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showCorrect) ...[
                    const Icon(Icons.check_circle_rounded, color: ClayColors.text, size: 30),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    item.word,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: ClayColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView({super.key, required this.state, required this.onRestart});

  final QuizState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Opacity(
                    opacity: i < state.rating ? 1 : 0.25,
                    child: Text('⭐', style: TextStyle(fontSize: i == 1 ? 84 : 64))
                        .animate(delay: (350 * i).ms)
                        .scale(begin: const Offset(0, 0), duration: 700.ms, curve: Curves.elasticOut),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l.roundComplete,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: ClayColors.text),
          ),
          const SizedBox(height: 8),
          Text(
            l.roundScore(state.score, state.total),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: ClayColors.textSoft),
          ),
          const SizedBox(height: 32),
          ClayButton(
            label: l.playAgain,
            icon: Icons.replay_rounded,
            tone: ClayColors.mint,
            height: 56,
            fontSize: 22,
            onTap: onRestart,
          ),
          const SizedBox(height: 16),
          ClayButton(
            label: l.backHome,
            icon: Icons.home_rounded,
            tone: ClayColors.lav,
            height: 56,
            fontSize: 22,
            onTap: () => ref.read(tabProvider.notifier).select(AppTab.home),
          ),
        ],
      ),
    );
  }
}
