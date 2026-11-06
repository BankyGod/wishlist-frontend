import 'haptics.dart';
import 'sounds.dart';

/// Combined sound + haptic cues gated by Settings toggles.
abstract final class WishlistFeedback {
  static Future<void> tap() async {
    await Future.wait([
      WishlistHaptics.tap(),
      WishlistSounds.tap(),
    ]);
  }

  static Future<void> success() async {
    await Future.wait([
      WishlistHaptics.success(),
      WishlistSounds.success(),
    ]);
  }

  static Future<void> warning() async {
    await Future.wait([
      WishlistHaptics.warning(),
      WishlistSounds.warning(),
    ]);
  }

  static Future<void> error() async {
    await Future.wait([
      WishlistHaptics.error(),
      WishlistSounds.error(),
    ]);
  }

  static Future<void> celebration() async {
    await Future.wait([
      WishlistHaptics.celebration(),
      WishlistSounds.celebration(),
    ]);
  }

  /// Preview when enabling a toggle in Settings.
  static Future<void> previewHaptics() => WishlistHaptics.success();

  static Future<void> previewSound() => WishlistSounds.success();
}
