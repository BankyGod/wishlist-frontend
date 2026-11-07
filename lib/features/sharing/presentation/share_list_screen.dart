import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/features/lists/domain/models.dart';

class ShareListScreen extends ConsumerStatefulWidget {
  const ShareListScreen({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<ShareListScreen> createState() => _ShareListScreenState();
}

class _ShareListScreenState extends ConsumerState<ShareListScreen> {
  String _privacyLabel(ListPrivacy p) => switch (p) {
        ListPrivacy.private => 'Private',
        ListPrivacy.invite => 'Invite only',
        ListPrivacy.link => 'Link',
      };

  Future<void> _inviteByEmail() async {
    final emailCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(ctx).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Invite by email', style: Theme.of(ctx).textTheme.headlineSmall),
              const Gap(12),
              TextField(
                controller: emailCtrl,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Friend’s email',
                  hintText: 'name@example.com',
                ),
              ),
              const Gap(16),
              StickerButton(
                label: 'Send invite',
                expand: true,
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        );
      },
    );
    final email = emailCtrl.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) => emailCtrl.dispose());
    if (ok != true || !mounted) return;
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }

    final store = ref.read(demoStoreProvider);
    final list = store.listById(widget.listId);
    final link = 'https://wishlist.app/share/${widget.listId}';
    store.inviteByEmail(listId: widget.listId, email: email);

    final subject = Uri.encodeComponent(
      'Join my ${list?.name ?? 'Wishlist'} list',
    );
    final body = Uri.encodeComponent(
      'Hey!\n\nI shared my wishlist with you:\n$link\n\n— sent from Wishlist (demo)',
    );
    final mailto = Uri.parse('mailto:$email?subject=$subject&body=$body');
    final launched = await launchUrl(mailto);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          launched
              ? 'Invite saved · opened mail for $email'
              : 'Invite saved for $email (mail app unavailable)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(demoStoreProvider);
    final list = store.listById(widget.listId);
    final link = 'https://wishlist.app/share/${widget.listId}';
    final invites = store.invitesForList(widget.listId);

    return Scaffold(
      appBar: AppBar(title: const Text('Share list')),
      body: ListView(
        padding: context.wishScrollPadding(),
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
            onPressed: _inviteByEmail,
          ),
          if (invites.isNotEmpty) ...[
            const Gap(24),
            Text('Invites sent', style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            for (final invite in invites)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StickerCard(
                  color: context.wishCardFill,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.mail_outline_rounded),
                    title: Text(invite.email),
                    subtitle: Text(
                      'Sent ${invite.sentAt.toLocal()}'.split('.').first,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
