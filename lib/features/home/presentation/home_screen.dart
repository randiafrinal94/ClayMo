import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../shell/application/tab_provider.dart';

/// Beranda: kartu sapaan berisi maskot + 4 menu clay (2x2).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    final menu = [
      _MenuItem('🔤', l.spelling, l.spellingSubtitle, ClayColors.blue, AppTab.spell),
      _MenuItem('🅰️', l.menuLetters, l.menuLettersSubtitle, ClayColors.pink, AppTab.abc),
      _MenuItem('🎯', l.quiz, l.quizSubtitle, ClayColors.mint, AppTab.quiz),
      _MenuItem('🏆', l.albumTitle, l.albumSubtitle, ClayColors.yellow, AppTab.album),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Column(
        children: [
          ClayCard(
            tone: ClayColors.lav,
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  // Animasi tak berujung dikurung di boundary sendiri supaya kartu
                  // di sekitarnya tidak ikut digambar ulang tiap frame.
                  RepaintBoundary(
                    child: const Text('🦉', style: TextStyle(fontSize: 64))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .rotate(begin: -0.0, end: -0.022, duration: 1250.ms, curve: Curves.easeInOut)
                        .moveY(begin: 0, end: -6, duration: 1250.ms, curve: Curves.easeInOut),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.heroTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: ClayColors.text,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.heroSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ClayColors.textSoft),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Column/Row (bukan GridView) agar bayangan kartu tidak terpotong viewport.
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 14),
            // IntrinsicHeight: dua kartu sebaris selalu sama tinggi, dan tumbuh bila teks membungkus.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var col = 0; col < 2; col++) ...[
                    if (col > 0) const SizedBox(width: 14),
                    Expanded(
                      child:
                          _MenuCard(
                                item: menu[row * 2 + col],
                                onTap: () => ref.read(tabProvider.notifier).select(menu[row * 2 + col].tab),
                              )
                              .animate(delay: (90 * (row * 2 + col)).ms)
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.15, curve: clayBounce),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.emoji, this.title, this.subtitle, this.tone, this.tab);

  final String emoji;
  final String title;
  final String subtitle;
  final ClayTone tone;
  final AppTab tab;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.onTap});

  final _MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 150),
      child: ClayCard(
        tone: item.tone,
        semanticLabel: item.title,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.emoji,
              style: TextStyle(
                fontSize: 44,
                shadows: [
                  Shadow(
                    color: const Color(0xFF463C78).withValues(alpha: 0.2),
                    offset: const Offset(2, 4),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ClayColors.text, height: 1.1),
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ClayColors.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}
