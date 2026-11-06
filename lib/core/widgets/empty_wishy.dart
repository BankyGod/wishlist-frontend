import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../theme/theme_context.dart';
import '../theme/wishlist_colors.dart';
import 'sticker_button.dart';

/// Cute empty state mascot "Wishy" with optional CTA.
class EmptyWishy extends StatelessWidget {
  const EmptyWishy({
    super.key,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(WishlistColors.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 72))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(begin: -0.05, end: 0.05, duration: 900.ms)
              .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06)),
          const Gap(12),
          Text(
            'Wishy',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: scheme.primary,
                ),
          ),
          const Gap(8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.wishMutedInk,
                ),
          ),
          if (ctaLabel != null && onCta != null) ...[
            const Gap(24),
            StickerButton(label: ctaLabel!, onPressed: onCta, expand: true),
          ],
        ],
      ),
    );
  }
}
