import 'package:flutter/material.dart';

import '../theme/clay_colors.dart';

/// Dasar semua komponen Claymorphism, mengikuti desain acuan Kata Pintar:
/// warna pastel rata + drop shadow lembut kanan-bawah + glow putih kiri-atas
/// + inner highlight/inner shadow yang membuat bentuknya "gembung".
///
/// [pressed] = tertekan (bayangan luar mengecil, inner shadow berbalik gelap).
/// [inset] = cekung (slot penampung).
class ClayContainer extends StatelessWidget {
  const ClayContainer({
    super.key,
    this.tone = ClayColors.white,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.alignment,
    this.radius = 28,
    this.depth = 1,
    this.pressed = false,
    this.inset = false,
    this.flat = false,
  });

  final ClayTone tone;
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  /// Radius sudut. Nilai besar (mis. 999) menghasilkan pil/lingkaran.
  final double radius;

  /// 0..1.5 — skala tinggi "bukit" tanah liat (elemen dekoratif kecil memakai < 1).
  final double depth;

  final bool pressed;
  final bool inset;

  /// true = tanpa bayangan luar (hanya inner shadow), mis. tab nav yang aktif.
  final bool flat;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: pressed ? 1 : 0),
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      builder: (context, p, _) {
        Widget content = child ?? const SizedBox.shrink();
        if (padding != null) content = Padding(padding: padding!, child: content);
        if (alignment != null) content = Align(alignment: alignment!, child: content);

        return SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: inset ? _insetColor : tone.base,
              boxShadow: inset || flat ? _insetOuter : _raisedOuter(p),
            ),
            child: CustomPaint(
              painter: _InnerShadowPainter(radius: radius, shadows: inset ? _insetInner : _raisedInner(p)),
              child: content,
            ),
          ),
        );
      },
    );
  }

  static const _insetColor = Color.fromRGBO(190, 175, 230, 0.28);

  static const _insetOuter = <BoxShadow>[];

  static const _insetInner = [
    _Inner(Color.fromRGBO(80, 60, 140, 0.2), Offset(5, 6), 10),
    _Inner(Color.fromRGBO(255, 255, 255, 0.8), Offset(-4, -4), 8),
  ];

  List<BoxShadow> _raisedOuter(double p) {
    final d = depth;
    final up = [
      BoxShadow(color: ClayColors.ink.withValues(alpha: 0.22), offset: Offset(8 * d, 10 * d), blurRadius: 18 * d),
      BoxShadow(color: ClayColors.ink.withValues(alpha: 0.14), offset: Offset(3 * d, 4 * d), blurRadius: 6 * d),
      BoxShadow(color: Colors.white.withValues(alpha: 0.85), offset: Offset(-5 * d, -5 * d), blurRadius: 12 * d),
    ];
    if (p == 0) return up;
    final down = [BoxShadow(color: ClayColors.ink.withValues(alpha: 0.2), offset: const Offset(3, 4), blurRadius: 8)];
    return BoxShadow.lerpList(up, down, p)!;
  }

  /// Empat lapis inner shadow; dua untuk keadaan normal, dua untuk tertekan.
  List<_Inner> _raisedInner(double p) {
    final d = depth;
    final up = 1 - p;
    return [
      _Inner(Colors.white.withValues(alpha: 0.85 * up), Offset(5 * d, 5 * d), 9),
      _Inner(const Color(0xFF463C78).withValues(alpha: 0.14 * up), Offset(-6 * d, -8 * d), 12),
      _Inner(const Color(0xFF463C78).withValues(alpha: 0.16 * p), const Offset(6, 7), 12),
      _Inner(Colors.white.withValues(alpha: 0.7 * p), const Offset(-3, -3), 8),
    ];
  }
}

class _Inner {
  const _Inner(this.color, this.offset, this.blur);
  final Color color;
  final Offset offset;
  final double blur;
}

/// Menggambar inner shadow: area di luar rrect digeser lalu di-blur dan
/// di-clip ke dalam rrect.
class _InnerShadowPainter extends CustomPainter {
  const _InnerShadowPainter({required this.radius, required this.shadows});

  final double radius;
  final List<_Inner> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final r = radius.clamp(0, size.shortestSide / 2).toDouble();
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));

    canvas.save();
    canvas.clipRRect(rrect);
    for (final s in shadows) {
      if (s.color.a == 0) continue;
      final path = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rect.inflate(60 + s.blur))
        ..addRRect(rrect);
      canvas.save();
      canvas.translate(s.offset.dx, s.offset.dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blur / 2),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InnerShadowPainter old) =>
      old.radius != radius || old.shadows.length != shadows.length || _differs(old);

  bool _differs(_InnerShadowPainter old) {
    for (var i = 0; i < shadows.length; i++) {
      final a = shadows[i];
      final b = old.shadows[i];
      if (a.color != b.color || a.offset != b.offset || a.blur != b.blur) return true;
    }
    return false;
  }
}
