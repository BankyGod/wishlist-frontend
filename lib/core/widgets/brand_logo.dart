import 'package:flutter/material.dart';

/// Official Wishlist kawaii logo (star-in-jar sticker).
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 160,
    this.showShadow = true,
  });

  final double size;
  final bool showShadow;

  static const assetPath = 'assets/images/wishlist_logo.jpg';

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.18),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: Text('✨', style: TextStyle(fontSize: 48)),
          ),
        ),
      ),
    );

    if (!showShadow) return image;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
            offset: const Offset(4, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: image,
    );
  }
}
