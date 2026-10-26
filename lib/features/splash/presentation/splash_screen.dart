import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/sfx_service.dart';
import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../shell/presentation/app_shell.dart';

/// Durasi splash sebelum pindah ke beranda.
const splashDuration = Duration(seconds: 3);

/// Splash interaktif: maskot + logo clay jatuh membal, chime sambutan,
/// lalu 3 bola clay melompat sebagai indikator loading.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(splashDuration, _goHome);
    _playWelcome();
  }

  Future<void> _playWelcome() async {
    final sfx = ref.read(sfxServiceProvider);
    // Player baru siap setelah preload; tanpa menunggu, chime pertama hilang.
    await sfx.preload();
    if (mounted) sfx.play(Sfx.welcome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => const AppShell(),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Semantics(
          label: l.appName,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Mascot(),
                const SizedBox(height: 28),
                const _SplashLogo(),
                const SizedBox(height: 56),
                Semantics(
                  label: l.loading,
                  child: const ExcludeSemantics(child: _JumpingDots()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Maskot: bola clay kuning berwajah. Jatuh membal, lalu bernapas pelan.
class _Mascot extends StatelessWidget {
  const _Mascot();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child:
          SizedBox(
                width: 190,
                height: 190,
                child: ClayContainer(
                  tone: ClayColors.yellow,
                  radius: 95,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(left: 28, bottom: 62, child: _Cheek()),
                      const Positioned(right: 28, bottom: 62, child: _Cheek()),
                      const Positioned(left: 52, top: 56, child: _Eye()),
                      const Positioned(right: 52, top: 56, child: _Eye()),
                      Positioned(
                        bottom: 40,
                        child: Container(
                          width: 44,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: ClayColors.text,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              // Jatuh dari atas dan memantul di "kasur empuk", lalu gepeng-melar saat mendarat.
              .animate()
              .fadeIn(duration: 150.ms)
              .moveY(begin: -420, end: 0, duration: 1000.ms, curve: Curves.bounceOut)
              .scale(
                begin: const Offset(0.7, 1.2),
                end: const Offset(1, 1),
                delay: 250.ms,
                duration: 900.ms,
                curve: Curves.elasticOut,
              )
              // Setelah mendarat, bernapas pelan seperti tanah liat yang hidup.
              .animate(onPlay: (c) => c.repeat(reverse: true), delay: 1300.ms)
              .scaleXY(begin: 1, end: 1.04, duration: 900.ms, curve: Curves.easeInOut),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 30,
      decoration: BoxDecoration(color: ClayColors.text, borderRadius: BorderRadius.circular(14)),
      alignment: Alignment.topRight,
      padding: const EdgeInsets.all(4),
      child: const DecoratedBox(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: SizedBox(width: 8, height: 8),
      ),
    );
  }
}

class _Cheek extends StatelessWidget {
  const _Cheek();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: ClayColors.pinkInk.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

/// Logo "CLAYMO": satu keping clay per huruf, jatuh bergantian dengan pegas.
class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    const letters = ['C', 'L', 'A', 'Y', 'M', 'O'];
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < letters.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child:
                  ClayContainer(
                        tone: ClayColors.rainbowAt(i),
                        width: 48,
                        height: 58,
                        radius: 18,
                        depth: 0.7,
                        child: Center(
                          child: Text(
                            letters[i],
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: ClayColors.text),
                          ),
                        ),
                      )
                      .animate(delay: (700 + 90 * i).ms)
                      .fadeIn(duration: 120.ms)
                      .moveY(begin: -260, end: 0, duration: 800.ms, curve: Curves.elasticOut)
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1, 1),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      ),
            ),
        ],
      ),
    );
  }
}

/// Indikator loading: 3 bola clay pastel yang melompat bergantian.
class _JumpingDots extends StatelessWidget {
  const _JumpingDots();

  static const _tones = [ClayColors.pink, ClayColors.mint, ClayColors.blue];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _tones.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: ClayContainer(tone: _tones[i], width: 28, height: 28, radius: 14, depth: 0.6)
                  .animate(onPlay: (c) => c.repeat(reverse: true), delay: (1400 + 180 * i).ms)
                  .moveY(begin: 0, end: -30, duration: 380.ms, curve: Curves.easeOutQuad)
                  .scale(begin: const Offset(1.15, 0.85), end: const Offset(1, 1), duration: 380.ms),
            ),
        ],
      ),
    );
  }
}
