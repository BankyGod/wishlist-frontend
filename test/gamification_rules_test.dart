import 'package:flutter_test/flutter_test.dart';
import 'package:wishlist/core/gamification/gamification_rules.dart';
import 'package:wishlist/features/lists/data/demo_store.dart';
import 'package:wishlist/features/lists/domain/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GamificationRules', () {
    test('levelFromStardust climbs with XP curve', () {
      expect(GamificationRules.levelFromStardust(0), 1);
      expect(GamificationRules.levelFromStardust(99), 1);
      expect(GamificationRules.levelFromStardust(100), 2);
      expect(GamificationRules.levelFromStardust(249), 2);
      expect(GamificationRules.levelFromStardust(250), 3);
    });

    test('progress reports remaining to next level', () {
      final p = GamificationRules.progress(stardustTotal: 120, level: 2);
      expect(p.intoLevel, 20);
      expect(p.needForNext, 150);
      expect(p.stardustToNext, 130);
    });
  });

  group('DemoStore streak', () {
    test('first activity starts streak and awards daily bonus', () {
      final store = DemoStore();
      store.hydrated = false;
      store.profile = store.profile.copyWith(
        streakDays: 0,
        bestStreakDays: 0,
        clearLastStreakDate: true,
        stardustTotal: 0,
        level: 1,
      );

      final before = store.profile.stardustTotal;
      store.addWish(
        listId: store.lists.first.id,
        imageUrls: const ['https://example.com/x.jpg'],
        title: 'Streak wish',
      );

      expect(store.profile.streakDays, 1);
      expect(
        store.profile.stardustTotal,
        before +
            GamificationRules.addWish +
            GamificationRules.dailyStreakBonus,
      );
      expect(store.lastAward?.streakExtended, isTrue);
    });

    test('second activity same day does not double streak bonus', () {
      final store = DemoStore();
      store.hydrated = false;
      store.profile = store.profile.copyWith(
        streakDays: 1,
        lastStreakDate: DateTime.now(),
        stardustTotal: 50,
        level: 1,
      );
      final before = store.profile.stardustTotal;
      store.addWish(
        listId: store.lists.first.id,
        imageUrls: const ['https://example.com/y.jpg'],
        title: 'Second',
      );
      expect(store.profile.streakDays, 1);
      expect(
        store.profile.stardustTotal,
        before + GamificationRules.addWish,
      );
    });

    test('missed day resets active streak on refresh', () {
      final store = DemoStore();
      store.hydrated = false;
      store.profile = store.profile.copyWith(
        streakDays: 5,
        lastStreakDate: DateTime.now().subtract(const Duration(days: 3)),
      );
      store.refreshStreakStatus();
      expect(store.profile.streakDays, 0);
    });
  });
}
