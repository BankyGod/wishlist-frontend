import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_theme.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/core/widgets/wish_image.dart';
import 'package:wishlist/features/lists/data/demo_store.dart';
import 'package:wishlist/features/lists/domain/models.dart';

/// Home — My Lists (SRD S06). No nested Scaffold (shell owns that).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(demoStoreProvider);
    final profile = store.profile;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cardFill = context.wishCardFill;
    final outline = context.wishOutline;

    var lists = store.lists.where((l) => !l.archived).toList()
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      lists = lists.where((l) => l.name.toLowerCase().contains(q)).toList();
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cardFill,
                  shape: BoxShape.circle,
                  border: Border.all(color: outline, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.22),
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: Text(
                  profile.avatarEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey, ${profile.displayName}',
                      style: text.headlineMedium,
                    ),
                    Text(
                      'Wish it. Snap it. Chase it.',
                      style: text.bodyMedium?.copyWith(
                        color: context.wishMutedInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/notifications'),
                style: IconButton.styleFrom(
                  backgroundColor: cardFill,
                  side: BorderSide(color: outline, width: 2),
                ),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: StickerCard(
                  color: scheme.secondary.withValues(alpha: 0.28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ Stardust',
                        style: text.titleSmall,
                      ),
                      Text(
                        '${profile.stardustTotal}',
                        style: context.wishNumberStyle,
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: StickerCard(
                  color: scheme.primary.withValues(alpha: 0.18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🔥 Streak', style: text.titleSmall),
                      Text(
                        '${profile.streakDays} days',
                        style: context.wishNumberStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Gap(14),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            style: text.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'Search lists…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const Gap(18),
          Row(
            children: [
              Text('Your lists', style: text.headlineSmall),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _createList(context, store),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New'),
              ),
            ],
          ),
          const Gap(8),
          if (lists.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No lists yet — tap New ✨',
                textAlign: TextAlign.center,
                style: text.bodyLarge,
              ),
            )
          else
            ...lists.asMap().entries.map(
                  (e) => _ListTileCard(list: e.value, store: store, index: e.key),
                ),
        ],
      ),
    );
  }

  Future<void> _createList(BuildContext context, DemoStore store) async {
    final nameCtrl = TextEditingController();
    const icons = ['🌈', '🎂', '🎁', '✈️', '📚', '🏠', '💚', '🎮'];
    var icon = icons.first;
    final scheme = Theme.of(context).colorScheme;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final text = Theme.of(ctx).textTheme;
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.viewInsetsOf(ctx).bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('New list', style: text.headlineSmall),
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final e in icons)
                          ChoiceChip(
                            label: Text(e, style: const TextStyle(fontSize: 20)),
                            selected: icon == e,
                            onSelected: (_) => setModal(() => icon = e),
                          ),
                      ],
                    ),
                    const Gap(12),
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      maxLength: 40,
                      decoration: const InputDecoration(labelText: 'List name'),
                    ),
                    const Gap(12),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    final name = nameCtrl.text.trim();
    // Dispose after the sheet route fully tears down its TextFields.
    WidgetsBinding.instance.addPostFrameCallback((_) => nameCtrl.dispose());
    if (ok == true && name.isNotEmpty) {
      store.createList(
        name: name,
        icon: icon,
        coverColor: scheme.primary.toARGB32(),
      );
    }
  }
}

class _ListTileCard extends StatelessWidget {
  const _ListTileCard({
    required this.list,
    required this.store,
    required this.index,
  });

  final WishList list;
  final DemoStore store;
  final int index;

  @override
  Widget build(BuildContext context) {
    final wishes = store.wishesForList(list.id);
    final open = wishes.where((w) => w.status == WishStatus.open).length;
    final granted = store.grantedCount(list.id);
    final previews = wishes.take(4).toList();
    final text = Theme.of(context).textTheme;
    final outline = context.wishOutline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/lists/${list.id}'),
          child: StickerCard(
            color: context.wishCardFill,
            rotation: index.isEven ? -0.012 : 0.018,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(list.coverColor),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: outline, width: 2.5),
                      ),
                      child: Text(list.icon, style: const TextStyle(fontSize: 26)),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${list.pinned ? '📌 ' : ''}${list.name}',
                            style: text.titleLarge,
                          ),
                          Text(
                            '$open open · $granted granted',
                            style: text.bodyMedium?.copyWith(
                              color: context.wishMutedInk,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: context.wishInk),
                  ],
                ),
                if (previews.isNotEmpty) ...[
                  const Gap(12),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: previews.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: outline, width: 2),
                        ),
                        child: WishImage(
                          url: previews[i].coverUrl,
                          width: 48,
                          height: 48,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
