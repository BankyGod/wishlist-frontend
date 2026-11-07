import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/core/widgets/wish_image.dart';

class BinScreen extends ConsumerWidget {
  const BinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(demoStoreProvider);
    final binned = store.binnedWishes;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bin'),
        actions: [
          if (binned.isNotEmpty)
            TextButton(
              onPressed: () => _confirmEmpty(context, ref),
              child: const Text('Empty'),
            ),
        ],
      ),
      body: binned.isEmpty
          ? Padding(
              padding: context.wishScrollPadding(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StickerCard(
                    rotation: 0.04,
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      children: [
                        const Text('🗑️', style: TextStyle(fontSize: 56)),
                        const Gap(12),
                        Text(
                          'Nothing in the bin',
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'Deleted wishes land here. Restore them, or empty the bin for good.',
                          textAlign: TextAlign.center,
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: context.wishScrollPadding(extraBottom: 32),
              itemCount: binned.length,
              separatorBuilder: (context, index) => const Gap(10),
              itemBuilder: (context, i) {
                final wish = binned[i];
                final title =
                    wish.title.isEmpty ? 'Untitled wish' : wish.title;
                return StickerCard(
                  color: context.wishCardFill,
                  child: Row(
                    children: [
                      WishImage(
                        url: wish.coverUrl,
                        width: 64,
                        height: 64,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: text.titleMedium),
                            Text(
                              'Deleted ${_relative(wish.deletedAt!)}',
                              style: text.bodySmall?.copyWith(
                                color: context.wishMutedInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Restore',
                        onPressed: () {
                          store.restoreWishById(wish.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Restored "$title"')),
                          );
                        },
                        icon: const Icon(Icons.restore_rounded),
                      ),
                      IconButton(
                        tooltip: 'Delete forever',
                        onPressed: () {
                          store.permanentlyDeleteWish(wish.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted "$title" forever')),
                          );
                        },
                        icon: Icon(
                          Icons.delete_forever_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }

  Future<void> _confirmEmpty(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty bin?'),
        content: const Text(
          'This permanently deletes every wish in the bin. You can’t undo it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          StickerButton(
            label: 'Empty',
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    ref.read(demoStoreProvider).emptyBin();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bin emptied')),
    );
  }
}
