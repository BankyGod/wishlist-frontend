import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/gamification/gamification_rules.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/gamification_cards.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class StardustScreen extends ConsumerWidget {
  const StardustScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(demoStoreProvider);
    final profile = store.profile;
    final progress = GamificationRules.progress(
      stardustTotal: profile.stardustTotal,
      level: profile.level,
    );
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Stardust & streak')),
      body: ListView(
        padding: context.wishScrollPadding(extraBottom: 32),
        children: [
          MeGamificationPanel(profile: profile),
          const Gap(20),
          Text('How you earn', style: text.headlineSmall),
          const Gap(8),
          const _EarnRow(
            emoji: '📋',
            title: 'Create a list',
            amount: GamificationRules.createList,
          ),
          const _EarnRow(
            emoji: '✨',
            title: 'Add a wish',
            amount: GamificationRules.addWish,
          ),
          const _EarnRow(
            emoji: '💰',
            title: 'Log savings',
            amount: GamificationRules.addSavings,
          ),
          const _EarnRow(
            emoji: '🫙',
            title: 'Shake the Wish Jar',
            amount: GamificationRules.jarDraw,
          ),
          const _EarnRow(
            emoji: '🏆',
            title: 'Grant a wish',
            amount: GamificationRules.grantWish,
          ),
          const _EarnRow(
            emoji: '🔥',
            title: 'First action of the day',
            amount: GamificationRules.dailyStreakBonus,
            subtitle: 'Bonus on top of whatever you did',
          ),
          const Gap(20),
          Text('Wish Flame', style: text.headlineSmall),
          const Gap(8),
          StickerCard(
            color: scheme.primary.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do one wishful thing a day — add, save, shake, or grant — to keep the flame lit. Miss a day and it cools to zero (your best streak is saved).',
                  style: text.bodyMedium,
                ),
                const Gap(12),
                Text(
                  'Milestones: ${GamificationRules.streakMilestones.join(' · ')} days',
                  style: text.labelLarge?.copyWith(color: scheme.primary),
                ),
                const Gap(8),
                Text(
                  'Now: ${profile.streakDays} · Best: ${profile.bestStreakDays} · ${GamificationRules.streakLabel(profile.streakDays)}',
                  style: text.titleSmall,
                ),
              ],
            ),
          ),
          const Gap(20),
          Text('Level track', style: text.headlineSmall),
          const Gap(8),
          StickerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${profile.level} · ${profile.levelTitle}',
                  style: text.titleMedium,
                ),
                const Gap(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.progress.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                    color: scheme.secondary,
                  ),
                ),
                const Gap(8),
                Text(
                  progress.atCap
                      ? 'Max level reached'
                      : '${progress.intoLevel} / ${progress.needForNext} XP · ${progress.stardustToNext} stardust to level ${profile.level + 1}',
                  style: text.bodySmall?.copyWith(color: context.wishMutedInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnRow extends StatelessWidget {
  const _EarnRow({
    required this.emoji,
    required this.title,
    required this.amount,
    this.subtitle,
  });

  final String emoji;
  final String title;
  final int amount;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: StickerCard(
        color: context.wishCardFill,
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.wishMutedInk,
                          ),
                    ),
                ],
              ),
            ),
            Text(
              '+$amount ✨',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
