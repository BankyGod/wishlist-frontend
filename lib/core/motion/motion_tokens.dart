import 'package:flutter/animation.dart';

/// Shared motion tokens from SRD §6.5.
/// Do not hard-code durations or curves in feature widgets — use these.
enum AnimationLevel { full, reduced, off }

abstract final class MotionTokens {
  static const micro = Duration(milliseconds: 120);
  static const short = Duration(milliseconds: 220);
  static const medium = Duration(milliseconds: 380);
  static const long = Duration(milliseconds: 600);
  static const hero = Duration(milliseconds: 900);
  static const celebrateMin = Duration(milliseconds: 2500);
  static const celebrateMax = Duration(milliseconds: 4000);

  static const staggerList = Duration(milliseconds: 40);
  static const staggerMaxItems = 12;

  static const curvePop = Curves.easeOutBack;
  static const curveRubber = Curves.elasticOut;
  static const curveSmooth = Curves.easeInOutCubicEmphasized;
  static const curveDrop = Curves.bounceOut;

  static SpringDescription get springSoft => const SpringDescription(
        mass: 1,
        stiffness: 180,
        damping: 12,
      );

  static SpringDescription get springSnappy => const SpringDescription(
        mass: 1,
        stiffness: 320,
        damping: 20,
      );

  static Duration scale(Duration base, AnimationLevel level) {
    return switch (level) {
      AnimationLevel.full => base,
      AnimationLevel.reduced => Duration(
          milliseconds: (base.inMilliseconds * 0.5).round(),
        ),
      AnimationLevel.off => Duration.zero,
    };
  }

  static bool allowDecorative(AnimationLevel level) =>
      level == AnimationLevel.full;

  static double pressScale = 0.92;
  static double dragLiftScale = 1.08;
  static double dragLiftRotation = 0.035; // ~2 degrees
}
