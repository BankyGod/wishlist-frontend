import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../motion/motion_tokens.dart';
import 'font_packs.dart';
import 'theme_context.dart';
import 'wishlist_colors.dart';

class WishlistThemeData {
  const WishlistThemeData({
    required this.palette,
    required this.fontPack,
    required this.animationLevel,
    this.soundsEnabled = true,
    this.hapticsEnabled = true,
    this.confettiEnabled = true,
    this.dataSaver = false,
    this.calmMode = false,
  });

  final WishlistThemePalette palette;
  final FontPack fontPack;
  final AnimationLevel animationLevel;
  final bool soundsEnabled;
  final bool hapticsEnabled;
  final bool confettiEnabled;
  final bool dataSaver;
  final bool calmMode;

  WishlistThemeData copyWith({
    WishlistThemePalette? palette,
    FontPack? fontPack,
    AnimationLevel? animationLevel,
    bool? soundsEnabled,
    bool? hapticsEnabled,
    bool? confettiEnabled,
    bool? dataSaver,
    bool? calmMode,
  }) {
    return WishlistThemeData(
      palette: palette ?? this.palette,
      fontPack: fontPack ?? this.fontPack,
      animationLevel: animationLevel ?? this.animationLevel,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      confettiEnabled: confettiEnabled ?? this.confettiEnabled,
      dataSaver: dataSaver ?? this.dataSaver,
      calmMode: calmMode ?? this.calmMode,
    );
  }

  static WishlistThemeData defaults() => WishlistThemeData(
        palette: WishlistThemePalette.byId(WishlistThemeId.light),
        fontPack: FontPack.byId(FontPackId.bubbly),
        animationLevel: AnimationLevel.full,
      );

  TextStyle _safeFont({
    required String family,
    required double size,
    FontWeight? weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    try {
      return GoogleFonts.getFont(
        family,
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }
  }

  ThemeData toThemeData() {
    final p = palette;
    final base = p.brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);

    TextStyle display([double size = 32, FontWeight? w]) => _safeFont(
          family: fontPack.displayFamily,
          size: size,
          weight: w ?? FontWeight.w800,
          color: p.onBackground,
        );

    TextStyle heading([double size = 20, FontWeight? w]) => _safeFont(
          family: fontPack.headingFamily,
          size: size,
          weight: w ?? FontWeight.w700,
          color: p.onBackground,
        );

    TextStyle body([double size = 16, FontWeight? w]) => _safeFont(
          family: fontPack.bodyFamily,
          size: size,
          weight: w,
          color: p.onBackground,
        );

    TextStyle number([double size = 24, FontWeight? w]) => _safeFont(
          family: fontPack.numberFamily,
          size: size,
          weight: w ?? FontWeight.w800,
          color: p.onBackground,
        );

    final textTheme = TextTheme(
      displayLarge: display(56),
      displayMedium: display(40),
      displaySmall: display(32),
      headlineLarge: heading(28, FontWeight.w800),
      headlineMedium: heading(24, FontWeight.w800),
      headlineSmall: heading(20, FontWeight.w800),
      titleLarge: heading(20, FontWeight.w800),
      titleMedium: heading(16, FontWeight.w700),
      titleSmall: heading(14, FontWeight.w700),
      bodyLarge: body(16),
      bodyMedium: body(14),
      bodySmall: body(12),
      labelLarge: body(14, FontWeight.w700),
      labelMedium: body(12, FontWeight.w600),
      labelSmall: body(11, FontWeight.w600),
    );

    final outline = p.onBackground.withValues(
      alpha: p.brightness == Brightness.dark ? 0.45 : 0.92,
    );
    final mutedFill = Color.lerp(p.surface, p.background, 0.35)!;

    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      cardColor: p.surface,
      dividerColor: p.onBackground.withValues(alpha: 0.12),
      colorScheme: ColorScheme(
        brightness: p.brightness,
        primary: p.primary,
        onPrimary: Colors.white,
        secondary: p.accent,
        onSecondary: p.brightness == Brightness.dark
            ? Colors.white
            : WishlistColors.midnightInk,
        tertiary: p.accent,
        onTertiary: Colors.white,
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
        surface: p.surface,
        onSurface: p.onBackground,
        surfaceContainerHighest: mutedFill,
        outline: outline,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: p.onBackground),
      primaryIconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.onBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        // Always bake ink into the title style so a transparent AppBar
        // (estimated as "dark" by Material) cannot wash titles to white.
        titleTextStyle: heading(22, FontWeight.w800).copyWith(
          color: p.onBackground,
        ),
        toolbarTextStyle: body(14).copyWith(color: p.onBackground),
        iconTheme: IconThemeData(color: p.onBackground),
        actionsIconTheme: IconThemeData(color: p.onBackground),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.primary.withValues(alpha: 0.22),
        disabledColor: p.surface.withValues(alpha: 0.5),
        labelStyle: body(13, FontWeight.w700),
        secondaryLabelStyle: body(13, FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WishlistColors.chipRadius),
          side: BorderSide(color: outline, width: 1.5),
        ),
        side: BorderSide(color: outline, width: 1.5),
        showCheckmark: true,
        checkmarkColor: p.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.brightness == Brightness.dark ? p.surface : Colors.white,
        hintStyle: body(14).copyWith(
          color: p.onBackground.withValues(alpha: 0.45),
        ),
        prefixIconColor: p.onBackground.withValues(alpha: 0.55),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: p.primary, width: 2.5),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.onBackground,
        textColor: p.onBackground,
        titleTextStyle: heading(16, FontWeight.w700),
        subtitleTextStyle: body(13),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: body(14, FontWeight.w800),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          textStyle: body(15, FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WishlistColors.chipRadius),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.brightness == Brightness.dark
            ? p.surface
            : WishlistColors.midnightInk,
        contentTextStyle: body(14).copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WishlistColors.chipRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        titleTextStyle: heading(20, FontWeight.w800),
        contentTextStyle: body(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WishlistColors.cardRadius),
          side: BorderSide(color: outline, width: 2),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        WishlistThemeTokens(
          palette: p,
          fontPack: fontPack,
          animationLevel: animationLevel,
          dataSaver: dataSaver,
          calmMode: calmMode,
        ),
        _NumberTextStyle(number()),
      ],
    );
  }
}

/// Optional number typography from the active font pack.
@immutable
class _NumberTextStyle extends ThemeExtension<_NumberTextStyle> {
  const _NumberTextStyle(this.style);
  final TextStyle style;

  @override
  _NumberTextStyle copyWith({TextStyle? style}) =>
      _NumberTextStyle(style ?? this.style);

  @override
  _NumberTextStyle lerp(ThemeExtension<_NumberTextStyle>? other, double t) {
    if (other is! _NumberTextStyle) return this;
    return _NumberTextStyle(TextStyle.lerp(style, other.style, t) ?? style);
  }
}

extension WishlistNumberStyle on BuildContext {
  TextStyle get wishNumberStyle {
    final ext = Theme.of(this).extension<_NumberTextStyle>();
    return ext?.style ??
        Theme.of(this).textTheme.headlineMedium ??
        const TextStyle(fontSize: 24, fontWeight: FontWeight.w800);
  }
}
