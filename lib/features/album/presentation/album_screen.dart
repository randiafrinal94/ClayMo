import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/sfx_service.dart';
import '../../../core/audio/tts_service.dart';
import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_card.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../core/widgets/clay_pressable.dart';
import '../../../core/widgets/effects.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../language/application/language_provider.dart';
import '../../language/domain/app_language.dart';
import '../../progress/application/progress_provider.dart';
import '../../progress/domain/sticker.dart';

/// Album stiker: progres bintang menuju stiker berikutnya + kisi stiker.
class AlbumScreen extends ConsumerStatefulWidget {
  const AlbumScreen({super.key});

  @override
  ConsumerState<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends ConsumerState<AlbumScreen> {
  /// Penghitung tap per stiker: gepeng (terbuka) atau goyang (terkunci).
  final Map<int, int> _taps = {};

  void _tap(int index, Sticker sticker, bool unlocked) {
    setState(() => _taps[index] = (_taps[index] ?? 0) + 1);
    if (!unlocked) return;
    final language = ref.read(languageProvider);
    ref.read(ttsServiceProvider).speakWord(_nameOf(sticker, language));
  }

  String _nameOf(Sticker s, AppLanguage language) => language == AppLanguage.id ? s.nameId : s.nameEn;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final language = ref.watch(languageProvider);
    final stars = ref.watch(starsProvider);
    final stickers = StickerCatalog.all;

    final next = stickers.where((s) => stars < s.requiredStars).firstOrNull;
    final previous = stickers.where((s) => stars >= s.requiredStars).lastOrNull;
    final base = previous?.requiredStars ?? 0;
    final fraction = next == null ? 1.0 : (stars - base) / (next.requiredStars - base);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Column(
        children: [
          ScreenTitle(l.albumTitle),
          ClayCard(
            tone: ClayColors.yellow,
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text(
                  l.albumStars(stars),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: ClayColors.text),
                ),
                const SizedBox(height: 8),
                _ProgressBar(fraction: fraction),
                const SizedBox(height: 8),
                Text(
                  next == null
                      ? l.albumDone
                      : l.albumNext(next.requiredStars - stars, next.emoji, _nameOf(next, language)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ClayColors.textSoft),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final cell = (constraints.maxWidth - gap * 2) / 3;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < stickers.length; i++)
                    SizedBox(
                      width: cell,
                      height: cell,
                      child: _StickerTile(
                        sticker: stickers[i],
                        name: _nameOf(stickers[i], language),
                        unlocked: stars >= stickers[i].requiredStars,
                        tone: ClayColors.rainbowAt(i),
                        taps: _taps[i] ?? 0,
                        onTap: (unlocked) => _tap(i, stickers[i], unlocked),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 16,
        child: Stack(
          children: [
            const Positioned.fill(child: ClayContainer(tone: ClayColors.white, radius: 99, depth: 0, inset: true)),
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: fraction.clamp(0, 1)),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (context, value, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: value.clamp(0, 1),
                    heightFactor: 1,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                        gradient: LinearGradient(colors: [Color(0xFFFF9EC3), Color(0xFFFFB86B)]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({
    required this.sticker,
    required this.name,
    required this.unlocked,
    required this.tone,
    required this.taps,
    required this.onTap,
  });

  final Sticker sticker;
  final String name;
  final bool unlocked;
  final ClayTone tone;
  final int taps;
  final void Function(bool unlocked) onTap;

  @override
  Widget build(BuildContext context) {
    return ShakeOnTrigger(
      trigger: unlocked ? 0 : taps,
      child: SquishOnTrigger(
        trigger: unlocked ? taps : 0,
        child: ClayPressable(
          sound: unlocked ? Sfx.pop : Sfx.wrong,
          semanticLabel: unlocked ? name : '${sticker.requiredStars}',
          onTap: () => onTap(unlocked),
          builder: (context, pressed) => ClayContainer(
            tone: unlocked ? tone : ClayColors.locked,
            inset: !unlocked,
            radius: 24,
            pressed: pressed,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: unlocked ? 1 : 0.35,
                  child: Text(
                    unlocked ? sticker.emoji : '❓',
                    style: TextStyle(
                      fontSize: 46,
                      shadows: unlocked
                          ? [
                              Shadow(
                                color: const Color(0xFF463C78).withValues(alpha: 0.25),
                                offset: const Offset(2, 4),
                                blurRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
                Text(
                  unlocked ? name : '${sticker.requiredStars} ⭐',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ClayColors.textSoft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
