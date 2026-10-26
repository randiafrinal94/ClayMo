# Technical Specification

## Core Stack
- **Framework**: Flutter (Dart)
- **State Management**: `flutter_riverpod` (v2.x+)
- **Audio & Speech**:
  - `flutter_tts`: Sintesis suara untuk membaca alfabet, suku kata, dan kata.
  - `audioplayers`: Pemutaran efek suara interaksi (pop, click, star, cheer).
- **Animasi & Efek**:
  - `flutter_animate`: Micro-animations dan bounce effects.
  - `confetti`: Efek perayaan kemenangan.
- **Lokalisasi**: `flutter_localizations`, `intl` (file `app_id.arb` dan `app_en.arb`).

## Local Storage & Database
- **SQLite Engine**: `sqflite` (atau `drift` untuk type-safe ORM & reactive stream).
- **Path Provider**: `path_provider` dan `path` (untuk mengelola direktori file database di Android/iOS).
- **Use Case**:
  - Menyimpan koleksi stiker & status unlock.
  - Tracking progres kata yang sudah dipelajari per bahasa (ID & EN).
  - Riwayat skor kuis dan akumulasi bintang.
  - Multi-profile anak (opsional, jika 1 HP dipakai lebih dari 1 anak).

## Bilingual Audio Handling
- **Bahasa Indonesia (`id_ID`)**:
  - Filter voice native Indonesia (`id-ID`).
  - Kamus fonetik pra-proses ejaan taling (`Be` -> `"bee "`, `Ce` -> `"cee "`, `De` -> `"dee "`) guna menghindari vokal pepet dan hembusan desah.
  - Rate: ~0.45 - 0.50 (skala flutter_tts), Pitch: 1.0.
- **English (`en_US`)**:
  - Filter voice US/UK child/friendly tone (`en-US`).
  - Fonik pelafalan per huruf (contoh: A is for Apple, B sounds like /b/).
  - Rate: ~0.45 - 0.50, Pitch: 1.05.

## Project Structure (Feature-First)

## Dependencies
- `flutter_animate: ^4.5.0` (Untuk staggered drop, scale bounce, dan continuous jumping dots di splash screen).
- `flutter_native_splash: ^2.4.0` (Opsional, untuk menangani transisi layar putih bawaan OS Android/iOS sebelum Flutter engine selesai warming up).