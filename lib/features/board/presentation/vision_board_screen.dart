import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/wish_image.dart';
import 'package:wishlist/features/lists/domain/models.dart';

class VisionBoardScreen extends ConsumerWidget {
  const VisionBoardScreen({super.key, required this.listId});

  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(demoStoreProvider);
    final items = store.boardItems.where((b) => b.listId == listId).toList()
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision board'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(200),
        minScale: 0.5,
        maxScale: 2.5,
        child: Container(
          width: 2000,
          height: 2000,
          color: context.wishPalette.background,
          child: Stack(
            children: items.map((item) {
              final wish = store.wishById(item.wishId);
              if (wish == null) return const SizedBox.shrink();
              return _DraggableSticker(
                item: item,
                wish: wish,
                onUpdate: (next) => store.updateBoardItem(next),
                onOpen: () => context.push('/wishes/${wish.id}'),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _DraggableSticker extends StatefulWidget {
  const _DraggableSticker({
    required this.item,
    required this.wish,
    required this.onUpdate,
    required this.onOpen,
  });

  final BoardItem item;
  final Wish wish;
  final ValueChanged<BoardItem> onUpdate;
  final VoidCallback onOpen;

  @override
  State<_DraggableSticker> createState() => _DraggableStickerState();
}

class _DraggableStickerState extends State<_DraggableSticker> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = Offset(widget.item.x, widget.item.y);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: widget.onOpen,
        onPanUpdate: (d) {
          setState(() => _position += d.delta);
          widget.onUpdate(widget.item.copyWith(x: _position.dx, y: _position.dy));
        },
        child: Transform.rotate(
          angle: widget.item.rotation,
          child: Transform.scale(
            scale: widget.item.scale,
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.wishOutline, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: context.wishInk.withValues(alpha: 0.2),
                    offset: WishlistColors.hardShadow,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WishImage(
                    url: widget.wish.coverUrl,
                    width: 100,
                    height: 90,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      widget.wish.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
