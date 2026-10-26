import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/tts_service.dart';
import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_button.dart';
import '../../../core/widgets/clay_card.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../core/widgets/clay_pressable.dart';
import '../../../core/widgets/effects.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../data/word_bank.dart';
import '../../../l10n/app_localizations.dart';
import '../../language/application/language_provider.dart';
import '../../language/domain/app_language.dart';

enum _PhonicsTab { alphabet, explore }

/// Layar "Huruf": tab Alfabet (A–Z + contoh kata) dan tab Suku Kata (ID) /
/// Kata Fonik (EN).
class PhonicsScreen extends ConsumerStatefulWidget {
  const PhonicsScreen({super.key});

  @override
  ConsumerState<PhonicsScreen> createState() => _PhonicsScreenState();
}

class _PhonicsScreenState extends ConsumerState<PhonicsScreen> {
  _PhonicsTab _tab = _PhonicsTab.alphabet;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final language = ref.watch(languageProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: l.alphabet,
                  selected: _tab == _PhonicsTab.alphabet,
                  onTap: () => setState(() => _tab = _PhonicsTab.alphabet),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TabButton(
                  label: language == AppLanguage.id ? l.syllables : l.phonicsWords,
                  selected: _tab == _PhonicsTab.explore,
                  onTap: () => setState(() => _tab = _PhonicsTab.explore),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (_tab) {
            _PhonicsTab.alphabet => const _AlphabetView(key: ValueKey('alphabet')),
            _PhonicsTab.explore =>
              language == AppLanguage.id
                  ? const _SyllablesView(key: ValueKey('syllables'))
                  : const _PhonicsWordsView(key: ValueKey('phonics-words')),
          },
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, pressed) => ClayContainer(
        tone: selected ? ClayColors.pink : ClayColors.tabIdle,
        height: 48,
        radius: 20,
        pressed: pressed,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ClayColors.text),
          ),
        ),
      ),
    );
  }
}

const _scrollPadding = EdgeInsets.fromLTRB(16, 6, 16, 14);

// -----------------------------------------------------------------------------
// Alfabet A–Z
// -----------------------------------------------------------------------------

class _AlphabetView extends ConsumerStatefulWidget {
  const _AlphabetView({super.key});

  @override
  ConsumerState<_AlphabetView> createState() => _AlphabetViewState();
}

class _AlphabetViewState extends ConsumerState<_AlphabetView> {
  /// Penghitung tap per huruf => memicu animasi gepeng pada kartu itu saja.
  final Map<int, int> _taps = {};

  void _select(int index, LetterExample item) {
    setState(() => _taps[index] = (_taps[index] ?? 0) + 1);
    ref.read(ttsServiceProvider).speakLetterIntro(item.letter, item.word);
  }

