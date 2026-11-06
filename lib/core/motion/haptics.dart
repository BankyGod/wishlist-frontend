import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptics gated by Settings → Haptics.
/// Prefers the Android [Vibrator] API (feels on budget Samsungs) and falls
/// back to [HapticFeedback].
abstract final class WishlistHaptics {
  static bool enabled = true;
  static bool? _hasVibrator;
  static bool? _hasAmplitude;

  static Future<void> _probe() async {
    if (_hasVibrator != null) return;
    try {
      _hasVibrator = await Vibration.hasVibrator();
      _hasAmplitude = await Vibration.hasAmplitudeControl();
    } catch (_) {
      _hasVibrator = false;
      _hasAmplitude = false;
    }
  }

  static Future<void> _pulse(int ms, {int amplitude = 180}) async {
    if (!enabled) return;
    await _probe();
    try {
      if (_hasVibrator == true) {
        if (_hasAmplitude == true) {
          await Vibration.vibrate(duration: ms, amplitude: amplitude);
        } else {
          await Vibration.vibrate(duration: ms);
        }
        return;
      }
    } catch (e) {
      debugPrint('Vibration.vibrate failed: $e');
    }
    await HapticFeedback.mediumImpact();
  }

  static Future<void> tap() => _pulse(32, amplitude: 160);

  static Future<void> success() => _pulse(50, amplitude: 220);

  static Future<void> warning() => _pulse(60, amplitude: 240);

  static Future<void> error() => _pulse(90, amplitude: 255);

  static Future<void> celebration() async {
    if (!enabled) return;
    await _pulse(70, amplitude: 255);
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await _pulse(45, amplitude: 200);
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await _pulse(30, amplitude: 160);
  }
}
