import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/reveal_meter.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/core/widgets/wish_image.dart';
import 'package:wishlist/features/lists/domain/models.dart';

class WishDetailScreen extends ConsumerWidget {
  const WishDetailScreen({super.key, required this.wishId});

  final String wishId;

  static Widget _priorityStars(BuildContext context, int priority) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < priority;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 22,
          color: filled
              ? scheme.secondary
              : scheme.onSurface.withValues(alpha: 0.35),
        );
      }),
    );
  }

  void _deleteWithUndo(BuildContext context, WidgetRef ref, Wish wish) {
    final store = ref.read(demoStoreProvider);
    final backup = wish;
    store.deleteWish(wish.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${wish.title.isEmpty ? 'Wish' : wish.title}" moved to bin'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => store.restoreWish(backup),
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(demoStoreProvider);
    final wish = store.wishById(wishId);
    if (wish == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Wish not found')),
      );
    }

    final goal = wish.savingsGoalAmount ?? wish.priceAmount ?? 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => context.push('/wishes/$wishId/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _deleteWithUndo(context, ref, wish),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'wish-$wishId',
                child: WishImage(url: wish.coverUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(WishlistColors.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    wish.title.isEmpty ? 'Untitled wish' : wish.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Gap(8),
                  StickerCard(
                    rotation: -0.02,
                    child: Row(
                      children: [
                        _priorityStars(context, wish.priority),
                        const Spacer(),
                        if (wish.priceAmount != null)
                          Text(
                            '${wish.priceCurrency} ${wish.priceAmount!.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (wish.category != null && wish.category!.isNotEmpty) ...[
                    const Gap(12),
                    StickerCard(
                      color: Theme.of(context).colorScheme.surface,
                      child: Row(
                        children: [
                          const Text('🏷️', style: TextStyle(fontSize: 20)),
                          const Gap(8),
                          Text(
                            wish.category!,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (wish.tags.isNotEmpty) ...[
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: wish.tags
                          .map(
                            (t) => Chip(
                              label: Text('#$t'),
                              backgroundColor: context.wishPalette.background,
                              side: BorderSide(
                                color: context.wishOutline,
                                width: 2,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (wish.whyText.isNotEmpty) ...[
                    const Gap(12),
                    StickerCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why I want this',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          const Gap(6),
                          Text(wish.whyText, style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                  if (wish.note.isNotEmpty) ...[
                    const Gap(12),
                    StickerCard(
                      rotation: 0.015,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Gap(6),
                          Text(wish.note, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                  const Gap(16),
                  StickerCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Savings preview',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Gap(12),
                        RevealMeter(
                          imageUrl: wish.coverUrl,
                          progress: wish.savingsProgress,
                          height: 180,
                        ),
                        const Gap(8),
                        Text(
                          '${(wish.savingsProgress * 100).toStringAsFixed(0)}% · '
                          '${wish.savingsTotal.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} GHS',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Gap(12),
                        StickerButton(
                          label: 'Add savings',
                          expand: true,
                          onPressed: () => context.push('/wishes/$wishId/savings'),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  StickerButton(
                    label: 'Edit wish',
                    filled: false,
                    expand: true,
                    onPressed: () => context.push('/wishes/$wishId/edit'),
                  ),
                  if (wish.status == WishStatus.open) ...[
                    const Gap(8),
                    StickerButton(
                      label: 'Grant this wish',
                      color: Theme.of(context).colorScheme.tertiary,
                      expand: true,
                      onPressed: () => context.push('/wishes/$wishId/grant'),
                    ),
                    const Gap(8),
                    StickerButton(
                      label: 'Maybe later',
                      filled: false,
                      expand: true,
                      onPressed: () {
                        store.setWishStatus(wishId, WishStatus.maybeLater);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Parked in Maybe later'),
                          ),
                        );
                      },
                    ),
                  ],
                  if (wish.status == WishStatus.maybeLater) ...[
                    const Gap(8),
                    StickerButton(
                      label: 'Move back to open',
                      expand: true,
                      onPressed: () {
                        store.setWishStatus(wishId, WishStatus.open);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Wish is open again')),
                        );
                      },
                    ),
                  ],
                  const Gap(8),
                  StickerButton(
                    label: 'Delete',
                    color: Theme.of(context).colorScheme.secondary,
                    expand: true,
                    onPressed: () => _deleteWithUndo(context, ref, wish),
                  ),
                  SizedBox(height: 24 + context.wishBottomInset),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
