import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static final _supportEmail = Uri(
    scheme: 'mailto',
    path: 'hello@wishlist.app',
    queryParameters: {'subject': 'Wishlist help'},
  );

  Future<void> _mail(BuildContext context) async {
    final ok = await launchUrl(_supportEmail);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn’t open mail app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        padding: context.wishScrollPadding(),
        children: [
          Text('Quick tips', style: text.headlineSmall),
          const Gap(12),
          const _HelpCard(
            emoji: '📷',
            title: 'Snap a wish',
            body:
                'Open any list, tap +, then Camera or Gallery. Fill in the title and price on the edit screen.',
          ),
          const Gap(10),
          const _HelpCard(
            emoji: '💰',
            title: 'Chase it with savings',
            body:
                'On a wish, open Add savings. The reveal meter peels back as you get closer to your goal.',
          ),
          const Gap(10),
          const _HelpCard(
            emoji: '🫙',
            title: 'Shake the Wish Jar',
            body:
                'Not sure what to chase next? Jar picks a weighted open wish — higher priority gets drawn more often.',
          ),
          const Gap(10),
          const _HelpCard(
            emoji: '🗑️',
            title: 'Bin & restore',
            body:
                'Delete moves a wish to Bin (Settings → Bin). Restore it, delete forever, or empty the bin.',
          ),
          const Gap(10),
          const _HelpCard(
            emoji: '🌙',
            title: 'Calm mode & data saver',
            body:
                'Settings → Experience. Calm hides stardust nudges. Data saver lightens images and motion.',
          ),
          const Gap(24),
          Text('Still stuck?', style: text.titleLarge),
          const Gap(8),
          StickerCard(
            onTap: () => _mail(context),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.mail_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Email support'),
              subtitle: const Text('hello@wishlist.app'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const Gap(12),
          Text(
            'Demo builds keep data on this device only until a real backend is connected.',
            style: text.bodySmall?.copyWith(color: context.wishMutedInk),
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({
    required this.emoji,
    required this.title,
    required this.body,
  });

  final String emoji;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return StickerCard(
      color: context.wishCardFill,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Gap(4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
