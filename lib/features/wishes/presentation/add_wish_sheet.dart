import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';

const _sampleImages = [
  'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800',
  'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
  'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
];

Future<void> showAddWishSheet(
  BuildContext context,
  WidgetRef ref, {
  String? listId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final text = Theme.of(sheetContext).textTheme;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          16 + MediaQuery.viewPaddingOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetContext.wishOutline.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const Gap(16),
            Text('Add a wish', style: text.headlineSmall),
            Text(
              'Snap it, pick it, or quick-add a sample',
              style: text.bodyMedium?.copyWith(color: sheetContext.wishMutedInk),
            ),
            const Gap(16),
            _Option(
              emoji: '📷',
              label: 'Camera (demo photo)',
              onTap: () => _createAndOpen(
                hostContext: context,
                sheetContext: sheetContext,
                ref: ref,
                listId: listId,
                urls: [_sampleImages[0]],
                title: 'New camera wish',
              ),
            ),
            _Option(
              emoji: '🖼️',
              label: 'Gallery',
              onTap: () => _fromGallery(
                hostContext: context,
                sheetContext: sheetContext,
                ref: ref,
                listId: listId,
              ),
            ),
            _Option(
              emoji: '⚡',
              label: 'Quick wish',
              onTap: () => _createAndOpen(
                hostContext: context,
                sheetContext: sheetContext,
                ref: ref,
                listId: listId,
                urls: [_sampleImages[1]],
                title: 'Quick wish',
              ),
            ),
            _Option(
              emoji: '👟',
              label: 'Sample sneakers',
              onTap: () => _createAndOpen(
                hostContext: context,
                sheetContext: sheetContext,
                ref: ref,
                listId: listId,
                urls: [_sampleImages[2]],
                title: 'Cool sneakers',
                price: 980,
              ),
            ),
            const Gap(8),
            StickerButton(
              label: 'Cancel',
              filled: false,
              expand: true,
              onPressed: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _fromGallery({
  required BuildContext hostContext,
  required BuildContext sheetContext,
  required WidgetRef ref,
  String? listId,
}) async {
  String url = _sampleImages[0];
  try {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) url = file.path;
  } catch (_) {}
  if (!sheetContext.mounted) return;
  await _createAndOpen(
    hostContext: hostContext,
    sheetContext: sheetContext,
    ref: ref,
    listId: listId,
    urls: [url],
    title: 'Gallery wish',
  );
}

Future<void> _createAndOpen({
  required BuildContext hostContext,
  required BuildContext sheetContext,
  required WidgetRef ref,
  String? listId,
  required List<String> urls,
  String title = '',
  double? price,
}) async {
  final store = ref.read(demoStoreProvider);
  final targetListId = listId ??
      (store.lists.isNotEmpty ? store.lists.first.id : 'list-someday');
  final wish = store.addWish(
    listId: targetListId,
    imageUrls: urls,
    title: title,
    price: price,
  );
  Navigator.pop(sheetContext);
  await Future<void>.delayed(const Duration(milliseconds: 50));
  if (hostContext.mounted) {
    hostContext.push('/wishes/${wish.id}/edit');
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = context.wishCardFill;
    final outline = context.wishOutline;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: outline, width: 2),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const Gap(12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.wishInk),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
