import 'package:flutter/material.dart';

/// Animated integer counter with rolling digit feel.
class RollingNumber extends StatefulWidget {
  const RollingNumber({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 400),
  });

  final int value;
  final TextStyle? style;
  final Duration duration;

  @override
  State<RollingNumber> createState() => _RollingNumberState();
}

class _RollingNumberState extends State<RollingNumber> {
  late int _from;
  late int _to;

  @override
  void initState() {
    super.initState();
    _from = _to = widget.value;
  }

  @override
  void didUpdateWidget(RollingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = oldWidget.value;
      _to = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ?? Theme.of(context).textTheme.headlineMedium;
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: _from, end: _to),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      onEnd: () => _from = _to,
      builder: (context, animated, child) {
        return Text('$animated', style: textStyle);
      },
    );
  }
}
