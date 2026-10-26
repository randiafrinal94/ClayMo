import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/sfx_service.dart';
import '../../../core/audio/tts_service.dart';
import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../core/widgets/clay_pressable.dart';
import '../application/language_provider.dart';
import '../domain/app_language.dart';

/// Toggle ID / EN di bilah atas. Perubahan langsung memengaruhi teks UI
/// (lewat `MaterialApp.locale`), suara TTS, dan daftar kata.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  static const double _width = 112;
  static const double _height = 46;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);

    return Semantics(
      label: ref.watch(l10nProvider).languageLabel,
      child: ClayContainer(
        inset: true,
        width: _width,
        height: _height,
        radius: _height / 2,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 450),
                curve: clayBounce,
                alignment: current == AppLanguage.id ? Alignment.centerLeft : Alignment.centerRight,
                child: const FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: ClayContainer(tone: ClayColors.yellow, radius: 999, depth: 0.5),
                ),
              ),
              Row(
                children: [
                  for (final language in AppLanguage.values)
                    Expanded(
                      child: _Option(language: language, selected: language == current),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends ConsumerWidget {
  const _Option({required this.language, required this.selected});

  final AppLanguage language;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClayPressable(
      pressedScale: const Offset(0.88, 0.84),
      sound: null,
      semanticLabel: language.label,
      onTap: () {
        if (selected) {
          ref.read(sfxServiceProvider).play(Sfx.tap);
          return;
        }
        ref.read(sfxServiceProvider).play(Sfx.pop);
        ref.read(languageProvider.notifier).select(language);
        // Suara TTS langsung ikut berganti: sapaan dalam bahasa baru.
        ref.read(ttsServiceProvider).speakPhrase(ref.read(l10nProvider).switchGreeting, language: language);
      },
      builder: (context, _) => Center(
        child: Text(
          '${language.flag} ${language.label}',
          maxLines: 1,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? ClayColors.text : ClayColors.textSoft,
          ),
        ),
      ),
    );
  }
}
