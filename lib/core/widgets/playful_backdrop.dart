import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Sticker Pop atmosphere (SRD §6.2) — colours follow the active theme.
class PlayfulBackdrop extends StatelessWidget {
  const PlayfulBackdrop({
    super.key,
    required this.child,
    this.dense = false,
  });

  final Widget child;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final p = context.wishPalette;
    final top = Color.lerp(p.background, Colors.white, p.brightness == Brightness.dark ? 0.04 : 0.35)!;
    final mid = p.background;
    final wash = Color.lerp(p.background, p.surface, 0.65)!;
    final accentWash = Color.lerp(p.surface, p.accent, 0.18)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [top, mid, wash, accentWash],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _DoodlePainter(
              dense: dense,
              primary: p.primary,
              accent: p.accent,
              ink: p.onBackground,
              brightness: p.brightness,
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _DoodlePainter extends CustomPainter {
  _DoodlePainter({
    required this.dense,
    required this.primary,
    required this.accent,
    required this.ink,
    required this.brightness,
  });

  final bool dense;
  final Color primary;
  final Color accent;
  final Color ink;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rnd = math.Random(42);
    final alphaOrb = brightness == Brightness.dark ? 0.18 : 0.12;
    final alphaStroke = brightness == Brightness.dark ? 0.22 : 0.16;

    final orb = Paint()..style = PaintingStyle.fill;
    // Keep large washes below the app bar so icons stay readable.
    orb.color = primary.withValues(alpha: alphaOrb * 0.7);
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.18), 70, orb);
    orb.color = accent.withValues(alpha: alphaOrb * 0.75);
    canvas.drawCircle(Offset(-10, size.height * 0.38), 78, orb);
    orb.color = Color.lerp(primary, accent, 0.5)!.withValues(alpha: alphaOrb);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.78), 88, orb);

    final palette = [
      primary,
      accent,
      Color.lerp(primary, accent, 0.35)!,
      Color.lerp(accent, ink, 0.25)!,
      Color.lerp(primary, Colors.white, 0.25)!,
    ];

    final count = dense ? 28 : 18;
    for (var i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final kind = i % 5;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette[kind].withValues(alpha: alphaStroke);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rnd.nextDouble() * math.pi);
      switch (kind) {
        case 0:
          _star(canvas, paint, 7 + rnd.nextDouble() * 6);
        case 1:
          canvas.drawLine(const Offset(-6, 0), const Offset(6, 0), paint);
          canvas.drawLine(const Offset(0, -6), const Offset(0, 6), paint);
        case 2:
          canvas.drawCircle(Offset.zero, 5 + rnd.nextDouble() * 4, paint);
        case 3:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: 18, height: 6),
              const Radius.circular(3),
            ),
            paint,
          );
        default:
          final path = Path()
            ..moveTo(0, -6)
            ..lineTo(5, 0)
            ..lineTo(0, 6)
            ..lineTo(-5, 0)
            ..close();
          canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  void _star(Canvas canvas, Paint paint, double r) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 4 * math.pi / 5;
      final p = Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter oldDelegate) =>
      oldDelegate.dense != dense ||
      oldDelegate.primary != primary ||
      oldDelegate.accent != accent ||
      oldDelegate.ink != ink ||
      oldDelegate.brightness != brightness;
}
