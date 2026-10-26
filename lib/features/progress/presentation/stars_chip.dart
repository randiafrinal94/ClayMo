import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../core/widgets/effects.dart';
import '../../language/application/language_provider.dart';
import '../application/progress_provider.dart';

class StarsChip extends ConsumerWidget {
  const StarsChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stars = ref.watch(starsProvider);
    return Semantics(
      label: '${ref.watch(l10nProvider).starsLabel}: $stars',
      excludeSemantics: true,
      child: SquishOnTrigger(
        trigger: stars,
        child: ClayContainer(
          tone: ClayColors.yellow,
          height: 46,
          radius: 999,
          padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Text(
                '$stars',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ClayColors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
