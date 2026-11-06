import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import '../theme/wishlist_colors.dart';
import 'squash_tap.dart';

class StickerButton extends StatelessWidget {
  const StickerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.filled = true,
    this.color,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final Color? color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = filled ? (color ?? scheme.primary) : context.wishCardFill;
    final fg = filled ? Colors.white : scheme.onSurface;
    final outline = context.wishOutline;

    final child = Container(
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(WishlistColors.chipRadius),
        border: Border.all(
          color: outline,
          width: WishlistColors.outlineWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.16),
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
          ),
        ],
      ),
    );

    return SquashTap(onTap: onPressed, child: child);
  }
}
