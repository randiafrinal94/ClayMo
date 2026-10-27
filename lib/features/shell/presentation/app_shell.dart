import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/sfx_service.dart';
import '../../../core/audio/tts_service.dart';
import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../core/widgets/clay_pressable.dart';
import '../../../core/widgets/effects.dart';
import '../../../l10n/app_localizations.dart';
import '../../album/presentation/album_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../language/presentation/language_switcher.dart';
import '../../language/presentation/voice_setup_guard.dart';
import '../../phonics/presentation/phonics_screen.dart';
import '../../language/application/language_provider.dart';
import '../../language/domain/app_language.dart';
import '../../progress/application/progress_provider.dart';
import '../../progress/presentation/stars_chip.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../../spelling/presentation/spelling_screen.dart';
import '../application/tab_provider.dart';

/// Kerangka utama: bilah atas (logo, bintang, bahasa), isi tab, dan navigasi
/// bawah clay. Pindah tab = ganti isi dengan animasi masuk yang membal.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(tabProvider);

    // Stiker baru terbuka => fanfare + toast (jeda agar tidak bertabrakan dengan bintang meletup).
    ref.listen(unlockedStickersProvider, (prev, next) {
      if (prev == null || next.length <= prev.length) return;
      final sticker = next.last;
      final language = ref.read(languageProvider);
      final name = language == AppLanguage.id ? sticker.nameId : sticker.nameEn;
      final message = ref.read(l10nProvider).stickerUnlocked(sticker.emoji, name);
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (!context.mounted) return;
        ref.read(sfxServiceProvider).play(Sfx.star);
        showClayToast(context, message);
      });
    });

    return Scaffold(
      body: VoiceSetupGuard(
        child: SafeArea(
          child: Column(
            children: [
              const _TopBar(),
              Expanded(
                // Transisi ringan (fade + geser saja, tanpa scale) di dalam RepaintBoundary
                // agar isi layar tidak dirasterisasi ulang tiap frame.
                child: RepaintBoundary(
                  child: KeyedSubtree(
                    key: ValueKey(tab),
                    child: _screenFor(tab)
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .slideY(begin: 0.03, end: 0, duration: 260.ms, curve: Curves.easeOutCubic),
                  ),
                ),
              ),
              const _NavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _screenFor(AppTab tab) => switch (tab) {
    AppTab.home => const HomeScreen(),
    AppTab.spell => const SpellingScreen(),
    AppTab.abc => const PhonicsScreen(),
    AppTab.quiz => const QuizScreen(),
    AppTab.album => const AlbumScreen(),
  };
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: _Logo()),
          ),
          SizedBox(width: 8),
          StarsChip(),
          SizedBox(width: 8),
          LanguageSwitcher(),
        ],
      ),
    );
  }
}

/// Logo: kotak clay kuning berisi buku + tulisan "Claymo" dua warna.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ClayContainer(
            tone: ClayColors.yellow,
            width: 40,
            height: 40,
            radius: 15,
            child: Center(child: Text('📚', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 8),
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Clay',
                  style: TextStyle(color: ClayColors.pinkInk),
                ),
                TextSpan(
                  text: 'mo',
                  style: TextStyle(color: ClayColors.blueInk),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends ConsumerWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(tabProvider);
    final items = [
      (AppTab.home, '🏠', l.navHome),
      (AppTab.spell, '🔤', l.navSpell),
      (AppTab.abc, '🅰️', l.navLetters),
      (AppTab.quiz, '🎯', l.navQuiz),
      (AppTab.album, '🏆', l.navAlbum),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: ClayContainer(
        radius: 30,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
        child: Row(
          children: [
            for (final (tab, emoji, label) in items)
              Expanded(
                child: _NavItem(
                  emoji: emoji,
                  label: label,
                  selected: tab == current,
                  onTap: () {
                    if (tab == current) return;
                    ref.read(ttsServiceProvider).stop();
                    ref.read(tabProvider.notifier).select(tab);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.emoji, required this.label, required this.selected, required this.onTap});

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClayPressable(
      sound: Sfx.tap,
      pressedScale: const Offset(0.85, 0.8),
      semanticLabel: label,
      onTap: onTap,
      builder: (context, pressed) {
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: clayBounce,
              offset: Offset(0, selected ? -0.06 : 0),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                curve: clayBounce,
                scale: selected ? 1.15 : 1,
                child: Text(emoji, style: const TextStyle(fontSize: 25, height: 1.2)),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? ClayColors.text : ClayColors.textSoft,
              ),
            ),
          ],
        );
        const padding = EdgeInsets.symmetric(vertical: 6);
        // Tab aktif = pil pink cekung-lembut; tab lain transparan tanpa bayangan.
        if (!selected) return Padding(padding: padding, child: content);
        return ClayContainer(
          tone: ClayColors.pink,
          flat: true,
          pressed: pressed,
          radius: 20,
          padding: padding,
          child: content,
        );
      },
    );
  }
}
