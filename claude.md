# Claymo - Project Context & Rules

## Project Overview
Claymo adalah aplikasi edukasi mobile interaktif untuk anak-anak usia dini (3-7 tahun) yang berfokus pada pembelajaran membaca, fonik, alfabet, dan pengejaan dalam dua bahasa (Bahasa Indonesia & English). Aplikasi dibangun menggunakan Flutter dengan estetika visual **Claymorphism** 3D yang empuk, ramah anak, dan penuh mikro-interaksi taktil.

## Core Directives
- **Architecture**: Clean Architecture / Feature-First dengan state management Riverpod.
- **Audio First**: Pembelajaran fonik mengandalkan Text-to-Speech (TTS) bilingual native dan pre-recorded/synthesized sound effects untuk interaksi taktil.
- **Visual Integrity**: Seluruh komponen interaktif wajib mengikuti aturan Claymorphism (inner shadow + outer soft shadow + sudut bulat tebal).
- **Internationalization (i18n)**: Mendukung pengalihan bahasa instan (ID <-> EN) tanpa reload aplikasi.

## Code Conventions
- Gunakan Flutter versi stabil terbaru.
- Pisahkan UI styling ke dalam reusable clay widgets (`ClayContainer`, `ClayButton`, `ClayCard`).
- Hindari hardcoded strings; seluruh teks wajib menggunakan sistem lokalisasi Flutter (`flutter_localizations` & `.arb` files).
- Pastikan semua interaksi tombol memiliki audio feedback dan scale/bounce animation.