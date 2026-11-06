import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// UI sounds gated by Settings → Sound. Plays bundled WAV assets so cues
/// follow media volume (unlike silent [SystemSound] clicks on many Androids).
abstract final class WishlistSounds {
  static bool enabled = true;
  static AudioPlayer? _player;
  static Future<void>? _initFuture;

  static Future<void> init() {
    return _initFuture ??= _doInit();
  }

  static Future<void> _doInit() async {
    try {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(1.0);
      await player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {},
          ),
        ),
      );
      _player = player;
    } catch (e) {
      debugPrint('WishlistSounds.init failed: $e');
      _initFuture = null;
    }
  }

  static Future<void> _play(String asset) async {
    if (!enabled) return;
    try {
      await init();
      final player = _player;
      if (player == null) return;
      await player.stop();
      await player.play(AssetSource(asset), volume: 1.0);
    } catch (e) {
      debugPrint('WishlistSounds.play($asset) failed: $e');
    }
  }

  static Future<void> tap() => _play('sounds/tap.wav');

  static Future<void> success() => _play('sounds/success.wav');

  static Future<void> warning() => _play('sounds/warning.wav');

  static Future<void> error() => _play('sounds/warning.wav');

  static Future<void> celebration() => _play('sounds/celebrate.wav');
}
