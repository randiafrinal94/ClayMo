import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/tts_service.dart';
import '../../../core/audio/tts_settings.dart';
import '../../../core/theme/clay_colors.dart';
import '../../../core/widgets/clay_button.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../l10n/app_localizations.dart';
import '../application/language_provider.dart';
import '../domain/app_language.dart';

/// Memastikan voice Bahasa Indonesia terpasang. Bila belum, tampilkan dialog
/// panduan untuk orang tua (sekali per sesi) dan cek ulang saat aplikasi
/// kembali dari Pengaturan.
class VoiceSetupGuard extends ConsumerStatefulWidget {
  const VoiceSetupGuard({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<VoiceSetupGuard> createState() => _VoiceSetupGuardState();
}

class _VoiceSetupGuardState extends ConsumerState<VoiceSetupGuard> {
  late final AppLifecycleListener _lifecycle;
  bool _prompted = false;
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_prompted || ref.read(languageProvider) != AppLanguage.id) return;
    final status = await ref.read(ttsServiceProvider).indonesianVoiceStatus();
    _missing = status == IndonesianVoiceStatus.missing;
    if (!_missing || _prompted || !mounted) return;
    _prompted = true;
    if (await showVoiceSetupDialog(context)) await TtsSettings.openIndonesianVoiceInstall();
  }

  /// Orang tua mungkin baru saja mengunduh voice di Pengaturan.
  Future<void> _onResume() async {
    if (!_missing) return;
    final status = await ref.read(ttsServiceProvider).recheckIndonesianVoice();
    _missing = status == IndonesianVoiceStatus.missing;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(languageProvider, (_, next) {
      if (next == AppLanguage.id) _check();
    });
    return widget.child;
  }
}

/// Dialog clay ramah orang tua. Mengembalikan `true` bila memilih "Buka Pengaturan".
Future<bool> showVoiceSetupDialog(BuildContext context) async {
  final opened = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: ClayColors.text.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, _, _) => const _VoiceSetupDialog(),
  );
  return opened ?? false;
}

class _VoiceSetupDialog extends StatelessWidget {
  const _VoiceSetupDialog();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canOpen = TtsSettings.canOpen;
    final isIos = !kIsWeb && Platform.isIOS;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child:
                ClayContainer(
                      tone: ClayColors.white,
                      radius: 32,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ClayContainer(
                            tone: ClayColors.yellow,
                            width: 72,
                            height: 72,
                            radius: 26,
                            child: Center(child: Text('🔈', style: TextStyle(fontSize: 36))),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.voiceSetupTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ClayColors.text),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isIos ? l.voiceSetupBodyIos : l.voiceSetupBody,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, height: 1.35, color: ClayColors.textSoft),
                          ),
                          const SizedBox(height: 22),
                          if (canOpen) ...[
                            ClayButton(
                              label: l.voiceSetupOpen,
                              emoji: '⚙️',
                              tone: ClayColors.mint,
                              expand: true,
                              onTap: () => Navigator.of(context).pop(true),
                            ),
                            const SizedBox(height: 12),
                          ],
                          ClayButton(
                            label: canOpen ? l.voiceSetupLater : l.voiceSetupOk,
                            tone: ClayColors.lav,
                            expand: true,
                            onTap: () => Navigator.of(context).pop(false),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 180.ms)
                    .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 420.ms, curve: clayBounce),
          ),
        ),
      ),
    );
  }
}
