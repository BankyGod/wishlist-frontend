import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/motion/feedback.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

const _categories = [
  'Tech',
  'Fashion',
  'Travel',
  'Gift',
  'Gadgets',
  'Other',
];

class EditWishScreen extends ConsumerStatefulWidget {
  const EditWishScreen({super.key, required this.wishId});

  final String wishId;

  @override
  ConsumerState<EditWishScreen> createState() => _EditWishScreenState();
}

class _EditWishScreenState extends ConsumerState<EditWishScreen> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late final TextEditingController _whyText;
  late final TextEditingController _price;
  late int _priority;
  late String _category;
  bool _saving = false;

  void _onPreviewChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final wish = ref.read(demoStoreProvider).wishById(widget.wishId);
    _title = TextEditingController(text: wish?.title ?? '');
    _note = TextEditingController(text: wish?.note ?? '');
    _whyText = TextEditingController(text: wish?.whyText ?? '');
    _price = TextEditingController(
      text: wish?.priceAmount?.toStringAsFixed(0) ?? '',
    );
    _priority = wish?.priority ?? 3;
    final cat = wish?.category;
    _category = cat != null && _categories.contains(cat) ? cat : 'Other';
    _title.addListener(_onPreviewChanged);
    _price.addListener(_onPreviewChanged);
  }

  @override
  void dispose() {
    _title.removeListener(_onPreviewChanged);
    _price.removeListener(_onPreviewChanged);
    _title.dispose();
    _note.dispose();
    _whyText.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    // Dismiss keyboard so the tap isn't eaten by focus changes.
    FocusScope.of(context).unfocus();

    final store = ref.read(demoStoreProvider);
    final wish = store.wishById(widget.wishId);
    if (wish == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wish not found — try again from Home')),
        );
        setState(() => _saving = false);
      }
      return;
    }

    final price = double.tryParse(_price.text.trim());
    store.updateWish(
      wish.copyWith(
        title: _title.text.trim(),
        note: _note.text.trim(),
        whyText: _whyText.text.trim(),
        priceAmount: price ?? wish.priceAmount,
        savingsGoalAmount: price ?? wish.savingsGoalAmount,
        priority: _priority,
        category: _category,
      ),
    );

    if (!mounted) return;
    WishlistFeedback.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved “${_title.text.trim().isEmpty ? 'wish' : _title.text.trim()}”',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  String get _previewPrice {
    final p = double.tryParse(_price.text);
    if (p == null) return '— GHS';
    return 'GHS ${p.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit wish')),
      // Pin Save outside the scroll view so taps always register.
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + context.wishBottomInset),
        child: StickerButton(
          label: _saving ? 'Saving…' : 'Save',
          expand: true,
          onPressed: _saving ? null : _save,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(WishlistColors.screenPadding),
        children: [
          StickerCard(
            rotation: -0.03,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live preview',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const Gap(4),
                Text(
                  _title.text.isEmpty ? 'Your wish title…' : _title.text,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Gap(4),
                Text(
                  _previewPrice,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: WishlistColors.sunnyGold,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const Gap(20),
          TextField(
            controller: _title,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const Gap(12),
          TextField(
            controller: _whyText,
            maxLines: 2,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Why I want this'),
          ),
          const Gap(12),
          TextField(
            controller: _note,
            maxLines: 3,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const Gap(12),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(labelText: 'Price (GHS)'),
          ),
          const Gap(16),
          Text('Priority', style: Theme.of(context).textTheme.titleSmall),
          const Gap(8),
          StickerCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                final selected = star <= _priority;
                return IconButton(
                  onPressed: () => setState(() => _priority = star),
                  icon: Icon(
                    selected ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36,
                    color: selected
                        ? WishlistColors.sunnyGold
                        : WishlistColors.outline.withValues(alpha: 0.35),
                  ),
                );
              }),
            ),
          ),
          const Gap(16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
          ),
          const Gap(24),
        ],
      ),
    );
  }
}
