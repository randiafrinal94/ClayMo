import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/app_language.dart';

class LanguageNotifier extends Notifier<AppLanguage> {
  static const _key = 'language';

  @override
  AppLanguage build() => AppLanguage.fromCode(ref.read(sharedPreferencesProvider).getString(_key));

  void select(AppLanguage language) {
    if (language == state) return;
    state = language;
    ref.read(sharedPreferencesProvider).setString(_key, language.code);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

/// Teks terlokalisasi untuk kode non-widget (mis. kalimat yang diucapkan TTS).
final l10nProvider = Provider<AppLocalizations>((ref) => lookupAppLocalizations(ref.watch(languageProvider).locale));
