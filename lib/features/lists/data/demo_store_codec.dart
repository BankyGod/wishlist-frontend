import 'package:wishlist/features/lists/domain/models.dart';

/// JSON codec for [DemoStore] snapshots (local persistence).
abstract final class DemoStoreCodec {
  static Map<String, dynamic> encode({
    required UserProfile profile,
    required bool onboardingComplete,
    required bool signedIn,
    required List<WishList> lists,
    required List<Wish> wishes,
    required List<SavingsEntry> savings,
    required List<BoardItem> boardItems,
    required List<AppNotification> notifications,
    required List<BadgeItem> badges,
    required List<ListInvite> invites,
  }) {
    return {
      'v': 1,
      'onboardingComplete': onboardingComplete,
      'signedIn': signedIn,
      'profile': _profile(profile),
      'lists': lists.map(_list).toList(),
      'wishes': wishes.map(_wish).toList(),
      'savings': savings.map(_savings).toList(),
      'boardItems': boardItems.map(_board).toList(),
      'notifications': notifications.map(_notification).toList(),
      'badges': badges.map(_badge).toList(),
      'invites': invites.map(_invite).toList(),
    };
  }

  static Map<String, dynamic> _profile(UserProfile p) => {
        'id': p.id,
        'displayName': p.displayName,
        'handle': p.handle,
        'email': p.email,
        'phone': p.phone,
        'favouriteColor': p.favouriteColor,
        'avatarEmoji': p.avatarEmoji,
        'stardustTotal': p.stardustTotal,
        'level': p.level,
        'streakDays': p.streakDays,
        'bestStreakDays': p.bestStreakDays,
        'lastStreakDate': p.lastStreakDate?.toIso8601String(),
        'isGuest': p.isGuest,
        'currencyDefault': p.currencyDefault,
      };

  static Map<String, dynamic> _list(WishList l) => {
        'id': l.id,
        'name': l.name,
        'icon': l.icon,
        'coverColor': l.coverColor,
        'description': l.description,
        'privacy': l.privacy.name,
        'targetDate': l.targetDate?.toIso8601String(),
        'sortOrder': l.sortOrder,
        'pinned': l.pinned,
        'archived': l.archived,
      };

  static Map<String, dynamic> _wish(Wish w) => {
        'id': w.id,
        'listId': w.listId,
        'imageUrls': w.imageUrls,
        'title': w.title,
        'note': w.note,
        'whyText': w.whyText,
        'priceAmount': w.priceAmount,
        'priceCurrency': w.priceCurrency,
        'priority': w.priority,
        'category': w.category,
        'tags': w.tags,
        'mood': w.mood?.name,
        'frameStyle': w.frameStyle.name,
        'productUrl': w.productUrl,
        'status': w.status.name,
        'grantedAt': w.grantedAt?.toIso8601String(),
        'grantedPrice': w.grantedPrice,
        'grantedNote': w.grantedNote,
        'savingsGoalAmount': w.savingsGoalAmount,
        'savingsTotal': w.savingsTotal,
        'sortOrder': w.sortOrder,
        'createdAt': w.createdAt?.toIso8601String(),
        'deletedAt': w.deletedAt?.toIso8601String(),
      };

  static Map<String, dynamic> _savings(SavingsEntry s) => {
        'id': s.id,
        'wishId': s.wishId,
        'amount': s.amount,
        'currency': s.currency,
        'entryDate': s.entryDate.toIso8601String(),
        'note': s.note,
      };

  static Map<String, dynamic> _board(BoardItem b) => {
        'id': b.id,
        'listId': b.listId,
        'wishId': b.wishId,
        'x': b.x,
        'y': b.y,
        'scale': b.scale,
        'rotation': b.rotation,
        'zIndex': b.zIndex,
      };

  static Map<String, dynamic> _notification(AppNotification n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'createdAt': n.createdAt.toIso8601String(),
        'read': n.read,
        'category': n.category,
      };

  static Map<String, dynamic> _badge(BadgeItem b) => {
        'id': b.id,
        'name': b.name,
        'description': b.description,
        'emoji': b.emoji,
        'unlocked': b.unlocked,
      };

  static Map<String, dynamic> _invite(ListInvite i) => {
        'id': i.id,
        'listId': i.listId,
        'email': i.email,
        'sentAt': i.sentAt.toIso8601String(),
      };

