/// Master data stiker. Terbuka otomatis saat total bintang mencapai [requiredStars].
class Sticker {
  const Sticker(this.id, this.emoji, this.nameId, this.nameEn, this.requiredStars);

  final String id;
  final String emoji;
  final String nameId;
  final String nameEn;
  final int requiredStars;

  Map<String, Object?> toRow() => {
    'id': id,
    'emoji': emoji,
    'name_id': nameId,
    'name_en': nameEn,
    'required_stars': requiredStars,
  };
}

abstract final class StickerCatalog {
  /// Sama dengan album pada desain acuan Kata Pintar (15 stiker, 1–72 bintang).
  static const all = [
    Sticker('sticker_unicorn', '🦄', 'Unicorn', 'Unicorn', 1),
    Sticker('sticker_dog', '🐶', 'Anjing', 'Dog', 3),
    Sticker('sticker_lion', '🦁', 'Singa', 'Lion', 5),
    Sticker('sticker_panda', '🐼', 'Panda', 'Panda', 8),
    Sticker('sticker_frog', '🐸', 'Katak', 'Frog', 11),
    Sticker('sticker_butterfly', '🦋', 'Kupu-kupu', 'Butterfly', 15),
    Sticker('sticker_octopus', '🐙', 'Gurita', 'Octopus', 19),
    Sticker('sticker_whale', '🐳', 'Paus', 'Whale', 24),
    Sticker('sticker_fox', '🦊', 'Rubah', 'Fox', 29),
    Sticker('sticker_tiger', '🐯', 'Harimau', 'Tiger', 35),
    Sticker('sticker_koala', '🐨', 'Koala', 'Koala', 41),
    Sticker('sticker_monkey', '🐵', 'Monyet', 'Monkey', 48),
    Sticker('sticker_dino', '🦖', 'Dino', 'Dino', 55),
    Sticker('sticker_rocket', '🚀', 'Roket', 'Rocket', 63),
    Sticker('sticker_rainbow', '🌈', 'Pelangi', 'Rainbow', 72),
  ];
}
