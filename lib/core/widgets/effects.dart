import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/clay_colors.dart';
import 'clay_container.dart';

/// Menggoyangkan [child] setiap kali [trigger] berubah (dan > 0).
/// Dipakai untuk feedback "salah" yang lembut.
class ShakeOnTrigger extends StatelessWidget {
  const ShakeOnTrigger({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (trigger <= 0) return child;
    return child
        .animate(key: ValueKey(trigger))
        .shake(hz: 5, offset: const Offset(10, 0), duration: 420.ms, curve: Curves.easeOut);
  }
}

/// Efek "gepeng lalu membal" setiap kali [trigger] berubah (dan > 0).
/// Dipakai untuk kartu huruf / suku kata / slot yang baru disentuh.
class SquishOnTrigger extends StatefulWidget {
  const SquishOnTrigger({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<SquishOnTrigger> createState() => _SquishOnTriggerState();
}

class _SquishOnTriggerState extends State<SquishOnTrigger> with SingleTickerProviderStateMixin {
  static final _scale = TweenSequence<Offset>([
    TweenSequenceItem(
      tween: Tween(begin: const Offset(1, 1), end: const Offset(1.15, 0.82)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(begin: const Offset(1.15, 0.82), end: const Offset(0.92, 1.1)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(begin: const Offset(0.92, 1.1), end: const Offset(1, 1)),
      weight: 40,
    ),
  ]);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void didUpdateWidget(SquishOnTrigger old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger > 0) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final s = _scale.transform(Curves.easeInOut.transform(_controller.value));
        return Transform(alignment: Alignment.center, transform: Matrix4.diagonal3Values(s.dx, s.dy, 1), child: child);
      },
    );
  }
}

/// Konfeti pastel. Panggil `controller.play()` untuk merayakan.
class ClayConfetti extends StatelessWidget {
  const ClayConfetti({super.key, required this.controller});

  final ConfettiController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: math.pi / 2,
        blastDirectionality: BlastDirectionality.explosive,
        emissionFrequency: 0.06,
        numberOfParticles: 22,
        maxBlastForce: 24,
        minBlastForce: 8,
        gravity: 0.25,
        shouldLoop: false,
        colors: ClayColors.confetti,
      ),
    );
  }
}

/// Bintang yang "meletup" di tengah layar setiap kali [trigger] bertambah.
class StarBurst extends StatefulWidget {
  const StarBurst({super.key, required this.trigger});

  final int trigger;

  @override
  State<StarBurst> createState() => _StarBurstState();
}

class _StarBurstState extends State<StarBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didUpdateWidget(StarBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger > 0) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          if (t == 0 || t == 1) return const SizedBox.shrink();
          final scale = Curves.elasticOut.transform(math.min(1, t * 1.6)) * 1.2;
          final opacity = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3);
          return Center(
            child: Opacity(
              opacity: opacity.clamp(0, 1),
              child: Transform.translate(
                offset: Offset(0, -60 * t),
                child: Transform.scale(
                  scale: scale,
                  child: const Text(
                    '⭐',
                    style: TextStyle(fontSize: 120, shadows: [Shadow(color: Colors.black26, blurRadius: 20)]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Toast clay di atas layar (mis. "Stiker baru!"). Hilang sendiri setelah ~3 detik.
void showClayToast(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  final top = MediaQuery.paddingOf(context).top + 76;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: top,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child:
                ClayContainer(
                      tone: ClayColors.lav,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: ClayColors.text),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: -0.5, end: 0, duration: 450.ms, curve: clayBounce)
                    .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), duration: 450.ms, curve: clayBounce)
                    .then(delay: 2300.ms)
                    .fadeOut(duration: 300.ms),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Timer(const Duration(milliseconds: 3100), () {
    if (entry.mounted) entry.remove();
  });
}
