import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class TrophyRoomScreen extends ConsumerWidget {
  const TrophyRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(demoStoreProvider).badges;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Trophy room')),
      body: GridView.builder(
        padding: context.wishScrollPadding(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          // Taller cells so badge copy fits on compact phones.
          childAspectRatio: 0.85,
        ),
        itemCount: badges.length,
        itemBuilder: (context, i) {
          final b = badges[i];
          return StickerCard(
            color: b.unlocked
                ? scheme.surface
                : scheme.surface.withValues(alpha: 0.45),
            child: Stack(
              children: [
                if (b.unlocked)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: scheme.primary,
                      size: 22,
                    ),
                  ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        b.unlocked ? b.emoji : '🔒',
                        style: TextStyle(
                          fontSize: 36,
                          color: b.unlocked ? null : Colors.grey.shade500,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        b.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: b.unlocked ? null : context.wishMutedInk,
                            ),
                      ),
                      if (!b.unlocked)
                        Text(
                          'Locked',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: context.wishMutedInk,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      const Gap(2),
                      Text(
                        b.description,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: b.unlocked ? null : context.wishMutedInk,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
