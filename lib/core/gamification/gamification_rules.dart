/// Stardust / streak / level math for the demo frontend (SRD gamification).
abstract final class GamificationRules {
  static const maxLevel = 30;

  /// Stardust granted per action.
  static const createList = 10;
  static const addWish = 10;
  static const addSavings = 15;
  static const jarDraw = 5;
  static const grantWish = 100;
  static const dailyStreakBonus = 5;

  /// XP needed to advance from [level] → [level] + 1.
  static int xpToAdvance(int level) {
    final safe = level.clamp(1, maxLevel);
    return 100 + (safe - 1) * 50;
  }

  /// Cumulative XP required to *reach* [level] (level 1 = 0).
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    var total = 0;
    for (var l = 1; l < level && l < maxLevel; l++) {
      total += xpToAdvance(l);
    }
    return total;
  }

  static int levelFromStardust(int stardust) {
    var level = 1;
    var remaining = stardust;
    while (level < maxLevel) {
      final need = xpToAdvance(level);
      if (remaining < need) break;
      remaining -= need;
      level++;
    }
    return level;
  }

  static LevelProgress progress({
    required int stardustTotal,
    required int level,
  }) {
    final floor = xpForLevel(level);
    final need = xpToAdvance(level);
    final into = (stardustTotal - floor).clamp(0, need);
    final atCap = level >= maxLevel;
    return LevelProgress(
      level: level,
      intoLevel: atCap ? need : into,
      needForNext: need,
      progress: atCap ? 1 : (need == 0 ? 0 : into / need),
      stardustToNext: atCap ? 0 : (need - into).clamp(0, need),
      atCap: atCap,
    );
  }

  static const streakMilestones = [3, 7, 14, 30, 60, 100];

  static String streakLabel(int days) {
    if (days <= 0) return 'Light the Wish Flame';
    if (days == 1) return 'Flame lit';
    if (days < 7) return 'Warming up';
    if (days < 14) return 'On fire';
    if (days < 30) return 'Wish Wizard streak';
    return 'Legendary flame';
  }

  static String flameEmoji(int days) {
    if (days <= 0) return '🕯️';
    if (days < 3) return '🔥';
    if (days < 7) return '🔥';
    if (days < 14) return '🧡';
    return '🌟';
  }
}

class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.intoLevel,
    required this.needForNext,
    required this.progress,
    required this.stardustToNext,
    required this.atCap,
  });

  final int level;
  final int intoLevel;
  final int needForNext;
  final double progress;
  final int stardustToNext;
  final bool atCap;
}

class AwardEvent {
  const AwardEvent({
    required this.amount,
    required this.reason,
    this.leveledUpTo,
    this.streakDays,
    this.streakExtended = false,
  });

  final int amount;
  final String reason;
  final int? leveledUpTo;
  final int? streakDays;
  final bool streakExtended;
}
