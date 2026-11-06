import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wishlist/core/config/app_config.dart';
import 'package:wishlist/core/motion/haptics.dart';
import 'package:wishlist/core/motion/sounds.dart';
import 'package:wishlist/core/theme/wishlist_theme.dart';
import 'package:wishlist/features/lists/data/demo_store.dart';

final demoStoreProvider = ChangeNotifierProvider<DemoStore>((ref) {
  return DemoStore();
});

class WishlistThemeNotifier extends Notifier<WishlistThemeData> {
  static const _kSounds = 'wishlist_sounds_enabled';
  static const _kHaptics = 'wishlist_haptics_enabled';
  static const _kConfetti = 'wishlist_confetti_enabled';

  @override
  WishlistThemeData build() {
    final defaults = WishlistThemeData.defaults();
    _syncFlags(defaults);
    Future.microtask(_hydrateFromPrefs);
    return defaults;
  }

  Future<void> _hydrateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final next = state.copyWith(
      soundsEnabled: prefs.getBool(_kSounds) ?? state.soundsEnabled,
      hapticsEnabled: prefs.getBool(_kHaptics) ?? state.hapticsEnabled,
      confettiEnabled: prefs.getBool(_kConfetti) ?? state.confettiEnabled,
    );
    state = next;
    _syncFlags(next);
  }

  Future<void> _persist(WishlistThemeData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSounds, data.soundsEnabled);
    await prefs.setBool(_kHaptics, data.hapticsEnabled);
    await prefs.setBool(_kConfetti, data.confettiEnabled);
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
