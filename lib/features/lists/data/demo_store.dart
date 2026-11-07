import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:wishlist/core/gamification/gamification_rules.dart';

import 'demo_store_codec.dart';
import '../domain/models.dart';

/// In-memory demo store (SRD FE-11) with local JSON persistence.
class DemoStore extends ChangeNotifier {
  DemoStore() {
    _seed();
    _hydrateFuture = _hydrate();
  }

  final _uuid = const Uuid();
  final lists = <WishList>[];
  final wishes = <Wish>[];
  final savings = <SavingsEntry>[];
  final boardItems = <BoardItem>[];
  final notifications = <AppNotification>[];
  final badges = <BadgeItem>[];
  final invites = <ListInvite>[];
  late UserProfile profile;
  bool onboardingComplete = false;
  bool signedIn = false;
  SyncState syncState = SyncState.synced;
  bool hydrated = false;
  late final Future<void> _hydrateFuture;
  Timer? _persistDebounce;
  AwardEvent? lastAward;

  Future<void> ensureHydrated() => _hydrateFuture;

  void clearLastAward() {
    if (lastAward == null) return;
    lastAward = null;
    notifyListeners();
  }

  void _seed() {
    profile = UserProfile(
      id: 'user-demo',
      displayName: 'Ama',
      handle: 'ama_accra',
      email: 'ama@example.com',
      favouriteColor: 0xFF6C3CE0,
      avatarEmoji: '✨',
      stardustTotal: 420,
      level: GamificationRules.levelFromStardust(420),
      streakDays: 7,
      bestStreakDays: 7,
      lastStreakDate: DateTime.now(),
      currencyDefault: 'GHS',
    );

    final someday = WishList(
      id: 'list-someday',
      name: 'Someday',
      icon: '🌈',
      coverColor: 0xFF6C3CE0,
      description: 'Big dreams for later',
      sortOrder: 0,
      pinned: true,
    );
    final birthday = WishList(
      id: 'list-birthday',
      name: 'Birthday',
      icon: '🎂',
      coverColor: 0xFFE4357E,
      targetDate: DateTime.now().add(const Duration(days: 42)),
      sortOrder: 1,
      pinned: true,
    );
    final gifts = WishList(
      id: 'list-gifts',
      name: 'Gifts for Others',
      icon: '🎁',
      coverColor: 0xFF0E9F6E,
      sortOrder: 2,
    );
    lists.addAll([someday, birthday, gifts]);

    wishes.addAll([
      Wish(
        id: 'wish-1',
        listId: someday.id,
        title: 'MacBook Air',
        note: 'For school projects and design work',
        whyText: 'I want to create without lagging',
        priceAmount: 9500,
        priority: 5,
        category: 'Tech',
        tags: const ['laptop', 'school'],
        mood: MoodSticker.dream,
        frameStyle: FrameStyle.polaroid,
        imageUrls: const [
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
        ],
        savingsGoalAmount: 9500,
        savingsTotal: 3200,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Wish(
        id: 'wish-2',
        listId: someday.id,
        title: 'Trip to Cape Coast',
        note: 'Weekend with friends',
        priceAmount: 1200,
        priority: 4,
        category: 'Travel',
        mood: MoodSticker.treat,
        frameStyle: FrameStyle.tornPaper,
        imageUrls: const [
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        ],
        savingsGoalAmount: 1200,
        savingsTotal: 450,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Wish(
        id: 'wish-3',
        listId: birthday.id,
        title: 'Nike Dunks',
        priceAmount: 980,
        priority: 5,
        category: 'Fashion',
        mood: MoodSticker.fire,
        frameStyle: FrameStyle.neon,
        imageUrls: const [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        ],
        savingsGoalAmount: 980,
        savingsTotal: 200,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Wish(
        id: 'wish-4',
        listId: birthday.id,
        title: 'Polaroid camera',
        priceAmount: 650,
        priority: 3,
        category: 'Gadgets',
        mood: MoodSticker.need,
        frameStyle: FrameStyle.filmStrip,
        imageUrls: const [
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Wish(
        id: 'wish-5',
        listId: gifts.id,
        title: 'Cookbook for Mum',
        priceAmount: 180,
        priority: 4,
        category: 'Gift',
        mood: MoodSticker.someday,
        frameStyle: FrameStyle.stickyNote,
        imageUrls: const [
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Wish(
        id: 'wish-6',
        listId: someday.id,
        title: 'Wireless headphones',
        priceAmount: 750,
        priority: 4,
        status: WishStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 14)),
        grantedPrice: 720,
        grantedNote: 'Finally quiet study sessions!',
        frameStyle: FrameStyle.gold,
        imageUrls: const [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
    ]);

    for (var i = 0; i < wishes.length; i++) {
      final w = wishes[i];
      if (w.status == WishStatus.open) {
        boardItems.add(
          BoardItem(
            id: 'board-$i',
            listId: w.listId,
            wishId: w.id,
            x: 40.0 + (i % 3) * 110,
            y: 60.0 + (i ~/ 3) * 140,
            scale: 0.9 + (i % 3) * 0.08,
            rotation: (-8 + i * 3) * pi / 180,
            zIndex: i,
          ),
        );
      }
    }

    savings.addAll([
      SavingsEntry(
        id: 'sav-1',
        wishId: 'wish-1',
        amount: 1000,
        currency: 'GHS',
        entryDate: DateTime.now().subtract(const Duration(days: 15)),
        note: 'Allowance',
      ),
      SavingsEntry(
        id: 'sav-2',
        wishId: 'wish-1',
        amount: 1200,
        currency: 'GHS',
        entryDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
      SavingsEntry(
        id: 'sav-3',
        wishId: 'wish-1',
        amount: 1000,
        currency: 'GHS',
        entryDate: DateTime.now().subtract(const Duration(days: 2)),
        note: 'Side hustle',
      ),
    ]);

    notifications.addAll([
      AppNotification(
        id: 'n1',
        title: 'Streak on fire 🔥',
        body: 'Day 7! Keep the Wish flame going.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'streak',
      ),
      AppNotification(
        id: 'n2',
        title: 'Savings milestone',
        body: 'You hit 25% on MacBook Air!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        category: 'savings',
        read: true,
      ),
    ]);

    badges.addAll(const [
      BadgeItem(
        id: 'b1',
        name: 'First Wish',
        description: 'Add your first wish',
        emoji: '🌠',
        unlocked: true,
      ),
      BadgeItem(
        id: 'b2',
        name: 'Photo Snapper',
        description: 'Add 5 wishes with photos',
        emoji: '📸',
        unlocked: true,
      ),
      BadgeItem(
        id: 'b3',
        name: 'Saver',
        description: 'Log 3 savings entries',
        emoji: '💰',
        unlocked: true,
      ),
      BadgeItem(
        id: 'b4',
        name: 'Granted!',
        description: 'Grant your first wish',
        emoji: '🏆',
        unlocked: true,
      ),
      BadgeItem(
        id: 'b5',
        name: 'Jar Shaker',
        description: 'Use the Wish Jar 10 times',
        emoji: '🫙',
      ),
      BadgeItem(
        id: 'b6',
        name: 'Board Artist',
        description: 'Arrange 10 items on a Vision Board',
        emoji: '🎨',
      ),
      BadgeItem(
        id: 'b7',
        name: 'Streak Week',
        description: '7-day streak',
        emoji: '🔥',
        unlocked: true,
      ),
      BadgeItem(
        id: 'b8',
        name: 'Generous',
        description: 'Share a list',
        emoji: '🤝',
      ),
      BadgeItem(
        id: 'b9',
        name: 'Visionary',
        description: 'Pin 5 wishes on a board',
        emoji: '🪄',
      ),
      BadgeItem(
        id: 'b10',
        name: 'Halfway Hero',
        description: 'Reach 50% savings on any wish',
        emoji: '🎯',
      ),
      BadgeItem(
        id: 'b11',
        name: 'Full Jar',
        description: 'Save 100% toward a wish',
        emoji: '🫙',
      ),
      BadgeItem(
        id: 'b12',
        name: 'Night Owl',
        description: 'Log savings after midnight',
        emoji: '🦉',
      ),
    ]);
  }

  List<Wish> wishesForList(String listId, {WishStatus? status}) {
    return wishes
        .where(
          (w) =>
              !w.isDeleted &&
              w.listId == listId &&
              (status == null || w.status == status),
        )
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<Wish> get openWishes => wishes
      .where((w) => !w.isDeleted && w.status == WishStatus.open)
      .toList();

  List<Wish> get grantedWishes => wishes
      .where((w) => !w.isDeleted && w.status == WishStatus.granted)
      .toList();

  List<Wish> get binnedWishes =>
      wishes.where((w) => w.isDeleted).toList()
        ..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));

  Wish? wishById(String id) {
    try {
      return wishes.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  WishList? listById(String id) {
    try {
      return lists.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  int wishCount(String listId) =>
      wishes.where((w) => !w.isDeleted && w.listId == listId).length;

  int grantedCount(String listId) => wishes
      .where(
        (w) =>
            !w.isDeleted &&
            w.listId == listId &&
            w.status == WishStatus.granted,
      )
      .length;

  void completeOnboarding() {
    onboardingComplete = true;
    _touch();
  }

  void signInAsGuest() {
    signedIn = true;
    onboardingComplete = true;
    profile = profile.copyWith(isGuest: true, displayName: 'Guest');
    _touch();
  }

  void signIn({
    String? displayName,
    String? email,
    String? phone,
    String? handle,
  }) {
    signedIn = true;
    onboardingComplete = true;
    profile = profile.copyWith(
      isGuest: false,
      displayName: displayName ?? profile.displayName,
      email: email ?? profile.email,
      phone: phone ?? profile.phone,
      handle: handle ?? profile.handle,
    );
    _touch();
  }

  void signOut() {
    signedIn = false;
    _touch();
  }

  void updateProfile(UserProfile next) {
    profile = next;
    _touch();
  }

  WishList createList({
    required String name,
    required String icon,
    required int coverColor,
    String? description,
  }) {
    final list = WishList(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      coverColor: coverColor,
      description: description,
      sortOrder: lists.length,
    );
    lists.add(list);
    _award(GamificationRules.createList, reason: 'New list');
    _touch();
    return list;
  }

  Wish addWish({
    required String listId,
    required List<String> imageUrls,
    String title = '',
    double? price,
    String? note,
  }) {
    final wish = Wish(
      id: _uuid.v4(),
      listId: listId,
      imageUrls: imageUrls,
      title: title,
      note: note ?? '',
      priceAmount: price,
      savingsGoalAmount: price,
      createdAt: DateTime.now(),
      sortOrder: wishes.length,
    );
    wishes.add(wish);
    boardItems.add(
      BoardItem(
        id: _uuid.v4(),
        listId: listId,
        wishId: wish.id,
        x: 80 + Random().nextDouble() * 160,
        y: 80 + Random().nextDouble() * 200,
        rotation: (Random().nextDouble() - 0.5) * 0.3,
        zIndex: boardItems.length,
      ),
    );
    _award(GamificationRules.addWish, reason: 'New wish');
    _touch();
    return wish;
  }

  void updateWish(Wish wish) {
    final i = wishes.indexWhere((w) => w.id == wish.id);
    if (i >= 0) {
      wishes[i] = wish;
      _touch();
    }
  }

  void setWishStatus(String id, WishStatus status) {
    final wish = wishById(id);
    if (wish == null || wish.isDeleted) return;
    updateWish(wish.copyWith(status: status));
  }

  /// Soft-delete — wish stays in [binnedWishes] until restored or purged.
  void deleteWish(String id) {
    final wish = wishById(id);
    if (wish == null || wish.isDeleted) return;
    boardItems.removeWhere((b) => b.wishId == id);
    updateWish(wish.copyWith(deletedAt: DateTime.now()));
  }

  void restoreWish(Wish wish) {
    final i = wishes.indexWhere((w) => w.id == wish.id);
    if (i >= 0) {
      wishes[i] = wishes[i].copyWith(clearDeletedAt: true);
      _touch();
      return;
    }
    wishes.add(wish.copyWith(clearDeletedAt: true));
    _touch();
  }

  void restoreWishById(String id) {
    final wish = wishById(id);
    if (wish == null) return;
    restoreWish(wish);
  }

  void permanentlyDeleteWish(String id) {
    wishes.removeWhere((w) => w.id == id);
    boardItems.removeWhere((b) => b.wishId == id);
    savings.removeWhere((s) => s.wishId == id);
    _touch();
  }

  void emptyBin() {
    final ids = binnedWishes.map((w) => w.id).toSet();
    wishes.removeWhere((w) => ids.contains(w.id));
    boardItems.removeWhere((b) => ids.contains(b.wishId));
    savings.removeWhere((s) => ids.contains(s.wishId));
    _touch();
  }

  void updateList(WishList list) {
    final i = lists.indexWhere((l) => l.id == list.id);
    if (i >= 0) {
      lists[i] = list;
      _touch();
    }
  }

  void archiveList(String id, {required bool archived}) {
    final list = listById(id);
    if (list == null) return;
    updateList(list.copyWith(archived: archived));
  }

  void togglePinList(String id) {
    final list = listById(id);
    if (list == null) return;
    updateList(list.copyWith(pinned: !list.pinned));
  }

  ListInvite inviteByEmail({
    required String listId,
    required String email,
  }) {
    final invite = ListInvite(
      id: _uuid.v4(),
      listId: listId,
      email: email.trim(),
      sentAt: DateTime.now(),
    );
    invites.add(invite);
    final list = listById(listId);
    if (list != null && list.privacy == ListPrivacy.private) {
      updateList(list.copyWith(privacy: ListPrivacy.invite));
    } else {
      _touch();
    }
    return invite;
  }

  List<ListInvite> invitesForList(String listId) =>
      invites.where((i) => i.listId == listId).toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

  void grantWish(
    String id, {
    double? paid,
    String? note,
  }) {
    final wish = wishById(id);
    if (wish == null) return;
    updateWish(
      wish.copyWith(
        status: WishStatus.granted,
        grantedAt: DateTime.now(),
        grantedPrice: paid ?? wish.priceAmount,
        grantedNote: note,
      ),
    );
    boardItems.removeWhere((b) => b.wishId == id);
    _unlockBadge('b4');
    _award(GamificationRules.grantWish, reason: 'Wish granted');
    _touch();
  }

  void _unlockBadge(String id) {
    final i = badges.indexWhere((b) => b.id == id);
    if (i >= 0 && !badges[i].unlocked) {
      badges[i] = BadgeItem(
        id: badges[i].id,
        name: badges[i].name,
        description: badges[i].description,
        emoji: badges[i].emoji,
        unlocked: true,
      );
    }
  }

  void addSavings(String wishId, double amount, {String? note}) {
    final wish = wishById(wishId);
    if (wish == null) return;
    savings.add(
      SavingsEntry(
        id: _uuid.v4(),
        wishId: wishId,
        amount: amount,
        currency: wish.priceCurrency,
        entryDate: DateTime.now(),
        note: note,
      ),
    );
    updateWish(wish.copyWith(savingsTotal: wish.savingsTotal + amount));
    _award(GamificationRules.addSavings, reason: 'Savings logged');
    _schedulePersist();
  }

  void updateBoardItem(BoardItem item) {
    final i = boardItems.indexWhere((b) => b.id == item.id);
    if (i >= 0) {
      boardItems[i] = item;
      _touch();
    }
  }

  Wish? drawFromJar() {
    final open = openWishes;
    if (open.isEmpty) return null;
    final weighted = <Wish>[];
    for (final w in open) {
      for (var i = 0; i < w.priority; i++) {
        weighted.add(w);
      }
    }
    final pick = weighted[Random().nextInt(weighted.length)];
    _award(GamificationRules.jarDraw, reason: 'Jar shake');
    _schedulePersist();
    return pick;
  }

  void markNotificationRead(String id) {
    final i = notifications.indexWhere((n) => n.id == id);
    if (i >= 0) {
      notifications[i] = notifications[i].copyWith(read: true);
      _touch();
    }
  }

  /// Call when the user opens the app so a broken streak can cool off visually.
  void refreshStreakStatus() {
    final today = _dateOnly(DateTime.now());
    final last = profile.lastStreakDate;
    if (last == null) return;
    final lastDay = _dateOnly(last);
    final gap = today.difference(lastDay).inDays;
    if (gap <= 1) return;
    // Missed a day — flame goes out until the next activity.
    if (profile.streakDays > 0) {
      profile = profile.copyWith(streakDays: 0);
      _touch();
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Returns true on the first awarding activity of the calendar day.
  bool _bumpStreak() {
    final today = _dateOnly(DateTime.now());
    final last = profile.lastStreakDate;
    if (last != null && _dateOnly(last) == today) {
      return false;
    }

    var nextStreak = 1;
    if (last != null) {
      final gap = today.difference(_dateOnly(last)).inDays;
      if (gap == 1) {
        nextStreak = profile.streakDays <= 0 ? 1 : profile.streakDays + 1;
      } else {
        nextStreak = 1;
      }
    }

    final best = nextStreak > profile.bestStreakDays
        ? nextStreak
        : profile.bestStreakDays;

    profile = profile.copyWith(
      streakDays: nextStreak,
      bestStreakDays: best,
      lastStreakDate: today,
    );

    if (nextStreak >= 7) _unlockBadge('b7');

    if (GamificationRules.streakMilestones.contains(nextStreak)) {
      notifications.insert(
        0,
        AppNotification(
          id: _uuid.v4(),
          title: 'Streak on fire ${GamificationRules.flameEmoji(nextStreak)}',
          body:
              '$nextStreak-day Wish Flame — ${GamificationRules.streakLabel(nextStreak)}!',
          createdAt: DateTime.now(),
          category: 'streak',
        ),
      );
    }
    return true;
  }

  void _award(int stardust, {required String reason}) {
    final previousLevel = profile.level;
    final firstToday = _bumpStreak();
    var amount = stardust;
    if (firstToday) {
      amount += GamificationRules.dailyStreakBonus;
    }

    final nextTotal = profile.stardustTotal + amount;
    final nextLevel = GamificationRules.levelFromStardust(nextTotal);
    profile = profile.copyWith(
      stardustTotal: nextTotal,
      level: nextLevel,
    );

    if (nextLevel > previousLevel) {
      notifications.insert(
        0,
        AppNotification(
          id: _uuid.v4(),
          title: 'Level up · ${profile.levelTitle}',
          body: 'You reached level $nextLevel with $nextTotal stardust.',
          createdAt: DateTime.now(),
          category: 'level',
        ),
      );
    }

    lastAward = AwardEvent(
      amount: amount,
      reason: reason,
      leveledUpTo: nextLevel > previousLevel ? nextLevel : null,
      streakDays: profile.streakDays,
      streakExtended: firstToday,
    );
  }

  void _touch() {
    notifyListeners();
    _schedulePersist();
  }

  void _schedulePersist() {
    if (!hydrated) return;
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_persist());
    });
  }

  Future<void> _hydrate() async {
    try {
      final file = await _storeFile();
      if (await file.exists()) {
        final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _applySnapshot(raw);
      }
    } catch (e, st) {
      debugPrint('DemoStore hydrate failed: $e\n$st');
    } finally {
      hydrated = true;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _maps(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  void _applySnapshot(Map<String, dynamic> raw) {
    lists
      ..clear()
      ..addAll(_maps(raw['lists']).map(DemoStoreCodec.list));
    wishes
      ..clear()
      ..addAll(_maps(raw['wishes']).map(DemoStoreCodec.wish));
    savings
      ..clear()
      ..addAll(_maps(raw['savings']).map(DemoStoreCodec.savings));
    boardItems
      ..clear()
      ..addAll(_maps(raw['boardItems']).map(DemoStoreCodec.board));
    notifications
      ..clear()
      ..addAll(_maps(raw['notifications']).map(DemoStoreCodec.notification));
    badges
      ..clear()
      ..addAll(_maps(raw['badges']).map(DemoStoreCodec.badge));
    invites
      ..clear()
      ..addAll(_maps(raw['invites']).map(DemoStoreCodec.invite));
    if (raw['profile'] is Map<String, dynamic>) {
      profile = DemoStoreCodec.profile(raw['profile'] as Map<String, dynamic>);
    }
    onboardingComplete = raw['onboardingComplete'] as bool? ?? onboardingComplete;
    signedIn = raw['signedIn'] as bool? ?? signedIn;
  }

  Future<void> _persist() async {
    try {
      final file = await _storeFile();
      final payload = DemoStoreCodec.encode(
        profile: profile,
        onboardingComplete: onboardingComplete,
        signedIn: signedIn,
        lists: lists,
        wishes: wishes,
        savings: savings,
        boardItems: boardItems,
        notifications: notifications,
        badges: badges,
        invites: invites,
      );
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    } catch (e, st) {
      debugPrint('DemoStore persist failed: $e\n$st');
    }
  }

  Future<File> _storeFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/wishlist_demo_store.json');
  }
}

enum SyncState { synced, syncing, offline, error }
