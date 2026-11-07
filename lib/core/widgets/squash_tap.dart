import 'package:flutter/material.dart';

import '../motion/feedback.dart';
import '../motion/motion_tokens.dart';
import '../theme/theme_context.dart';

/// Squash-on-press wrapper (SRD UI-M3).
/// Uses [InkWell.onTap] so taps still fire inside scrollables / with keyboard open.
class SquashTap extends StatefulWidget {
  const SquashTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.haptics = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool haptics;

  @override
  State<SquashTap> createState() => _SquashTapState();
}

class _SquashTapState extends State<SquashTap> {
  bool _pressed = false;

  bool get _canTap => widget.enabled && widget.onTap != null;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!_canTap) return;
    if (widget.haptics) WishlistFeedback.tap();
    widget.onTap!.call();
  }

  @override
  Widget build(BuildContext context) {
    final animate = context.wishAllowDecorativeMotion;
    final duration = context.wishDuration(MotionTokens.micro);
    final scale = (!animate || !_pressed) ? 1.0 : MotionTokens.pressScale;

    return Opacity(
      opacity: _canTap || widget.onLongPress != null ? 1 : 0.45,
      child: AnimatedScale(
        scale: scale,
        duration: duration,
        curve: Curves.easeOut,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _canTap ? _handleTap : null,
            onLongPress: widget.enabled ? widget.onLongPress : null,
            onHighlightChanged: (v) => _setPressed(v),
            borderRadius: BorderRadius.circular(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
