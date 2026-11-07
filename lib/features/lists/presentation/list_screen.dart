import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/empty_wishy.dart';
import 'package:wishlist/core/widgets/playful_backdrop.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/core/widgets/wish_image.dart';
import 'package:wishlist/features/lists/domain/models.dart';
import 'package:wishlist/features/wishes/presentation/add_wish_sheet.dart';

enum _ListViewMode { grid, stack, board, timeline }

enum _StatusFilter { all, open, maybeLater, granted }

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  _ListViewMode _mode = _ListViewMode.grid;
  _StatusFilter _status = _StatusFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(demoStoreProvider);
    final list = store.listById(widget.listId);
    if (list == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyWishy(message: 'List not found'),
      );
    }
    var wishes = store.wishesForList(widget.listId);
    wishes = switch (_status) {
      _StatusFilter.all => wishes,
      _StatusFilter.open =>
        wishes.where((w) => w.status == WishStatus.open).toList(),
      _StatusFilter.maybeLater =>
        wishes.where((w) => w.status == WishStatus.maybeLater).toList(),
      _StatusFilter.granted =>
        wishes.where((w) => w.status == WishStatus.granted).toList(),
    };

    final ink = context.wishInk;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: ink,
          fontWeight: FontWeight.w800,
        );

    return PlayfulBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              showAddWishSheet(context, ref, listId: widget.listId),
          child: const Icon(Icons.add_rounded),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: ink,
          elevation: 0,
          title: Text('${list.icon} ${list.name}', style: titleStyle),
          iconTheme: IconThemeData(color: ink),
          actionsIconTheme: IconThemeData(color: ink),
          actions: [
            IconButton(
              icon: const Icon(Icons.dashboard_customize_outlined),
              onPressed: () => context.push('/lists/${widget.listId}/board'),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => context.push('/share/${widget.listId}'),
            ),
          ],
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: _StatusFilter.values.map((s) {
                  final selected = _status == s;
                  final label = switch (s) {
                    _StatusFilter.all => 'all',
                    _StatusFilter.open => 'open',
                    _StatusFilter.maybeLater => 'maybe later',
                    _StatusFilter.granted => 'granted',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selected,
                      label: Text(label),
                      onSelected: (_) => setState(() => _status = s),
                    ),
                  );
                }).toList(),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: _ListViewMode.values.map((m) {
                  final selected = _mode == m;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selected,
                      label: Text(m.name),
                      onSelected: (_) => setState(() => _mode = m),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: wishes.isEmpty
                  ? const EmptyWishy(
                      message: 'No wishes here yet — tap + to add one!',
                    )
                  : _buildBody(context, wishes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<Wish> wishes) {
    switch (_mode) {
      case _ListViewMode.grid:
        return GridView.builder(
          padding: context.wishScrollPadding(extraBottom: 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: wishes.length,
          itemBuilder: (_, i) => _WishTile(wish: wishes[i]),
        );
      case _ListViewMode.stack:
        // Overlap with a Stack — never use negative Padding (asserts).
        final cardH = 220.0;
        final step = 36.0;
        final stackHeight =
            cardH + (wishes.length > 1 ? (wishes.length - 1) * step : 0);
        return SingleChildScrollView(
          padding: context.wishScrollPadding(top: 8, extraBottom: 96),
          child: SizedBox(
            height: stackHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < wishes.length; i++)
                  Positioned(
                    top: i * step,
                    left: (i.isEven ? 0.0 : 10.0),
                    right: (i.isEven ? 10.0 : 0.0),
                    child: Transform.rotate(
                      angle: (i % 3 - 1) * 0.035,
                      child: _WishTile(wish: wishes[i], tall: true),
                    ),
                  ),
              ],
            ),
          ),
        );
      case _ListViewMode.board:
        return Center(
          child: StickerButton(
            label: 'Open vision board',
            onPressed: () => context.push('/lists/${widget.listId}/board'),
          ),
        );
      case _ListViewMode.timeline:
        return ListView.separated(
          padding: context.wishScrollPadding(extraBottom: 96),
          itemCount: wishes.length,
          separatorBuilder: (_, __) => const Gap(8),
          itemBuilder: (_, i) {
            final w = wishes[i];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i < wishes.length - 1)
                      Container(
                        width: 2,
                        height: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                      ),
                  ],
                ),
                const Gap(12),
                Expanded(child: _WishTile(wish: w)),
              ],
            );
          },
        );
    }
  }
}

class _WishTile extends StatelessWidget {
  const _WishTile({required this.wish, this.tall = false});

  final Wish wish;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    return StickerCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/wishes/${wish.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WishImage(
            url: wish.coverUrl,
            height: tall ? 160 : 120,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wish.title.isEmpty ? 'Untitled wish' : wish.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (wish.priceAmount != null)
                  Text(
                    '${wish.priceCurrency} ${wish.priceAmount!.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
