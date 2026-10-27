package com.claymo.claymo

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "claymo/tts_settings").setMethodCallHandler { call, result ->
            when (call.method) {
                "openVoiceInstall" -> result.success(openVoiceInstall())
                else -> result.notImplemented()
            }
        }
    }

    /// Arahkan orang tua ke tempat mengunduh voice Bahasa Indonesia.
    private fun openVoiceInstall(): Boolean {
        val candidates = buildList {
            if (isInstalled(GOOGLE_TTS)) {
                add(Intent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA).setPackage(GOOGLE_TTS))
            } else {
                add(Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$GOOGLE_TTS")))
                add(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$GOOGLE_TTS")))
            }
            add(Intent("com.android.settings.TTS_SETTINGS"))
            add(Intent(Settings.ACTION_SETTINGS))
        }
        for (intent in candidates) {
            try {
                startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                return true
            } catch (e: ActivityNotFoundException) {
                // Coba kandidat berikutnya.
            }
        }
        return false
    }

    private fun isInstalled(packageName: String): Boolean = try {
        packageManager.getPackageInfo(packageName, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    private companion object {
        const val GOOGLE_TTS = "com.google.android.tts"
    }
}
