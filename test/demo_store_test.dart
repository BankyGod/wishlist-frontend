import 'package:flutter_test/flutter_test.dart';
import 'package:wishlist/features/lists/data/demo_store.dart';
import 'package:wishlist/features/lists/data/demo_store_codec.dart';
import 'package:wishlist/features/lists/domain/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DemoStore soft-delete', () {
    test('delete moves wish to bin and restore brings it back', () {
      final store = DemoStore();
      // Avoid racing hydrate write during unit tests.
      store.hydrated = false;

      final id = store.openWishes.first.id;
      store.deleteWish(id);

      expect(store.wishById(id)?.isDeleted, isTrue);
      expect(store.binnedWishes.any((w) => w.id == id), isTrue);
      expect(store.openWishes.any((w) => w.id == id), isFalse);

      store.restoreWishById(id);
      expect(store.wishById(id)?.isDeleted, isFalse);
      expect(store.openWishes.any((w) => w.id == id), isTrue);
    });

    test('maybe later excludes wish from jar pool', () {
      final store = DemoStore();
      store.hydrated = false;
      final id = store.openWishes.first.id;
      store.setWishStatus(id, WishStatus.maybeLater);
      expect(store.openWishes.any((w) => w.id == id), isFalse);
      expect(
        store.wishesForList(store.wishById(id)!.listId)
            .any((w) => w.id == id && w.status == WishStatus.maybeLater),
        isTrue,
      );
    });

    test('archive list hides from active lists filter', () {
      final store = DemoStore();
      store.hydrated = false;
      final listId = store.lists.first.id;
      store.archiveList(listId, archived: true);
      expect(store.listById(listId)?.archived, isTrue);
    });
  });

  group('DemoStoreCodec', () {
    test('round-trips a wish with deletedAt', () {
      final wish = Wish(
        id: 'w1',
        listId: 'l1',
        imageUrls: const ['https://example.com/a.jpg'],
        title: 'Test',
        deletedAt: DateTime.utc(2026, 1, 2),
        status: WishStatus.maybeLater,
      );
      final encoded = DemoStoreCodec.encode(
        profile: const UserProfile(
          id: 'u',
          displayName: 'A',
          handle: 'a',
        ),
        onboardingComplete: true,
        signedIn: true,
        lists: const [],
        wishes: [wish],
        savings: const [],
        boardItems: const [],
        notifications: const [],
        badges: const [],
        invites: const [],
      );
      final decoded = DemoStoreCodec.wish(
        (encoded['wishes'] as List).first as Map<String, dynamic>,
      );
      expect(decoded.title, 'Test');
      expect(decoded.status, WishStatus.maybeLater);
      expect(decoded.deletedAt?.toUtc(), DateTime.utc(2026, 1, 2));
    });
  });
}
