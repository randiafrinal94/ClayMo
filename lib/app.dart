import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/audio/sfx_service.dart';
import 'core/audio/tts_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/clay_background.dart';
import 'features/language/application/language_provider.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'l10n/app_localizations.dart';

class ClaymoApp extends ConsumerStatefulWidget {
  const ClaymoApp({super.key});

  @override
  ConsumerState<ClaymoApp> createState() => _ClaymoAppState();
}

class _ClaymoAppState extends ConsumerState<ClaymoApp> {
  @override
  void initState() {
    super.initState();
    // Pemanasan audio agar tap pertama tidak terasa lag.
    ref.read(sfxServiceProvider).preload();
    ref.read(ttsServiceProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    // Ganti bahasa => locale berubah => seluruh UI ter-rebuild seketika.
    final language = ref.watch(languageProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) => ClayBackground(child: child ?? const SizedBox.shrink()),
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
