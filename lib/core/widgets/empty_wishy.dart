import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

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
    final animate = context.wishAllowDecorativeMotion;
    return Padding(
      padding: const EdgeInsets.all(WishlistColors.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: animate
                ? Lottie.asset(
                    'assets/lottie/wishy_sparkle.json',
                    repeat: true,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      '⭐',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 72),
                    ),
                  )
                : const Text('⭐', style: TextStyle(fontSize: 72)),
          ),
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
      )
          .animate(target: animate ? 1 : 0)
          .fadeIn(duration: 300.ms),
    );
  }
}
