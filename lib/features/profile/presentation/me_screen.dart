import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_theme.dart';
import 'package:wishlist/core/widgets/brand_logo.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(demoStoreProvider);
    final profile = store.profile;
    final badges = store.badges.where((b) => b.unlocked).take(6).toList();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final outline = context.wishOutline;
    final cardFill = context.wishCardFill;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            children: [
              const BrandLogo(size: 44, showShadow: false),
              const Gap(10),
              Text('Me', style: text.headlineMedium),
              const Spacer(),
              IconButton(
                onPressed: () => context.push('/settings'),
                style: IconButton.styleFrom(
                  backgroundColor: cardFill,
                  side: BorderSide(color: outline, width: 2),
                ),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const Gap(12),
          StickerCard(
            color: cardFill,
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(profile.favouriteColor),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: outline, width: 2.5),
                  ),
                  child: Text(
                    profile.avatarEmoji,
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.displayName, style: text.headlineSmall),
                      Text('@${profile.handle}', style: text.bodyMedium),
                      Text(
                        'Level ${profile.level} · ${profile.levelTitle}',
                        style: text.titleSmall?.copyWith(color: scheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          StickerCard(
            color: scheme.secondary.withValues(alpha: 0.28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('✨ Stardust', style: text.titleLarge),
                Text(
                  '${profile.stardustTotal}',
                  style: context.wishNumberStyle.copyWith(color: scheme.primary),
                ),
              ],
            ),
          ),
          const Gap(12),
          StickerCard(
            color: scheme.primary.withValues(alpha: 0.16),
            child: Text(
              '🔥 ${profile.streakDays}-day Wish Streak',
              style: text.titleMedium,
            ),
          ),
          const Gap(20),
          Row(
            children: [
              Text('Badges', style: text.headlineSmall),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/trophies'),
                child: const Text('Trophy room'),
              ),
            ],
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final b in badges)
                StickerCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: cardFill,
                  child: Text('${b.emoji}  ${b.name}', style: text.labelLarge),
                ),
            ],
          ),
          const Gap(20),
          StickerButton(
            label: 'Open settings',
            expand: true,
            filled: false,
            icon: Icons.settings_outlined,
            onPressed: () => context.push('/settings'),
          ),
          const Gap(8),
          StickerButton(
            label: 'Notifications inbox',
            expand: true,
            filled: false,
            icon: Icons.notifications_outlined,
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }
}
