import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wishlist/core/config/app_config.dart';
import 'package:wishlist/core/motion/haptics.dart';
import 'package:wishlist/core/motion/motion_tokens.dart';
import 'package:wishlist/core/motion/sounds.dart';
import 'package:wishlist/core/theme/font_packs.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/theme/wishlist_theme.dart';
import 'package:wishlist/features/lists/data/demo_store.dart';

final demoStoreProvider = ChangeNotifierProvider<DemoStore>((ref) {
  return DemoStore();
});

class WishlistThemeNotifier extends Notifier<WishlistThemeData> {
  static const _kSounds = 'wishlist_sounds_enabled';
  static const _kHaptics = 'wishlist_haptics_enabled';
  static const _kConfetti = 'wishlist_confetti_enabled';
  static const _kPalette = 'wishlist_theme_palette';
  static const _kFont = 'wishlist_font_pack';
  static const _kAnimation = 'wishlist_animation_level';
  static const _kDataSaver = 'wishlist_data_saver';
  static const _kCalm = 'wishlist_calm_mode';

  @override
  WishlistThemeData build() {
    final defaults = WishlistThemeData.defaults();
    _syncFlags(defaults);
    Future.microtask(_hydrateFromPrefs);
    return defaults;
  }

  Future<void> _hydrateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    WishlistThemePalette palette = state.palette;
    final paletteName = prefs.getString(_kPalette);
    if (paletteName != null) {
      try {
        palette = WishlistThemePalette.byId(
          WishlistThemeId.values.byName(paletteName),
        );
      } catch (_) {}
    }

    FontPack fontPack = state.fontPack;
    final fontName = prefs.getString(_kFont);
    if (fontName != null) {
      try {
        fontPack = FontPack.byId(FontPackId.values.byName(fontName));
      } catch (_) {}
    }

    AnimationLevel animationLevel = state.animationLevel;
    final animName = prefs.getString(_kAnimation);
    if (animName != null) {
      try {
        animationLevel = AnimationLevel.values.byName(animName);
      } catch (_) {}
    }

    final next = state.copyWith(
      palette: palette,
      fontPack: fontPack,
      animationLevel: animationLevel,
      soundsEnabled: prefs.getBool(_kSounds) ?? state.soundsEnabled,
      hapticsEnabled: prefs.getBool(_kHaptics) ?? state.hapticsEnabled,
      confettiEnabled: prefs.getBool(_kConfetti) ?? state.confettiEnabled,
      dataSaver: prefs.getBool(_kDataSaver) ?? state.dataSaver,
      calmMode: prefs.getBool(_kCalm) ?? state.calmMode,
    );
    state = next;
    _syncFlags(next);
  }

  Future<void> _persist(WishlistThemeData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPalette, data.palette.id.name);
    await prefs.setString(_kFont, data.fontPack.id.name);
    await prefs.setString(_kAnimation, data.animationLevel.name);
    await prefs.setBool(_kSounds, data.soundsEnabled);
    await prefs.setBool(_kHaptics, data.hapticsEnabled);
    await prefs.setBool(_kConfetti, data.confettiEnabled);
    await prefs.setBool(_kDataSaver, data.dataSaver);
    await prefs.setBool(_kCalm, data.calmMode);
  }

  void _syncFlags(WishlistThemeData data) {
    WishlistSounds.enabled = data.soundsEnabled;
    WishlistHaptics.enabled = data.hapticsEnabled;
  }

  void setTheme(WishlistThemeData data) {
    state = data;
    _syncFlags(data);
    _persist(data);
  }

  void update(WishlistThemeData Function(WishlistThemeData current) fn) {
    final next = fn(state);
    state = next;
    _syncFlags(next);
    _persist(next);
  }
}

final wishlistThemeProvider =
    NotifierProvider<WishlistThemeNotifier, WishlistThemeData>(
  WishlistThemeNotifier.new,
);

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('Override appConfigProvider in ProviderScope'),
);
