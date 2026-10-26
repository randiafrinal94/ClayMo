import 'package:flutter/material.dart';

import '../theme/clay_colors.dart';

/// Judul layar (h2 pada desain acuan).
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: ClayColors.text),
      ),
    );
  }
}

/// Teks bantu kecil di bawah judul (progres / petunjuk).
class ScreenHint extends StatelessWidget {
  const ScreenHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ClayColors.textSoft),
      ),
    );
  }
}
