import 'package:flutter/material.dart';

import '../audio/sfx_service.dart';
import '../theme/clay_colors.dart';
import 'clay_container.dart';
import 'clay_pressable.dart';

/// Tombol clay. Varian pil (label/emoji/ikon) dan bulat (hanya ikon).
class ClayButton extends StatelessWidget {
  const ClayButton({
    super.key,
    required this.onTap,
    this.label,
    this.icon,
    this.emoji,
    this.tone = ClayColors.pink,
    this.sound = Sfx.pop,
    this.semanticLabel,
    this.height = 56,
    this.fontSize = 20,
    this.expand = false,
  }) : assert(label != null || icon != null || emoji != null),
       circle = false;

  /// Tombol bulat berisi ikon saja (min 48dp).
  const ClayButton.icon({
    super.key,
    required this.onTap,
    required IconData this.icon,
    this.tone = ClayColors.blue,
    this.sound = Sfx.pop,
    this.semanticLabel,
    double size = 56,
  }) : label = null,
       emoji = null,
       height = size,
       fontSize = 20,
       expand = false,
       circle = true;

  final VoidCallback? onTap;
  final String? label;
  final IconData? icon;
  final String? emoji;
  final ClayTone tone;
  final Sfx? sound;
  final String? semanticLabel;
  final double height;
  final double fontSize;
  final bool expand;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final size = height < 48 ? 48.0 : height;
    return ClayPressable(
      onTap: onTap,
      sound: sound,
      semanticLabel: semanticLabel ?? label,
      builder: (context, pressed) {
        final lead = switch ((emoji, icon)) {
          (final e?, _) => Text(e, style: TextStyle(fontSize: fontSize + 2)),
          (_, final i?) => Icon(i, size: circle ? size * 0.5 : fontSize + 8, color: ClayColors.text),
          _ => null,
        };
        final content = circle
            ? Center(child: lead)
            : Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ?lead,
                  if (lead != null && label != null) const SizedBox(width: 8),
                  if (label != null)
                    Flexible(
                      child: Text(
                        label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: ClayColors.text),
                      ),
                    ),
                ],
              );

        return ClayContainer(
          tone: tone,
          width: circle ? size : null,
          height: size,
          radius: 999,
          pressed: pressed,
          padding: circle ? null : EdgeInsets.symmetric(horizontal: fontSize + 2),
          child: content,
        );
      },
    );
  }
}
