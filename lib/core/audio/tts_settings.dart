import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Jembatan ke pengaturan TTS perangkat (diimplementasikan di `MainActivity.kt`).
abstract final class TtsSettings {
  static const _channel = MethodChannel('claymo/tts_settings');

  /// Hanya Android yang bisa membuka layar unduh voice secara langsung.
  static bool get canOpen => !kIsWeb && Platform.isAndroid;

  /// Buka layar unduh data suara Google TTS (atau Play Store bila Google TTS
  /// belum terpasang, lalu pengaturan TTS sistem sebagai cadangan).
  static Future<bool> openIndonesianVoiceInstall() async {
    if (!canOpen) return false;
    try {
      return await _channel.invokeMethod<bool>('openVoiceInstall') ?? false;
    } catch (e) {
      debugPrint('TtsSettings: gagal membuka pengaturan TTS: $e');
      return false;
    }
  }
}
