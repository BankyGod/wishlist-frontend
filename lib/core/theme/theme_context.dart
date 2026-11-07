import 'package:flutter/material.dart';

import '../motion/motion_tokens.dart';
import 'font_packs.dart';
import 'wishlist_colors.dart';

/// Palette + font pack + experience flags on [ThemeData].
@immutable
class WishlistThemeTokens extends ThemeExtension<WishlistThemeTokens> {
  const WishlistThemeTokens({
    required this.palette,
    required this.fontPack,
    this.animationLevel = AnimationLevel.full,
    this.dataSaver = false,
    this.calmMode = false,
  });

  final WishlistThemePalette palette;
  final FontPack fontPack;
  final AnimationLevel animationLevel;
  final bool dataSaver;
  final bool calmMode;

  @override
  WishlistThemeTokens copyWith({
    WishlistThemePalette? palette,
    FontPack? fontPack,
    AnimationLevel? animationLevel,
    bool? dataSaver,
    bool? calmMode,
  }) {
    return WishlistThemeTokens(
      palette: palette ?? this.palette,
      fontPack: fontPack ?? this.fontPack,
      animationLevel: animationLevel ?? this.animationLevel,
      dataSaver: dataSaver ?? this.dataSaver,
      calmMode: calmMode ?? this.calmMode,
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

  AnimationLevel get wishAnimationLevel => wishTokens.animationLevel;

  bool get wishDataSaver => wishTokens.dataSaver;

  bool get wishCalmMode => wishTokens.calmMode;

  /// Scaled duration for the active animation preference.
  Duration wishDuration(Duration base) =>
      MotionTokens.scale(base, wishAnimationLevel);

  bool get wishAllowDecorativeMotion =>
      MotionTokens.allowDecorative(wishAnimationLevel) && !wishDataSaver;

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
