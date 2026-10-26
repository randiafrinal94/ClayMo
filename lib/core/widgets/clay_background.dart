import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/clay_colors.dart';

/// Layar lebih lebar dari ini dianggap tablet/desktop/web: aplikasi tampil di
/// dalam bingkai ponsel di atas latar polkadot, persis seperti desain acuan.
const double _frameBreakpoint = 480;

/// Lebar & tinggi maksimum bingkai ponsel.
const double _frameWidth = 430;
const double _frameMaxHeight = 860;
const double _frameBorder = 10;

/// Latar seluruh aplikasi. Dipasang lewat `MaterialApp.builder` sehingga semua
/// layar (dan transisi antar layar) berbagi satu latar yang sama.
class ClayBackground extends StatelessWidget {
  const ClayBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _frameBreakpoint) {
          return DecoratedBox(
            decoration: const BoxDecoration(gradient: ClayColors.pageGradient),
            child: child,
          );
        }
        return _FramedPhone(size: constraints.biggest, child: child);
      },
    );
  }
}

class _FramedPhone extends StatelessWidget {
  const _FramedPhone({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final height = math.min(size.height, _frameMaxHeight);
    final radius = size.height < 700 ? 30.0 : 48.0;
    final inner = Size(_frameWidth - _frameBorder * 2, height - _frameBorder * 2);
    final mq = MediaQuery.of(context);

    return Stack(
      children: [
        const Positioned.fill(child: _PolkaBackground()),
        const _Decorations(),
        Center(
          child: Container(
            width: _frameWidth,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Color(0x595A3C8C), offset: Offset(0, 30), blurRadius: 60),
                BoxShadow(color: Color(0xFFE7D6FF), offset: Offset(0, 8)),
              ],
            ),
            padding: const EdgeInsets.all(_frameBorder),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius - _frameBorder),
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: ClayColors.pageGradient),
                child: MediaQuery(
                  data: mq.copyWith(size: inner, padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Polkadot pastel yang bergeser pelan (40 detik per siklus).
class _PolkaBackground extends StatefulWidget {
  const _PolkaBackground();

  @override
  State<_PolkaBackground> createState() => _PolkaBackgroundState();
}

class _PolkaBackgroundState extends State<_PolkaBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 40))
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: CustomPaint(painter: _PolkaPainter(_controller)));
  }
}

class _PolkaPainter extends CustomPainter {
  _PolkaPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  static const _tile = 90.0;
  static final _dots = [
    (const Offset(20, 20), 8.5, const Color(0xA6FFFFFF)),
    (const Offset(70, 70), 11.5, const Color(0xB3A8D8FF)),
    (const Offset(20, 70), 6.5, const Color(0xCCFFE9A0)),
    (const Offset(70, 20), 7.5, const Color(0xCCB5ECD2)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFD9E8));
    // 360px = 4 petak, sehingga loop bergeser mulus.
    final shift = animation.value * 360;
    final startX = -_tile + (shift % _tile);
    final startY = -_tile + (shift % _tile);
    final paint = Paint();
    for (var y = startY; y < size.height; y += _tile) {
      for (var x = startX; x < size.width; x += _tile) {
        for (final (center, radius, color) in _dots) {
          canvas.drawCircle(Offset(x, y) + center, radius, paint..color = color);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PolkaPainter old) => false;
}

/// Emoji melayang di sekitar bingkai ponsel (hanya tampil di layar lebar).
class _Decorations extends StatelessWidget {
  const _Decorations();

  @override
  Widget build(BuildContext context) {
    // (emoji, kiri?, x-fraksi, y-fraksi, ukuran, delay ms)
    const items = [
      ('⭐', true, 0.06, 0.10, 54.0, 0),
      ('🌈', true, 0.10, 0.78, 54.0, 1000),
      ('🎈', false, 0.07, 0.14, 54.0, 2000),
      ('🦋', false, 0.10, 0.76, 54.0, 3000),
      ('☁️', true, 0.20, 0.45, 40.0, 500),
      ('🍭', false, 0.20, 0.48, 40.0, 2500),
    ];
    return LayoutBuilder(
      builder: (context, c) => Stack(
        children: [
          for (final (emoji, left, fx, fy, size, delay) in items)
            Positioned(
              left: left ? c.maxWidth * fx : null,
              right: left ? null : c.maxWidth * fx,
              top: c.maxHeight * fy,
              child: IgnorePointer(
                child:
                    Text(
                          emoji,
                          style: TextStyle(
                            fontSize: size,
                            decoration: TextDecoration.none,
                            shadows: [
                              Shadow(
                                color: ClayColors.ink.withValues(alpha: 0.2),
                                offset: const Offset(4, 6),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true), delay: delay.ms)
                        .moveY(begin: 0, end: -16, duration: 2500.ms, curve: Curves.easeInOut)
                        .rotate(begin: 0, end: 0.017, duration: 2500.ms),
              ),
            ),
        ],
      ),
    );
  }
}
