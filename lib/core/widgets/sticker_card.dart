import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import '../theme/wishlist_colors.dart';

/// Sticker Pop card: thick outline + hard offset shadow (SRD §6.2).
class StickerCard extends StatelessWidget {
  const StickerCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.onTap,
    this.rotation = 0,
    this.outlined = true,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double rotation;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(WishlistColors.cardRadius);
    final bg = color ?? context.wishCardFill;
    final outline = context.wishOutline;
    final ink = context.wishInk;

    return Transform.rotate(
      angle: rotation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: ink.withValues(alpha: 0.18),
              offset: WishlistColors.hardShadow,
            ),
          ],
        ),
        child: Material(
          color: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: outlined
                ? BorderSide(color: outline, width: WishlistColors.outlineWidth)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: onTap == null
              ? Padding(padding: padding, child: child)
              : InkWell(
                  onTap: onTap,
                  child: Padding(padding: padding, child: child),
                ),
        ),
      ),
    );
  }
}
