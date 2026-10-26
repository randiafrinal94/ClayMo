# Design System: Claymorphism for Kids (Claymo)

## Referensi Visual
Tampilan mengikuti prototipe `KataPintar/index.html` (pastel rata, bayangan ungu lembut, font Fredoka, navigasi bawah 5 tab).

## Color Palette (Soft Pastels)
- **Blue** `#A8D8FF` · **Pink** `#FFC2D9` · **Mint** `#B5ECD2` · **Yellow** `#FFE9A0` · **Lav** `#D6C7FF` · **Peach** `#FFCFB0`
- **Latar halaman**: gradien `#D9EDFF` → `#EEF7FF` → `#FFF3F8` (atas ke bawah). Layar lebar: bingkai ponsel di atas latar polkadot `#FFD9E8`.
- **Teks**: ink `#4A4466`, teks sekunder `#7D7799`. Teks di atas clay selalu ink (bukan putih).
- **Aksen**: pink ink `#FF7AA8`, blue ink `#5AA9F0`; benar `#8FE3B4`, salah `#FFA3A3`.
- **Font**: Fredoka (dibundel di `assets/fonts/`), bobot 400–700.

## Clay Anatomy & Shadows
Semua komponen dibentuk oleh `ClayContainer` dengan warna rata + lapisan bayangan:
1. **Drop shadow**: ink `#5A508C` α.22 offset (8,10) blur 18, dan α.14 offset (3,4) blur 6.
2. **Glow putih**: α.85 offset (-5,-5) blur 12.
3. **Inner highlight**: putih α.85 offset (5,5) blur 9; **inner shadow**: α.14 offset (-6,-8) blur 12.
4. **Radius**: 28 (kartu), 20–22 (ubin/tab), 999 (pil/tombol).
5. **Inset (slot cekung)**: lavender `rgba(190,175,230,.28)` + inner shadow gelap kiri-atas.

## Micro-Interactions & Motion
- **Squish on Press**: Saat disentuh, scale `(0.9, 0.84)` (lebih sempit & pendek), bayangan luar mengecil dan inner shadow berbalik gelap.
- **Release Bounce**: Kurva `cubic-bezier(.34,1.9,.5,1)` (`clayBounce`) saat dilepas.
- **Pindah tab**: isi masuk dengan fade + naik + scale `0.96→1` (450ms, `clayBounce`).

## Splash Screen Experience
- **Entry Sensation**: Maskot dan tipografi muncul dengan akselerasi pegas (*elastic spring entrance*) untuk menciptakan kesan balon/tanah liat yang jatuh ke kasur empuk.
- **Micro Audio**: Mainkan chime bernada ceria (durasi 1-1.5 detik) yang langsung membangun ketertarikan anak.
- **Dynamic Loading**: Ganti spinner loading konvensional dengan 3 keping *Jumping Clay Spheres* berwarna pastel yang bergerak secara ritmis.