import 'package:flutter/material.dart';

import '../audio/sfx_service.dart';
import '../theme/clay_colors.dart';
import 'clay_container.dart';
import 'clay_pressable.dart';

/// Kartu clay. Jika [onTap] diisi, kartu menjadi tombol kenyal.
class ClayCard extends StatelessWidget {
  const ClayCard({
    super.key,
    required this.child,
    this.tone = ClayColors.white,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = 28,
    this.width,
    this.height,
    this.inset = false,
    this.sound = Sfx.pop,
    this.semanticLabel,
  });

  final Widget child;
  final ClayTone tone;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double? width;
  final double? height;
  final bool inset;
  final Sfx? sound;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return ClayContainer(
        tone: tone,
        padding: padding,
        radius: radius,
        width: width,
        height: height,
        inset: inset,
        child: child,
      );
    }
    return ClayPressable(
      onTap: onTap,
      sound: sound,
      semanticLabel: semanticLabel,
      builder: (context, pressed) => ClayContainer(
        tone: tone,
        padding: padding,
        radius: radius,
        width: width,
        height: height,
        inset: inset,
        pressed: pressed,
        child: child,
      ),
    );
  }
}
