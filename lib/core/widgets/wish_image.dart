import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import '../theme/wishlist_colors.dart';

/// Wish cover image — file paths, network URLs, or a playful fallback tile.
class WishImage extends StatelessWidget {
  const WishImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderColor,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;

  bool get _isNetwork =>
      url.startsWith('http://') || url.startsWith('https://');

  bool get _isAsset => url.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(WishlistColors.cardRadius);
    final scheme = Theme.of(context).colorScheme;
    final tint = placeholderColor ?? scheme.surface;
    final dataSaver = context.wishDataSaver;

    // Decode at display size when data saver is on (less memory / bandwidth).
    final cacheW = dataSaver && width != null
        ? (width! * MediaQuery.devicePixelRatioOf(context)).round()
        : null;
    final cacheH = dataSaver && height != null
        ? (height! * MediaQuery.devicePixelRatioOf(context)).round()
        : (dataSaver ? 480 : null);

    Widget image;
    if (url.isEmpty) {
      image = _fallback(context, tint, '✨');
    } else if (_isNetwork) {
      image = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheW ?? cacheH,
        errorBuilder: (context, error, stackTrace) =>
            _fallback(context, tint, '🎁'),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _fallback(context, tint, '⏳');
        },
      );
    } else if (_isAsset) {
      image = Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheW,
        cacheHeight: cacheH,
        errorBuilder: (context, error, stackTrace) =>
            _fallback(context, tint, '📷'),
      );
    } else {
      // Local camera / gallery path from image_picker
      image = Image.file(
        File(url),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheW,
        cacheHeight: cacheH,
        errorBuilder: (context, error, stackTrace) =>
            _fallback(context, tint, '📷'),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(width: width, height: height, child: image),
    );
  }

  Widget _fallback(BuildContext context, Color tint, String emoji) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tint,
            primary.withValues(alpha: 0.25),
          ],
        ),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }
}
