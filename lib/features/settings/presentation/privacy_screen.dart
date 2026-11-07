import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: context.wishScrollPadding(),
        children: [
          Text('Your wishes, your rules', style: text.headlineSmall),
          const Gap(8),
          Text(
            'This summary covers how the Wishlist demo app handles data on your device. It is not legal advice for a production launch.',
            style: text.bodyMedium?.copyWith(color: context.wishMutedInk),
          ),
          const Gap(16),
          const _Section(
            title: 'What we store on device',
            body:
                'Lists, wishes, savings, board layout, profile vibe, and appearance preferences are saved locally so they survive app restarts. Demo mode does not upload them to a Wishlist server yet.',
          ),
          const Gap(10),
          const _Section(
            title: 'Photos',
            body:
                'Camera and gallery picks stay as local file paths on your phone. We do not upload images in this demo build.',
          ),
          const Gap(10),
          const _Section(
            title: 'Sign-in',
            body:
                'Phone/email OTP, Google, and Apple buttons on this build complete a local demo session only. No passwords or OAuth tokens are sent to a backend until you connect a real API.',
          ),
          const Gap(10),
          const _Section(
            title: 'Sharing',
            body:
                'Share links and email invites are generated on device. Invites are logged locally and can open your mail app — they are not delivered by Wishlist servers in demo mode.',
          ),
          const Gap(10),
          const _Section(
            title: 'Controls',
            body:
                'Sign out clears the signed-in flag. Deleting wishes moves them to Bin; Empty bin removes them permanently from local storage. Uninstalling the app removes local data.',
          ),
          const Gap(10),
          const _Section(
            title: 'Questions',
            body:
                'Email hello@wishlist.app. When the production API ships, this page will be updated with the full privacy policy URL.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return StickerCard(
      color: context.wishCardFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Gap(6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
