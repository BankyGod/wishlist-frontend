import 'package:flutter/material.dart';

import 'font_packs.dart';
import 'wishlist_colors.dart';

/// Palette + font pack carried on [ThemeData] so any widget can theme itself.
@immutable
class WishlistThemeTokens extends ThemeExtension<WishlistThemeTokens> {
  const WishlistThemeTokens({
    required this.palette,
    required this.fontPack,
  });

  final WishlistThemePalette palette;
  final FontPack fontPack;

  @override
  WishlistThemeTokens copyWith({
    WishlistThemePalette? palette,
    FontPack? fontPack,
  }) {
    return WishlistThemeTokens(
      palette: palette ?? this.palette,
      fontPack: fontPack ?? this.fontPack,
    );
  }

  @override
  WishlistThemeTokens lerp(ThemeExtension<WishlistThemeTokens>? other, double t) {
    if (other is! WishlistThemeTokens) return this;
    return t < 0.5 ? this : other;
  }
}

extension WishlistThemeContext on BuildContext {
  WishlistThemeTokens get wishTokens {
    final ext = Theme.of(this).extension<WishlistThemeTokens>();
    if (ext != null) return ext;
    return WishlistThemeTokens(
      palette: WishlistThemePalette.byId(WishlistThemeId.light),
      fontPack: FontPack.byId(FontPackId.bubbly),
    );
  }

  WishlistThemePalette get wishPalette => wishTokens.palette;

  FontPack get wishFontPack => wishTokens.fontPack;

  Color get wishOutline =>
      wishPalette.onBackground.withValues(
        alpha: Theme.of(this).brightness == Brightness.dark ? 0.45 : 0.92,
      );

  Color get wishInk => wishPalette.onBackground;

  Color get wishMutedInk =>
      wishPalette.onBackground.withValues(alpha: 0.62);

  Color get wishCardFill {
    final p = wishPalette;
    if (p.brightness == Brightness.dark) return p.surface;
    return Colors.white;
  }

  /// System nav / home-indicator inset. Prefer [viewPadding] so edge-to-edge
  /// Android (padding often 0) still clears the gesture bar.
  double get wishBottomInset => MediaQuery.viewPaddingOf(this).bottom;

  /// Scroll padding that keeps the last item above the system nav.
  EdgeInsets wishScrollPadding({
    double horizontal = WishlistColors.screenPadding,
    double top = WishlistColors.screenPadding,
    double extraBottom = 20,
  }) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      extraBottom + wishBottomInset,
    );
  }
}
