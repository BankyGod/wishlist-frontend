import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/core/widgets/wish_image.dart';

class ShelfScreen extends ConsumerWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final granted = ref.watch(demoStoreProvider).grantedWishes;
    final total = granted.fold<double>(
      0,
      (s, w) => s + (w.grantedPrice ?? w.priceAmount ?? 0),
    );
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cardFill = context.wishCardFill;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text('Granted shelf 🏆', style: text.headlineMedium),
          const Gap(12),
          StickerCard(
            color: scheme.primary.withValues(alpha: 0.16),
            child: Row(
              children: [
                Text(
                  '${granted.length} granted',
                  style: text.titleMedium,
                ),
                const Spacer(),
                Text(
                  'GHS ${total.toStringAsFixed(0)}',
                  style: text.titleMedium?.copyWith(color: scheme.primary),
                ),
              ],
            ),
          ),
          const Gap(16),
          if (granted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                'Grant a wish and it will shine here.',
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: context.wishMutedInk),
              ),
            )
          else
            ...granted.map((w) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.push('/wishes/${w.id}'),
                    child: StickerCard(
                      color: cardFill,
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          WishImage(
                            url: w.coverUrl,
                            width: 88,
                            height: 88,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(22),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.title.isEmpty ? 'Wish' : w.title,
                                    style: text.titleMedium,
                                  ),
                                  if (w.grantedAt != null)
                                    Text(
                                      'Granted ${MaterialLocalizations.of(context).formatShortDate(w.grantedAt!)}',
                                      style: text.bodySmall?.copyWith(
                                        color: context.wishMutedInk,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Text('🏆', style: TextStyle(fontSize: 28)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
