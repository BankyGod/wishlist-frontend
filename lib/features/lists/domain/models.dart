import 'package:equatable/equatable.dart';

enum ListPrivacy { private, invite, link }

enum WishStatus { open, granted, maybeLater }

enum FrameStyle {
  polaroid,
  tornPaper,
  neon,
  gold,
  filmStrip,
  comic,
  postageStamp,
  stickyNote,
  ticket,
  plain,
}

enum MoodSticker { fire, dream, need, treat, someday }

class WishList extends Equatable {
  const WishList({
    required this.id,
    required this.name,
    required this.icon,
    required this.coverColor,
    this.description,
    this.privacy = ListPrivacy.private,
    this.targetDate,
    this.sortOrder = 0,
    this.pinned = false,
    this.archived = false,
  });

  final String id;
  final String name;
  final String icon;
  final int coverColor;
  final String? description;
  final ListPrivacy privacy;
  final DateTime? targetDate;
  final int sortOrder;
  final bool pinned;
  final bool archived;

  WishList copyWith({
    String? name,
    String? icon,
    int? coverColor,
    String? description,
    ListPrivacy? privacy,
    DateTime? targetDate,
    int? sortOrder,
    bool? pinned,
    bool? archived,
  }) {
    return WishList(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      coverColor: coverColor ?? this.coverColor,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
      targetDate: targetDate ?? this.targetDate,
      sortOrder: sortOrder ?? this.sortOrder,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        coverColor,
        description,
        privacy,
        targetDate,
        sortOrder,
        pinned,
        archived,
      ];
}

class Wish extends Equatable {
  const Wish({
    required this.id,
    required this.listId,
    required this.imageUrls,
    this.title = '',
    this.note = '',
    this.whyText = '',
    this.priceAmount,
    this.priceCurrency = 'GHS',
    this.priority = 3,
    this.category,
    this.tags = const [],
    this.mood,
    this.frameStyle = FrameStyle.polaroid,
    this.productUrl,
    this.status = WishStatus.open,
    this.grantedAt,
    this.grantedPrice,
    this.grantedNote,
    this.savingsGoalAmount,
    this.savingsTotal = 0,
    this.sortOrder = 0,
    this.createdAt,
    this.deletedAt,
  });

  final String id;
  final String listId;
  final List<String> imageUrls;
  final String title;
  final String note;
  final String whyText;
  final double? priceAmount;
  final String priceCurrency;
  final int priority;
  final String? category;
  final List<String> tags;
  final MoodSticker? mood;
  final FrameStyle frameStyle;
  final String? productUrl;
  final WishStatus status;
  final DateTime? grantedAt;
  final double? grantedPrice;
  final String? grantedNote;
  final double? savingsGoalAmount;
  final double savingsTotal;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  String get coverUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  double get savingsProgress {
    final goal = savingsGoalAmount ?? priceAmount;
    if (goal == null || goal <= 0) return 0;
    return (savingsTotal / goal).clamp(0.0, 1.0);
  }

