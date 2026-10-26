# Database Schema Specification (SQLite)

Dokumen ini mendefinisikan skema basis data lokal SQLite untuk aplikasi **Claymo** menggunakan library seperti `sqflite` atau `drift`. Sistem dirancang *offline-first* untuk melacak progres belajar, koleksi hadiah, dan pengaturan pengguna.

---

## 1. Entity Relationship Overview

- **users (1) ───< (N) word_progress**: Satu profil anak memiliki banyak catatan progres kata.
- **users (1) ───< (N) user_stickers**: Melacak stiker mana saja yang sudah dibuka oleh masing-masing anak.
- **stickers (1) ───< (N) user_stickers**: Relasi *many-to-many* antara profil dan master data stiker.
- **users (1) ───< (N) quiz_history**: Riwayat sesi kuis tebak gambar beserta skor bintang.

---

## 2. Table Definitions (DDL)

### A. Tabel `users`
Menyimpan profil anak, avatar clay pilihan, saldo bintang aktif, dan preferensi bahasa default.

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    avatar_id TEXT NOT NULL DEFAULT 'avatar_bear',
    total_stars INTEGER NOT NULL DEFAULT 0,
    preferred_language TEXT NOT NULL DEFAULT 'id' CHECK (preferred_language IN ('id', 'en')),
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);