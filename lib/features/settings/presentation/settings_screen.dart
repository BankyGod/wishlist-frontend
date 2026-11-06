import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/motion/feedback.dart';
import 'package:wishlist/core/motion/motion_tokens.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(wishlistThemeProvider);
    final themeNotifier = ref.read(wishlistThemeProvider.notifier);
    final store = ref.read(demoStoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: context.wishScrollPadding(),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleSmall),
          const Gap(8),
          StickerCard(
            onTap: () => context.push('/settings/appearance'),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Theme & fonts'),
              subtitle: Text(
                '${themeData.palette.label} · ${themeData.fontPack.label}',
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const Gap(16),
          Text('Experience', style: Theme.of(context).textTheme.titleSmall),
          const Gap(8),
          StickerCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.volume_up_outlined),
              title: const Text('Sound'),
              subtitle: const Text('Clicks & celebration cues'),
              value: themeData.soundsEnabled,
              onChanged: (v) async {
                themeNotifier.update((t) => t.copyWith(soundsEnabled: v));
                if (v) {
                  // Small delay so the gate flip applies before preview.
                  await Future<void>.delayed(const Duration(milliseconds: 16));
                  await WishlistFeedback.previewSound();
                }
              },
            ),
          ),
          const Gap(8),
          StickerCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.vibration_outlined),
              title: const Text('Haptics'),
              subtitle: const Text('Vibrate on taps & grants'),
              value: themeData.hapticsEnabled,
              onChanged: (v) async {
                themeNotifier.update((t) => t.copyWith(hapticsEnabled: v));
                if (v) {
                  await Future<void>.delayed(const Duration(milliseconds: 16));
                  await WishlistFeedback.previewHaptics();
                }
              },
            ),
          ),
          const Gap(8),
          StickerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.animation_outlined),
                  title: Text('Animations'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: SegmentedButton<AnimationLevel>(
                    segments: const [
                      ButtonSegment(
                        value: AnimationLevel.full,
                        label: Text('Full'),
                      ),
                      ButtonSegment(
                        value: AnimationLevel.reduced,
                        label: Text('Reduced'),
                      ),
                      ButtonSegment(
                        value: AnimationLevel.off,
                        label: Text('Off'),
                      ),
                    ],
                    selected: {themeData.animationLevel},
                    onSelectionChanged: (s) {
                      themeNotifier.update(
                        (t) => t.copyWith(animationLevel: s.first),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          StickerCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.celebration_outlined),
              title: const Text('Confetti'),
              value: themeData.confettiEnabled,
              onChanged: (v) =>
                  themeNotifier.update((t) => t.copyWith(confettiEnabled: v)),
            ),
          ),
          const Gap(8),
          StickerCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.data_saver_off_outlined),
              title: const Text('Data saver'),
              subtitle: const Text('Lighter images & fewer animations'),
              value: themeData.dataSaver,
              onChanged: (v) =>
                  themeNotifier.update((t) => t.copyWith(dataSaver: v)),
            ),
          ),
          const Gap(8),
          StickerCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.spa_outlined),
              title: const Text('Calm mode'),
              subtitle: const Text('Turn off gamification nudges'),
              value: themeData.calmMode,
              onChanged: (v) =>
                  themeNotifier.update((t) => t.copyWith(calmMode: v)),
            ),
          ),
          const Gap(16),
          Text('Support', style: Theme.of(context).textTheme.titleSmall),
          const Gap(8),
          StickerCard(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help centre coming soon')),
              );
            },
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.help_outline),
              title: Text('Help'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const Gap(8),
          StickerCard(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy (demo stub)')),
              );
            },
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('Privacy'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const Gap(8),
          StickerCard(
            onTap: () => context.push('/bin'),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline),
              title: Text('Bin'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const Gap(16),
          StickerCard(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
            onTap: () {
              store.signOut();
              context.go('/auth');
            },
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Sign out',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
