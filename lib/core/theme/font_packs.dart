enum FontPackId {
  bubbly,
  handwritten,
  retroArcade,
  elegant,
  comic,
  clean,
}

class FontPack {
  const FontPack({
    required this.id,
    required this.label,
    required this.displayFamily,
    required this.headingFamily,
    required this.bodyFamily,
    required this.handFamily,
    required this.numberFamily,
  });

  final FontPackId id;
  final String label;
  final String displayFamily;
  final String headingFamily;
  final String bodyFamily;
  final String handFamily;
  final String numberFamily;

  /// Google Fonts family names matching SRD §6.3 (OFL).
  static const catalogue = <FontPack>[
    FontPack(
      id: FontPackId.bubbly,
      label: 'Bubbly',
      displayFamily: 'Bagel Fat One',
      headingFamily: 'Fredoka',
      bodyFamily: 'Nunito',
      handFamily: 'Caveat',
      numberFamily: 'Fredoka',
    ),
    FontPack(
      id: FontPackId.handwritten,
      label: 'Handwritten',
      displayFamily: 'Caveat',
      headingFamily: 'Patrick Hand',
      bodyFamily: 'Nunito',
      handFamily: 'Gochi Hand',
      numberFamily: 'Fredoka',
    ),
    FontPack(
      id: FontPackId.retroArcade,
      label: 'Retro Arcade',
      displayFamily: 'Press Start 2P',
      headingFamily: 'Fredoka',
      bodyFamily: 'Nunito',
      handFamily: 'Caveat',
      numberFamily: 'Rubik Mono One',
    ),
    FontPack(
      id: FontPackId.elegant,
      label: 'Elegant',
      displayFamily: 'Playfair Display',
      headingFamily: 'Playfair Display',
      bodyFamily: 'Nunito',
      handFamily: 'Caveat',
      numberFamily: 'Fredoka',
    ),
    FontPack(
      id: FontPackId.comic,
      label: 'Comic',
      displayFamily: 'Bangers',
      headingFamily: 'Lilita One',
      bodyFamily: 'Nunito',
      handFamily: 'Caveat',
      numberFamily: 'Fredoka',
    ),
    FontPack(
      id: FontPackId.clean,
      label: 'Clean',
      displayFamily: 'Fredoka',
      headingFamily: 'DM Sans',
      bodyFamily: 'DM Sans',
      handFamily: 'Caveat',
      numberFamily: 'DM Sans',
    ),
  ];

  static FontPack byId(FontPackId id) =>
      catalogue.firstWhere((p) => p.id == id);
}