  static UserProfile profile(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        displayName: j['displayName'] as String,
        handle: j['handle'] as String,
        email: j['email'] as String?,
        phone: j['phone'] as String?,
        favouriteColor: j['favouriteColor'] as int? ?? 0xFF6C3CE0,
        avatarEmoji: j['avatarEmoji'] as String? ?? '🌟',
        stardustTotal: j['stardustTotal'] as int? ?? 0,
        level: j['level'] as int? ?? 1,
        streakDays: j['streakDays'] as int? ?? 0,
        bestStreakDays: j['bestStreakDays'] as int? ??
            (j['streakDays'] as int? ?? 0),
        lastStreakDate: j['lastStreakDate'] != null
            ? DateTime.tryParse(j['lastStreakDate'] as String)
            : null,
        isGuest: j['isGuest'] as bool? ?? false,
        currencyDefault: j['currencyDefault'] as String? ?? 'GHS',
      );

  static WishList list(Map<String, dynamic> j) => WishList(
        id: j['id'] as String,
        name: j['name'] as String,
        icon: j['icon'] as String,
        coverColor: j['coverColor'] as int,
        description: j['description'] as String?,
        privacy: ListPrivacy.values.byName(j['privacy'] as String? ?? 'private'),
        targetDate: j['targetDate'] != null
            ? DateTime.tryParse(j['targetDate'] as String)
            : null,
        sortOrder: j['sortOrder'] as int? ?? 0,
        pinned: j['pinned'] as bool? ?? false,
        archived: j['archived'] as bool? ?? false,
      );

  static Wish wish(Map<String, dynamic> j) => Wish(
        id: j['id'] as String,
        listId: j['listId'] as String,
        imageUrls: (j['imageUrls'] as List?)?.cast<String>() ?? const [],
        title: j['title'] as String? ?? '',
        note: j['note'] as String? ?? '',
        whyText: j['whyText'] as String? ?? '',
        priceAmount: (j['priceAmount'] as num?)?.toDouble(),
        priceCurrency: j['priceCurrency'] as String? ?? 'GHS',
        priority: j['priority'] as int? ?? 3,
        category: j['category'] as String?,
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
        mood: j['mood'] != null
            ? MoodSticker.values.byName(j['mood'] as String)
            : null,
        frameStyle: FrameStyle.values.byName(
          j['frameStyle'] as String? ?? 'polaroid',
        ),
        productUrl: j['productUrl'] as String?,
        status: WishStatus.values.byName(j['status'] as String? ?? 'open'),
        grantedAt: j['grantedAt'] != null
            ? DateTime.tryParse(j['grantedAt'] as String)
            : null,
        grantedPrice: (j['grantedPrice'] as num?)?.toDouble(),
        grantedNote: j['grantedNote'] as String?,
        savingsGoalAmount: (j['savingsGoalAmount'] as num?)?.toDouble(),
        savingsTotal: (j['savingsTotal'] as num?)?.toDouble() ?? 0,
        sortOrder: j['sortOrder'] as int? ?? 0,
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'] as String)
            : null,
        deletedAt: j['deletedAt'] != null
            ? DateTime.tryParse(j['deletedAt'] as String)
            : null,
      );

  static SavingsEntry savings(Map<String, dynamic> j) => SavingsEntry(
        id: j['id'] as String,
        wishId: j['wishId'] as String,
        amount: (j['amount'] as num).toDouble(),
        currency: j['currency'] as String,
        entryDate: DateTime.parse(j['entryDate'] as String),
        note: j['note'] as String?,
      );

  static BoardItem board(Map<String, dynamic> j) => BoardItem(
        id: j['id'] as String,
        listId: j['listId'] as String,
        wishId: j['wishId'] as String,
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        scale: (j['scale'] as num?)?.toDouble() ?? 1,
        rotation: (j['rotation'] as num?)?.toDouble() ?? 0,
        zIndex: j['zIndex'] as int? ?? 0,
      );

  static AppNotification notification(Map<String, dynamic> j) =>
      AppNotification(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        read: j['read'] as bool? ?? false,
        category: j['category'] as String? ?? 'general',
      );

  static BadgeItem badge(Map<String, dynamic> j) => BadgeItem(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String,
        emoji: j['emoji'] as String,
        unlocked: j['unlocked'] as bool? ?? false,
      );

  static ListInvite invite(Map<String, dynamic> j) => ListInvite(
        id: j['id'] as String,
        listId: j['listId'] as String,
        email: j['email'] as String,
        sentAt: DateTime.parse(j['sentAt'] as String),
      );
}

class ListInvite {
  const ListInvite({
    required this.id,
    required this.listId,
    required this.email,
    required this.sentAt,
  });

  final String id;
  final String listId;
  final String email;
  final DateTime sentAt;
}