  Wish copyWith({
    List<String>? imageUrls,
    String? title,
    String? note,
    String? whyText,
    double? priceAmount,
    String? priceCurrency,
    int? priority,
    String? category,
    List<String>? tags,
    MoodSticker? mood,
    FrameStyle? frameStyle,
    String? productUrl,
    WishStatus? status,
    DateTime? grantedAt,
    double? grantedPrice,
    String? grantedNote,
    double? savingsGoalAmount,
    double? savingsTotal,
    int? sortOrder,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Wish(
      id: id,
      listId: listId,
      imageUrls: imageUrls ?? this.imageUrls,
      title: title ?? this.title,
      note: note ?? this.note,
      whyText: whyText ?? this.whyText,
      priceAmount: priceAmount ?? this.priceAmount,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      frameStyle: frameStyle ?? this.frameStyle,
      productUrl: productUrl ?? this.productUrl,
      status: status ?? this.status,
      grantedAt: grantedAt ?? this.grantedAt,
      grantedPrice: grantedPrice ?? this.grantedPrice,
      grantedNote: grantedNote ?? this.grantedNote,
      savingsGoalAmount: savingsGoalAmount ?? this.savingsGoalAmount,
      savingsTotal: savingsTotal ?? this.savingsTotal,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  @override
  List<Object?> get props => [
        id,
        listId,
        imageUrls,
        title,
        note,
        whyText,
        priceAmount,
        priceCurrency,
        priority,
        category,
        tags,
        mood,
        frameStyle,
        productUrl,
        status,
        grantedAt,
        grantedPrice,
        grantedNote,
        savingsGoalAmount,
        savingsTotal,
        sortOrder,
        createdAt,
        deletedAt,
      ];
}

class SavingsEntry extends Equatable {
  const SavingsEntry({
    required this.id,
    required this.wishId,
    required this.amount,
    required this.currency,
    required this.entryDate,
    this.note,
  });

  final String id;
  final String wishId;
  final double amount;
  final String currency;
  final DateTime entryDate;
  final String? note;

  @override
  List<Object?> get props => [id, wishId, amount, currency, entryDate, note];
}

class BoardItem extends Equatable {
  const BoardItem({
    required this.id,
    required this.listId,
    required this.wishId,
    required this.x,
    required this.y,
    this.scale = 1,
    this.rotation = 0,
    this.zIndex = 0,
  });

  final String id;
  final String listId;
  final String wishId;
  final double x;
  final double y;
  final double scale;
  final double rotation;
  final int zIndex;

  BoardItem copyWith({
    double? x,
    double? y,
    double? scale,
    double? rotation,
    int? zIndex,
  }) {
    return BoardItem(
      id: id,
      listId: listId,
      wishId: wishId,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  @override
  List<Object?> get props => [id, listId, wishId, x, y, scale, rotation, zIndex];
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.handle,
    this.email,
    this.phone,
    this.favouriteColor = 0xFF6C3CE0,
    this.avatarEmoji = '🌟',
    this.stardustTotal = 0,
    this.level = 1,
    this.streakDays = 0,
    this.bestStreakDays = 0,
    this.lastStreakDate,
    this.isGuest = false,
    this.currencyDefault = 'GHS',
  });

  final String id;
  final String displayName;
  final String handle;
  final String? email;
  final String? phone;
  final int favouriteColor;
  final String avatarEmoji;
  final int stardustTotal;
  final int level;
  final int streakDays;
  final int bestStreakDays;
  /// Calendar day the streak was last advanced (date-only meaning).
  final DateTime? lastStreakDate;
  final bool isGuest;
  final String currencyDefault;

  String get levelTitle {
    const titles = [
      'Dreamer',
      'Collector',
      'Dream Chaser',
      'Wish Wizard',
      'Stardust Seeker',
      'Vision Keeper',
      'Wish Legend',
    ];
    final i = (level - 1).clamp(0, titles.length - 1);
    return titles[i];
  }

  UserProfile copyWith({
    String? displayName,
    String? handle,
    String? email,
    String? phone,
    int? favouriteColor,
    String? avatarEmoji,
    int? stardustTotal,
    int? level,
    int? streakDays,
    int? bestStreakDays,
    DateTime? lastStreakDate,
    bool clearLastStreakDate = false,
    bool? isGuest,
    String? currencyDefault,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      favouriteColor: favouriteColor ?? this.favouriteColor,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      stardustTotal: stardustTotal ?? this.stardustTotal,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      bestStreakDays: bestStreakDays ?? this.bestStreakDays,
      lastStreakDate:
          clearLastStreakDate ? null : (lastStreakDate ?? this.lastStreakDate),
      isGuest: isGuest ?? this.isGuest,
      currencyDefault: currencyDefault ?? this.currencyDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        handle,
        email,
        phone,
        favouriteColor,
        avatarEmoji,
        stardustTotal,
        level,
        streakDays,
        bestStreakDays,
        lastStreakDate,
        isGuest,
        currencyDefault,
      ];
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.category = 'general',
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String category;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
        read: read ?? this.read,
        category: category,
      );

  @override
  List<Object?> get props => [id, title, body, createdAt, read, category];
}

class BadgeItem extends Equatable {
  const BadgeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.unlocked = false,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;
  final bool unlocked;

  @override
  List<Object?> get props => [id, name, description, emoji, unlocked];
}
