import 'dart:ui';

import 'package:flutter/material.dart';

import 'wish_image.dart';

/// Blur + grayscale reveal based on [progress] (0 = full blur, 1 = sharp).
class RevealMeter extends StatelessWidget {
  const RevealMeter({
    super.key,
    required this.imageUrl,
    required this.progress,
    this.height = 220,
    this.borderRadius,
  });

  final String imageUrl;
  final double progress;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    final blurSigma = (1 - t) * 18;
    final grayscale = 1 - t;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            WishImage(
              url: imageUrl,
              height: height,
              fit: BoxFit.cover,
            ),
            if (t < 1)
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(_grayscaleMatrix(grayscale)),
                  child: WishImage(
                    url: imageUrl,
                    height: height,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: LinearProgressIndicator(
                value: t,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: Colors.white.withValues(alpha: 0.35),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _grayscaleMatrix(double amount) {
    final inv = 1 - amount;
    final r = 0.2126 * amount + inv;
    final g = 0.7152 * amount + inv;
    final b = 0.0722 * amount + inv;
    return [
      r, g, b, 0, 0,
      r, g, b, 0, 0,
      r, g, b, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }
}
