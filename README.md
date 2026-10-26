# Claymo

Aplikasi edukasi interaktif (Flutter) untuk anak 3–7 tahun: mengeja, fonik, alfabet, dan kuis
tebak gambar dalam **Bahasa Indonesia** dan **English**, dengan visual Claymorphism 3D.

## Menjalankan

```bash
flutter pub get
flutter gen-l10n          # hanya jika mengubah file .arb
flutter run               # Android / iOS
flutter test
```

Efek suara (`assets/sounds/*.wav`) dihasilkan oleh `dart run tool/generate_sounds.dart`
dan boleh diganti dengan rekaman sendiri selama namanya sama.

## Struktur (feature-first + Riverpod)

```
lib/
  core/
    audio/      tts_service, sfx_service, phonetics (normalisasi e-taling)
    theme/      palet warna & ThemeData
    widgets/    ClayContainer, ClayButton, ClayCard, ClayPressable, efek (konfeti, bintang, shake)
    storage/    SharedPreferences provider
  data/         word_bank (kata, alfabet, suku kata, keluarga kata fonik)
  features/
    language/   toggle ID/EN + provider (instan, tersimpan)
    home/  spelling/  phonics/  quiz/  progress/  shell/
  l10n/         app_id.arb, app_en.arb (sumber teks UI)
```

## Catatan audio

- ID: locale `id-ID`, rate 0.46 (0.38 untuk tombol "dengarkan"); huruf/suku kata berakhiran E
  dipetakan ke e-taling (`Be` → `"bee "`), lihat `core/audio/phonetics.dart`.
- EN: locale `en-US`, pitch 1.1, rate 0.47.
- Kualitas suara bergantung pada mesin TTS perangkat. Pasang voice **Indonesian** / **English (US)**
  di pengaturan TTS Android (Google Speech Services) bila suara terdengar salah bahasa.
