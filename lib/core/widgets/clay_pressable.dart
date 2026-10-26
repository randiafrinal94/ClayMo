import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/sfx_service.dart';
import '../theme/clay_colors.dart';

/// Perilaku tekan kenyal ala desain acuan: gepeng (lebih sempit & pendek) saat
/// disentuh, lalu membal dengan kurva overshoot saat dilepas. Memutar efek
/// suara + haptik pada setiap tap.
class ClayPressable extends ConsumerStatefulWidget {
  const ClayPressable({
    super.key,
    required this.builder,
    this.onTap,
    this.sound = Sfx.pop,
    this.pressedScale = const Offset(0.9, 0.84),
    this.semanticLabel,
  });

  /// `pressed` dipakai untuk membalik bayangan clay saat ditekan.
  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback? onTap;

  /// null = tanpa suara (mis. widget yang memutar suara sendiri).
  final Sfx? sound;

  /// Skala (x, y) saat tertekan.
  final Offset pressedScale;
  final String? semanticLabel;

  @override
  ConsumerState<ClayPressable> createState() => _ClayPressableState();
}

class _ClayPressableState extends ConsumerState<ClayPressable> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!_enabled) return;
    final sound = widget.sound;
    if (sound != null) ref.read(sfxServiceProvider).play(sound);
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _handleTap,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(end: _pressed ? widget.pressedScale : const Offset(1, 1)),
          duration: Duration(milliseconds: _pressed ? 90 : 320),
          curve: _pressed ? Curves.easeOut : clayBounce,
          builder: (context, scale, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(scale.dx, scale.dy, 1),
            child: child,
          ),
          child: widget.builder(context, _pressed),
        ),
      ),
    );
  }
}
