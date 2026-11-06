import 'package:flutter/material.dart';

/// Sticker Pop colour tokens from SRD §6.2.
abstract final class WishlistColors {
  static const wishViolet = Color(0xFF6C3CE0);
  static const popPink = Color(0xFFE4357E);
  static const sunnyGold = Color(0xFFF2B705);
  static const mintGreen = Color(0xFF0E9F6E);
  static const skyBlue = Color(0xFF4DB8FF);
  static const midnightInk = Color(0xFF1B1B2F);
  static const paperCream = Color(0xFFFFF9F0);
  static const cloudLilac = Color(0xFFF6F2FF);

  static const outline = midnightInk;
  static const cardRadius = 24.0;
  static const chipRadius = 16.0;
  static const screenPadding = 20.0;
  static const outlineWidth = 2.5;
  static const hardShadow = Offset(4, 4);
}

enum WishlistThemeId {
  light,
  dark,
  amoled,
  sunset,
  ocean,
  candy,
  forest,
  midnightParty,
}

class WishlistThemePalette {
  const WishlistThemePalette({
    required this.id,
    required this.label,
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.onBackground,
    required this.brightness,
  });

  final WishlistThemeId id;
  final String label;
  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color onBackground;
  final Brightness brightness;

  static const catalogue = <WishlistThemePalette>[
    WishlistThemePalette(
      id: WishlistThemeId.light,
      label: 'Paper Cream',
      primary: WishlistColors.wishViolet,
      accent: WishlistColors.popPink,
      background: WishlistColors.paperCream,
      surface: WishlistColors.cloudLilac,
      onBackground: WishlistColors.midnightInk,
      brightness: Brightness.light,
    ),
    WishlistThemePalette(
      id: WishlistThemeId.dark,
      label: 'Midnight',
      primary: Color(0xFF9B7BFF),
      accent: WishlistColors.popPink,
      background: WishlistColors.midnightInk,
      surface: Color(0xFF2A2A45),
      onBackground: WishlistColors.paperCream,
      brightness: Brightness.dark,
    ),
    WishlistThemePalette(
      id: WishlistThemeId.amoled,
      label: 'AMOLED Black',
      primary: Color(0xFFB794FF),
      accent: WishlistColors.sunnyGold,
      background: Color(0xFF000000),
      surface: Color(0xFF121212),
      onBackground: Color(0xFFF5F5F5),
      brightness: Brightness.dark,
    ),
    WishlistThemePalette(
      id: WishlistThemeId.sunset,
      label: 'Accra Sunset',
      primary: Color(0xFFE85D04),
      accent: Color(0xFFFFBA08),
      background: Color(0xFFFFF3E6),
      surface: Color(0xFFFFE0B8),
      onBackground: Color(0xFF2D1B0E),
      brightness: Brightness.light,
    ),
    WishlistThemePalette(
      id: WishlistThemeId.ocean,
      label: 'Cape Coast',
      primary: Color(0xFF0077B6),
      accent: Color(0xFF00B4D8),
      background: Color(0xFFE8F7FC),
      surface: Color(0xFFCAF0F8),
      onBackground: Color(0xFF023E8A),
      brightness: Brightness.light,
    ),
    WishlistThemePalette(
      id: WishlistThemeId.candy,
      label: 'Candy Pop',
      primary: Color(0xFFFF4D6D),
      accent: Color(0xFFC77DFF),
      background: Color(0xFFFFF0F5),
      surface: Color(0xFFFFD6E7),
      onBackground: Color(0xFF3D0C2E),
      brightness: Brightness.light,
    ),
    WishlistThemePalette(
      id: WishlistThemeId.forest,
      label: 'Kakum Green',
      primary: Color(0xFF1B7A4A),
      accent: Color(0xFF3DDC97),
      background: Color(0xFFF4FFF8),
      surface: Color(0xFFE3F7EA),
      onBackground: Color(0xFF123528),
      brightness: Brightness.light,
    ),
    WishlistThemePalette(
      id: WishlistThemeId.midnightParty,
      label: 'Midnight Party',
      primary: Color(0xFFFF006E),
      accent: Color(0xFF8338EC),
      background: Color(0xFF10002B),
      surface: Color(0xFF240046),
      onBackground: Color(0xFFE0AAFF),
      brightness: Brightness.dark,
    ),
  ];

  static WishlistThemePalette byId(WishlistThemeId id) =>
      catalogue.firstWhere((p) => p.id == id);
}
