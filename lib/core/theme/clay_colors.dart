import 'package:flutter/material.dart';

/// Satu "warna tanah liat" pastel. Bayangan & highlight dibuat seragam oleh
/// [ClayContainer], jadi cukup warna dasar yang berbeda.
class ClayTone {
  const ClayTone(this.base);

  final Color base;
}

abstract final class ClayColors {
  static const text = Color(0xFF4A4466);
  static const textSoft = Color(0xFF7D7799);

  /// Warna bayangan clay (ungu kebiruan lembut, bukan hitam).
  static const ink = Color(0xFF5A508C);

  /// Aksen teks logo & sorotan huruf.
  static const pinkInk = Color(0xFFFF7AA8);
  static const blueInk = Color(0xFF5AA9F0);

  static const good = Color(0xFF8FE3B4);
  static const bad = Color(0xFFFFA3A3);

  static const blue = ClayTone(Color(0xFFA8D8FF));
  static const pink = ClayTone(Color(0xFFFFC2D9));
  static const mint = ClayTone(Color(0xFFB5ECD2));
  static const yellow = ClayTone(Color(0xFFFFE9A0));
  static const lav = ClayTone(Color(0xFFD6C7FF));
  static const peach = ClayTone(Color(0xFFFFCFB0));

  /// Permukaan putih (kartu gambar, kartu detail, nav).
  static const white = ClayTone(Color(0xFFFFFFFF));

  /// Tab / sel yang tidak aktif.
  static const tabIdle = ClayTone(Color(0xFFE9E4FB));

  /// Stiker yang masih terkunci.
  static const locked = ClayTone(Color(0xFFE4E0F0));

  static const rainbow = [blue, pink, mint, yellow, lav, peach];

  static ClayTone rainbowAt(int index) => rainbow[index % rainbow.length];

  /// Latar halaman: gradien biru langit -> putih -> merah muda muda.
  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD9EDFF), Color(0xFFEEF7FF), Color(0xFFFFF3F8)],
    stops: [0, 0.45, 1],
  );

  static const confetti = [
    Color(0xFFFF7AA8),
    Color(0xFF5AA9F0),
    Color(0xFFFFD04D),
    Color(0xFF6FDCA3),
    Color(0xFFA78BFA),
    Color(0xFFFF9A5C),
  ];
}

/// Kurva membal ala `cubic-bezier(.34,1.9,.5,1)` pada desain acuan.
const clayBounce = Cubic(0.34, 1.9, 0.5, 1);
