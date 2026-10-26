import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'clay_container.dart';

/// Kartu putih besar berisi emoji gambar soal (mengeja & tebak gambar).
/// Emoji muncul membal lalu bergoyang pelan terus-menerus.
class PictureCard extends StatelessWidget {
  const PictureCard({super.key, required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 170,
      child: ClayContainer(
        child: Center(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child:
                  Text(
                        emoji,
                        style: TextStyle(
                          fontSize: 104,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF463C78).withValues(alpha: 0.22),
                              offset: const Offset(4, 7),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      )
                      .animate(key: ValueKey(emoji))
                      .scale(begin: const Offset(0.4, 0.4), duration: 600.ms, curve: Curves.elasticOut)
                      .then()
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .rotate(begin: 0, end: -0.022, duration: 1500.ms, curve: Curves.easeInOut),
            ),
          ),
        ),
      ),
    );
  }
}
