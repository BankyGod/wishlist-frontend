import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/empty_wishy.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(demoStoreProvider);
    final items = store.notifications.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: items.isEmpty
          ? const EmptyWishy(message: 'All quiet — no pings yet.')
          : ListView.separated(
              padding: context.wishScrollPadding(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, i) {
                final n = items[i];
                return StickerCard(
                  color: n.read
                      ? null
                      : Theme.of(context).colorScheme.surface,
                  onTap: () => ref.read(demoStoreProvider).markNotificationRead(n.id),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!n.read)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 6, right: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight:
                                        n.read ? FontWeight.w600 : FontWeight.w800,
                                  ),
                            ),
                            const Gap(4),
                            Text(n.body, style: Theme.of(context).textTheme.bodyMedium),
                            const Gap(4),
                            Text(
                              DateFormat.MMMd().add_jm().format(n.createdAt),
                              style: Theme.of(context).textTheme.labelSmall,
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
