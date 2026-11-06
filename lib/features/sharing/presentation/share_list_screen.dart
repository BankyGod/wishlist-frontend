import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/features/lists/domain/models.dart';

class ShareListScreen extends ConsumerWidget {
  const ShareListScreen({super.key, required this.listId});

  final String listId;

  String _privacyLabel(ListPrivacy p) => switch (p) {
        ListPrivacy.private => 'Private',
        ListPrivacy.invite => 'Invite only',
        ListPrivacy.link => 'Link',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(demoStoreProvider);
    final list = store.listById(listId);
    final link = 'https://wishlist.app/share/$listId';

    return Scaffold(
      appBar: AppBar(title: const Text('Share list')),
      body: Padding(
        padding: context.wishScrollPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (list != null)
              StickerCard(
                child: Text(
                  '${list.icon} ${list.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            const Gap(16),
            Text('Privacy', style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            if (list != null)
              StickerCard(
                child: Column(
                  children: ListPrivacy.values.map((privacy) {
                    final selected = list.privacy == privacy;
                    return RadioListTile<ListPrivacy>(
                      contentPadding: EdgeInsets.zero,
                      value: privacy,
                      groupValue: list.privacy,
                      title: Text(_privacyLabel(privacy)),
                      subtitle: Text(switch (privacy) {
                        ListPrivacy.private => 'Only you can see this list',
                        ListPrivacy.invite => 'People you invite by email',
                        ListPrivacy.link => 'Anyone with the link',
                      }),
                      onChanged: (v) {
                        if (v == null) return;
                        store.updateList(list.copyWith(privacy: v));
                      },
                      selected: selected,
                    );
                  }).toList(),
                ),
              ),
            const Gap(16),
            StickerCard(
              child: SelectableText(
                link,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Gap(16),
            StickerButton(
              label: 'Copy link',
              expand: true,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied')),
                );
              },
            ),
            const Gap(8),
            StickerButton(
              label: 'Share',
              filled: false,
              expand: true,
              onPressed: () => SharePlus.instance.share(ShareParams(text: link)),
            ),
            const Gap(8),
            StickerButton(
              label: 'Invite by email',
              color: Theme.of(context).colorScheme.primary,
              expand: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invite sent (demo stub) ✉️'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
