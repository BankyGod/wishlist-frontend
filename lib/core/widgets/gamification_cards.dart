import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import 'package:wishlist/core/gamification/gamification_rules.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_theme.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/features/lists/domain/models.dart';

class GamificationStrip extends StatelessWidget {
  const GamificationStrip({
    super.key,
    required this.profile,
    this.onTapStardust,
    this.onTapStreak,
  });

  final UserProfile profile;
  final VoidCallback? onTapStardust;
  final VoidCallback? onTapStreak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StardustCard(
            profile: profile,
            onTap: onTapStardust,
          ),
        ),
        const Gap(10),
        Expanded(
          child: StreakCard(
            profile: profile,
            onTap: onTapStreak,
          ),
        ),
      ],
    );
  }
}

class StardustCard extends StatelessWidget {
  const StardustCard({
    super.key,
    required this.profile,
    this.onTap,
    this.compact = true,
  });

  final UserProfile profile;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final progress = GamificationRules.progress(
      stardustTotal: profile.stardustTotal,
      level: profile.level,
    );
    final animate = context.wishAllowDecorativeMotion;

    return StickerCard(
      onTap: onTap,
      color: scheme.secondary.withValues(alpha: 0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '✨',
                style: TextStyle(fontSize: compact ? 18 : 28),
              )
                  .animate(target: animate ? 1 : 0)
                  .shimmer(duration: 1800.ms, delay: 400.ms),
              const Gap(6),
              Text('Stardust', style: text.titleSmall),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: context.wishMutedInk,
                ),
            ],
          ),
          const Gap(4),
          Text(
            '${profile.stardustTotal}',
            style: context.wishNumberStyle.copyWith(
              fontSize: compact ? 28 : 40,
              color: scheme.primary,
            ),
          ),
          const Gap(6),
          Text(
            progress.atCap
                ? 'Max level · ${profile.levelTitle}'
                : 'Lvl ${profile.level} · ${progress.stardustToNext} to next',
            style: text.labelMedium?.copyWith(color: context.wishMutedInk),
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              color: scheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.profile,
    this.onTap,
    this.compact = true,
  });

  final UserProfile profile;
  final VoidCallback? onTap;
  final bool compact;

  List<bool> _weekLit() {
    final today = DateTime.now();
    final weekday = today.weekday; // 1=Mon … 7=Sun
    final last = profile.lastStreakDate;
    final lit = List<bool>.filled(7, false);
    if (profile.streakDays <= 0 || last == null) return lit;

    final lastDay = DateTime(last.year, last.month, last.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final gap = todayDay.difference(lastDay).inDays;
    if (gap > 1) return lit;

    // Light the last [streakDays] days ending at last active day.
    final activeWeekday = lastDay.weekday;
    for (var i = 0; i < profile.streakDays && i < 7; i++) {
      final dayIndex = (activeWeekday - 1 - i) % 7;
      final idx = dayIndex < 0 ? dayIndex + 7 : dayIndex;
      lit[idx] = true;
    }
    // Soft-dim future weekdays after today.
    for (var i = weekday; i < 7; i++) {
      // leave as-is if already lit from wrap; usually empty
    }
    return lit;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final days = profile.streakDays;
    final flame = GamificationRules.flameEmoji(days);
    final label = GamificationRules.streakLabel(days);
    final lit = _weekLit();
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final animate = context.wishAllowDecorativeMotion;

    return StickerCard(
      onTap: onTap,
      color: scheme.primary.withValues(alpha: 0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(flame, style: TextStyle(fontSize: compact ? 18 : 28))
                  .animate(target: animate && days > 0 ? 1 : 0)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.08, 1.08),
                    duration: 900.ms,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.08, 1.08),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                  ),
              const Gap(6),
              Text('Streak', style: text.titleSmall),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: context.wishMutedInk,
                ),
            ],
          ),
          const Gap(4),
          Text(
            days <= 0 ? '0' : '$days',
            style: context.wishNumberStyle.copyWith(
              fontSize: compact ? 28 : 40,
              color: scheme.primary,
            ),
          ),
          Text(
            days <= 0 ? 'days · light it today' : (days == 1 ? 'day' : 'days'),
            style: text.labelMedium?.copyWith(color: context.wishMutedInk),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                Column(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: lit[i]
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.08),
                        border: Border.all(
                          color: lit[i]
                              ? scheme.primary
                              : context.wishOutline.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: lit[i]
                          ? const Text('🔥', style: TextStyle(fontSize: 9))
                          : null,
                    ),
                    const Gap(2),
                    Text(
                      labels[i],
                      style: text.labelSmall?.copyWith(
                        fontSize: 9,
                        color: context.wishMutedInk,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Gap(6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MeGamificationPanel extends StatelessWidget {
  const MeGamificationPanel({
    super.key,
    required this.profile,
    this.onOpenDetails,
  });

  final UserProfile profile;
  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final progress = GamificationRules.progress(
      stardustTotal: profile.stardustTotal,
      level: profile.level,
    );
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        StardustCard(profile: profile, onTap: onOpenDetails, compact: false),
        const Gap(12),
        StreakCard(profile: profile, onTap: onOpenDetails, compact: false),
        const Gap(12),
        StickerCard(
          onTap: onOpenDetails,
          color: context.wishCardFill,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${profile.level} · ${profile.levelTitle}',
                      style: text.titleMedium,
                    ),
                    const Gap(4),
                    Text(
                      progress.atCap
                          ? 'You’ve collected every star in the sky.'
                          : '${progress.intoLevel} / ${progress.needForNext} XP this level',
                      style: text.bodySmall?.copyWith(
                        color: context.wishMutedInk,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Best streak · ${profile.bestStreakDays} days',
                      style: text.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.auto_awesome, color: scheme.secondary),
            ],
          ),
        ),
      ],
    );
  }
}
