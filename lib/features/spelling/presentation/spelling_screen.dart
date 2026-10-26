import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_button.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../core/widgets/clay_pressable.dart';
import '../../../core/widgets/effects.dart';
import '../../../core/widgets/picture_card.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';
import '../application/spelling_controller.dart';

class SpellingScreen extends ConsumerStatefulWidget {
  const SpellingScreen({super.key});

  @override
  ConsumerState<SpellingScreen> createState() => _SpellingScreenState();
}

class _SpellingScreenState extends ConsumerState<SpellingScreen> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));
  int _burst = 0;
  Timer? _speakTimer;

  @override
  void initState() {
    super.initState();
    _speakWordSoon();
  }

  @override
  void dispose() {
    _speakTimer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  /// Kata baru dibacakan setelah transisi layar selesai.
  void _speakWordSoon() {
    _speakTimer?.cancel();
    _speakTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) ref.read(spellingProvider.notifier).listen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    ref.listen(spellingProvider.select((s) => s.current.word), (_, _) => _speakWordSoon());
    ref.listen(spellingProvider.select((s) => s.completed), (_, done) {
      if (!done) return;
      _confetti.play();
      setState(() => _burst++);
    });

    final state = ref.watch(spellingProvider);
    final notifier = ref.read(spellingProvider.notifier);

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
              child: Column(
                children: [
                  ScreenTitle(l.spelling),
                  ScreenHint(l.wordProgress(state.index + 1, state.deck.length)),
                  PictureCard(emoji: state.current.emoji),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ClayButton(
                        emoji: '🔊',
                        label: l.listen,
                        tone: ClayColors.blue,
                        height: 48,
                        fontSize: 17,
                        onTap: notifier.listen,
                      ),
                      ClayButton(
                        emoji: '🐢',
                        label: l.slow,
                        tone: ClayColors.lav,
                        height: 48,
                        fontSize: 17,
                        onTap: notifier.listenSlow,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Slots(state: state, maxWidth: constraints.maxWidth - 32),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state.completed
                        ? Column(
                            key: const ValueKey('done'),
                            children: [
                              Text(
                                l.wellDone,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: ClayColors.text,
                                ),
                              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                              const SizedBox(height: 12),
                              ClayButton(
                                label: l.next,
                                icon: Icons.arrow_forward_rounded,
                                tone: ClayColors.mint,
                                height: 56,
                                fontSize: 22,
                                onTap: notifier.next,
                              ),
                            ],
                          )
                        : _Tiles(key: const ValueKey('tiles'), state: state),
                  ),
                ],
              ),
            ),
          ),
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

class _Slots extends StatelessWidget {
  const _Slots({required this.state, required this.maxWidth});

  final SpellingState state;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    final count = state.slots.length;
    final width = ((maxWidth - gap * (count - 1)) / count).clamp(36.0, 54.0);
    final height = width * 62 / 54;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: gap,
      runSpacing: gap,
      children: [
        for (var i = 0; i < count; i++)
          state.slots[i] == null
              ? ClayContainer(
                  key: ValueKey('empty${state.index}-$i'),
                  inset: true,
                  width: width,
                  height: height,
                  radius: 20,
                )
              : ClayContainer(
                  key: ValueKey('filled${state.index}-$i'),
                  tone: ClayColors.rainbowAt(i),
                  width: width,
                  height: height,
                  radius: 20,
                  child: Center(child: _LetterText(state.slots[i]!, width * 0.6)),
                ).animate().scale(begin: const Offset(0.3, 0.3), duration: 450.ms, curve: clayBounce),
      ],
    );
  }
}

class _Tiles extends ConsumerWidget {
  const _Tiles({super.key, required this.state});

  final SpellingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final small = state.current.letters.length > 6;
    final w = small ? 50.0 : 60.0;
    final h = small ? 58.0 : 66.0;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final tile in state.tiles)
          ShakeOnTrigger(
            trigger: state.wrongTileId == tile.id ? state.wrongTick : 0,
            child: tile.placed
                ? SizedBox(width: w, height: h) // tempat kosong, ukuran tetap
                : ClayPressable(
                    sound: null, // suara diputar controller (place / wrong)
                    semanticLabel: tile.letter,
                    onTap: () => ref.read(spellingProvider.notifier).tapTile(tile.id),
                    builder: (context, pressed) => ClayContainer(
                      tone: ClayColors.rainbowAt(tile.id),
                      width: w,
                      height: h,
                      radius: 22,
                      pressed: pressed,
                      child: Center(child: _LetterText(tile.letter, small ? 28 : 32)),
                    ),
                  ),
          ),
      ],
    );
  }
}

class _LetterText extends StatelessWidget {
  const _LetterText(this.letter, this.size);

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
    letter,
    style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: ClayColors.text, height: 1),
  );
}
