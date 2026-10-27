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

## Versioning & rilis APK (SemVer otomatis)

Versi `X.Y.Z+N` di `pubspec.yaml` ditentukan dari [Conventional Commits](https://www.conventionalcommits.org)
sejak tag `vX.Y.Z` terakhir:

| Commit | Bump | Contoh |
|---|---|---|
| `feat!:` / `fix!:` / footer `BREAKING CHANGE:` | MAJOR | 1.2.3 → 2.0.0 |
| `feat:` | MINOR | 1.2.3 → 1.3.0 |
| `fix:` `perf:` `refactor:` | PATCH | 1.2.3 → 1.2.4 |
| `docs:` `chore:` `style:` `test:` `ci:` `build:` | tidak naik | |

Build number `N` = `git rev-list --count HEAD` (tidak pernah <= build yang sudah ada di pubspec).

**Lokal** (`dart run tool/version_bumper.dart --help` untuk opsi; `.\tool\build_apk.ps1` memanggilnya
otomatis, matikan dengan `-NoBump`):

```bash
dart run tool/version_bumper.dart --dry-run   # lihat hasil tanpa mengubah apa pun
dart run tool/version_bumper.dart --tag       # tulis pubspec.yaml + buat tag lokal vX.Y.Z
```

**CI** (`.github/workflows/build_apk.yml` + `.releaserc.json`): push ke `main` → semantic-release
menghitung versi, `tool/ci_build_apk.sh` menulis pubspec di runner lalu menjalankan
`flutter build apk --release --build-name=X.Y.Z --build-number=N`, membuat tag `vX.Y.Z` dan
GitHub Release berisi `Claymo-vX.Y.Z-release.apk`. Pubspec tidak di-commit balik; tag adalah sumber kebenaran.

Setup sekali:

1. Buat tag awal supaya rilis pertama tidak melompat ke 1.0.0 (semantic-release default):
   `git tag v0.1.0 <commit> && git push origin v0.1.0`.
2. Secret repo untuk tanda tangan rilis (tanpanya APK memakai debug key): `ANDROID_KEYSTORE_BASE64`
   (`base64 -w0 android/claymo-release.jks`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
