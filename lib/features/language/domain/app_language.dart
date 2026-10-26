import 'package:flutter/widgets.dart';

enum AppLanguage {
  id(code: 'id', label: 'ID', flag: '🇮🇩', ttsLocale: 'id-ID'),
  en(code: 'en', label: 'EN', flag: '🇺🇸', ttsLocale: 'en-US');

  const AppLanguage({required this.code, required this.label, required this.flag, required this.ttsLocale});

  final String code;
  final String label;
  final String flag;
  final String ttsLocale;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.id);
}