  @override
  Widget build(BuildContext context) {
    final letters = WordBank.alphabet(ref.watch(languageProvider));

    return SingleChildScrollView(
      padding: _scrollPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 11.0;
          final cell = (constraints.maxWidth - gap * 3) / 4;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < letters.length; i++)
                SizedBox(
                  width: cell,
                  height: cell * 1.05,
                  child: SquishOnTrigger(
                    trigger: _taps[i] ?? 0,
                    child: ClayPressable(
                      semanticLabel: letters[i].letter,
                      onTap: () => _select(i, letters[i]),
                      builder: (context, pressed) => ClayContainer(
                        tone: ClayColors.rainbowAt(i),
                        radius: 22,
                        pressed: pressed,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              letters[i].letter,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: ClayColors.text,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(letters[i].emoji, style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Suku kata Indonesia: pilih konsonan, lalu Ba-Bi-Bu-Be-Bo
// -----------------------------------------------------------------------------

class _SyllablesView extends ConsumerStatefulWidget {
  const _SyllablesView({super.key});

  @override
  ConsumerState<_SyllablesView> createState() => _SyllablesViewState();
}

class _SyllablesViewState extends ConsumerState<_SyllablesView> {
  String _consonant = WordBank.syllableConsonants.first;

  /// Vokal yang sedang disorot pada kotak detail (null = belum ada).
  String? _vowel;
  final List<int> _taps = List.filled(WordBank.syllableVowels.length, 0);
  final List<Timer> _timers = [];

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  TtsService get _tts => ref.read(ttsServiceProvider);

  void _pickConsonant(String c) {
    setState(() {
      _consonant = c;
      _vowel = null;
    });
    _speak(0);
  }

  void _speak(int i) {
    setState(() {
      _vowel = WordBank.syllableVowels[i];
      _taps[i]++;
    });
    _tts.speakSyllable('$_consonant${WordBank.syllableVowels[i]}');
  }

  /// Baca semua: satu ucapan utuh, sambil kartu bergelombang bergantian.
  void _speakAll() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _tts.speakSyllables(WordBank.syllableRow(_consonant));
    for (var i = 0; i < WordBank.syllableVowels.length; i++) {
      _timers.add(
        Timer(Duration(milliseconds: 700 * i), () {
          if (!mounted) return;
          setState(() {
            _vowel = WordBank.syllableVowels[i];
            _taps[i]++;
          });
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final syllables = WordBank.syllableRow(_consonant);

    return SingleChildScrollView(
      padding: _scrollPadding,
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in WordBank.syllableConsonants)
                ClayPressable(
                  semanticLabel: c,
                  onTap: () => _pickConsonant(c),
                  builder: (context, pressed) => ClayContainer(
                    tone: c == _consonant ? ClayColors.yellow : ClayColors.white,
                    width: 46,
                    height: 46,
                    radius: 16,
                    pressed: pressed,
                    child: Center(
                      child: Text(
                        c,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ClayColors.text),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final w = (constraints.maxWidth - gap * 4) / 5;
              return Row(
                children: [
                  for (var i = 0; i < syllables.length; i++) ...[
                    if (i > 0) const SizedBox(width: gap),
                    SizedBox(
                      width: w,
                      height: w * 1.15,
                      child: SquishOnTrigger(
                        trigger: _taps[i],
                        child: ClayPressable(
                          semanticLabel: syllables[i],
                          onTap: () => _speak(i),
                          builder: (context, pressed) => ClayContainer(
                            tone: ClayColors.rainbowAt(i),
                            radius: 20,
                            pressed: pressed,
                            child: Center(
                              child: FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    syllables[i],
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: ClayColors.text,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          ClayCard(
            width: double.infinity,
            height: 64,
            padding: const EdgeInsets.all(12),
            child: Center(
              child: _vowel == null
                  ? Text(
                      '${l.syllableTouch} 👆',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ClayColors.text),
                    )
                  : Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: _consonant),
                          TextSpan(
                            text: _vowel,
                            style: const TextStyle(color: ClayColors.pinkInk),
                          ),
                          const TextSpan(text: ' = '),
                          TextSpan(
                            text: '$_consonant$_vowel',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: ClayColors.text),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          ClayButton(emoji: '▶', label: l.playAll, tone: ClayColors.yellow, height: 56, fontSize: 22, onTap: _speakAll),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Phonics words Inggris (word families)
// -----------------------------------------------------------------------------

class _PhonicsWordsView extends ConsumerWidget {
  const _PhonicsWordsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tts = ref.read(ttsServiceProvider);
    final groups = WordBank.phonicsGroups;

    return SingleChildScrollView(
      padding: _scrollPadding,
      child: Column(
        children: [
          ScreenHint(l.phonicsHint),
          for (var g = 0; g < groups.length; g++) ...[
            if (g > 0) const SizedBox(height: 16),
            ClayCard(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClayContainer(
                    tone: ClayColors.rainbowAt(g),
                    radius: 16,
                    depth: 0.6,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      groups[g].title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: ClayColors.text),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final item in groups[g].words)
                        ClayPressable(
                          semanticLabel: item.word,
                          onTap: () => tts.speakPhonicsWord(item.word),
                          builder: (context, pressed) => ClayContainer(
                            tone: ClayColors.rainbowAt(g),
                            radius: 22,
                            pressed: pressed,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(item.emoji, style: const TextStyle(fontSize: 34)),
                                Text(
                                  item.word,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: ClayColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
