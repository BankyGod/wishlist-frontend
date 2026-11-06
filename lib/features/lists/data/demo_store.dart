import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';

/// In-memory demo store (SRD FE-11). UI source of truth until Drift sync lands.
class DemoStore extends ChangeNotifier {
  DemoStore() {
    _seed();
  }

  final _uuid = const Uuid();
  final lists = <WishList>[];
  final wishes = <Wish>[];
  final savings = <SavingsEntry>[];
  final boardItems = <BoardItem>[];
  final notifications = <AppNotification>[];
  final badges = <BadgeItem>[];
  late UserProfile profile;
  bool onboardingComplete = false;
  bool signedIn = false;
  SyncState syncState = SyncState.synced;

  void _seed() {
    profile = const UserProfile(
      id: 'user-demo',
      displayName: 'Ama',
      handle: 'ama_accra',
      email: 'ama@example.com',
      favouriteColor: 0xFF6C3CE0,
      avatarEmoji: '✨',
      stardustTotal: 420,
      level: 4,
      streakDays: 7,
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
              w.listId == listId && (status == null || w.status == status),
        )
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<Wish> get openWishes =>
      wishes.where((w) => w.status == WishStatus.open).toList();

  List<Wish> get grantedWishes =>
      wishes.where((w) => w.status == WishStatus.granted).toList();

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
      wishes.where((w) => w.listId == listId).length;

  int grantedCount(String listId) => wishes
      .where((w) => w.listId == listId && w.status == WishStatus.granted)
      .length;

  void completeOnboarding() {
    onboardingComplete = true;
    notifyListeners();
  }

  void signInAsGuest() {
    signedIn = true;
    onboardingComplete = true;
    profile = profile.copyWith(isGuest: true, displayName: 'Guest');
    notifyListeners();
  }

  void signIn({String? displayName, String? email, String? phone}) {
    signedIn = true;
    onboardingComplete = true;
    profile = profile.copyWith(
      isGuest: false,
      displayName: displayName ?? profile.displayName,
      email: email ?? profile.email,
      phone: phone ?? profile.phone,
    );
    notifyListeners();
  }

  void signOut() {
    signedIn = false;
    notifyListeners();
  }

  void updateProfile(UserProfile next) {
    profile = next;
    notifyListeners();
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
    _award(10);
    notifyListeners();
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
    _award(10);
    notifyListeners();
    return wish;
  }

  void updateWish(Wish wish) {
    final i = wishes.indexWhere((w) => w.id == wish.id);
    if (i >= 0) {
      wishes[i] = wish;
      notifyListeners();
    }
  }

  void deleteWish(String id) {
    wishes.removeWhere((w) => w.id == id);
    boardItems.removeWhere((b) => b.wishId == id);
    notifyListeners();
  }

  void restoreWish(Wish wish) {
    if (wishes.any((w) => w.id == wish.id)) return;
    wishes.add(wish);
    notifyListeners();
  }

  void updateList(WishList list) {
    final i = lists.indexWhere((l) => l.id == list.id);
    if (i >= 0) {
      lists[i] = list;
      notifyListeners();
    }
  }

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
    _award(100);
    notifyListeners();
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
    _award(15);
  }

  void updateBoardItem(BoardItem item) {
    final i = boardItems.indexWhere((b) => b.id == item.id);
    if (i >= 0) {
      boardItems[i] = item;
      notifyListeners();
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
    _award(5);
    return pick;
  }

  void markNotificationRead(String id) {
    final i = notifications.indexWhere((n) => n.id == id);
    if (i >= 0) {
      notifications[i] = notifications[i].copyWith(read: true);
      notifyListeners();
    }
  }

  void _award(int stardust) {
    final next = profile.stardustTotal + stardust;
    var level = profile.level;
    // Rough level thresholds for demo
    while (next >= level * 150 && level < 30) {
      level++;
    }
    profile = profile.copyWith(stardustTotal: next, level: level);
  }
}

enum SyncState { synced, syncing, offline, error }
