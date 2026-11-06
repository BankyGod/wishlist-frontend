import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/motion/feedback.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/core/widgets/wish_image.dart';

class GrantScreen extends ConsumerStatefulWidget {
  const GrantScreen({super.key, required this.wishId});

  final String wishId;

  @override
  ConsumerState<GrantScreen> createState() => _GrantScreenState();
}

class _GrantScreenState extends ConsumerState<GrantScreen> {
  double _knobX = 0;
  final _paidCtrl = TextEditingController();
  final _memoryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final wish = ref.read(demoStoreProvider).wishById(widget.wishId);
    if (wish?.priceAmount != null) {
      _paidCtrl.text = wish!.priceAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _paidCtrl.dispose();
    _memoryCtrl.dispose();
    super.dispose();
  }

  void _onGrant() {
    final paid = double.tryParse(_paidCtrl.text);
    WishlistFeedback.celebration();
    ref.read(demoStoreProvider).grantWish(
          widget.wishId,
          paid: paid,
          note: _memoryCtrl.text.trim().isEmpty ? null : _memoryCtrl.text.trim(),
        );
    context.go('/celebration/${widget.wishId}');
  }

  void _onDragEnd(double trackWidth) {
    final maxDrag = trackWidth - 56;
    if (maxDrag <= 0) return;
    if (_knobX >= maxDrag * 0.85) {
      _onGrant();
    } else {
      WishlistFeedback.tap();
      setState(() => _knobX = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wish = ref.watch(demoStoreProvider).wishById(widget.wishId);
    if (wish == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Wish not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Grant wish')),
      body: ListView(
        padding: context.wishScrollPadding(),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: WishImage(url: wish.coverUrl, height: 200),
          ),
          const Gap(16),
          Text(
            wish.title.isEmpty ? 'Your wish' : wish.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          StickerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _paidCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Paid price (optional)',
                    prefixText: 'GHS ',
                  ),
                ),
                const Gap(12),
                TextField(
                  controller: _memoryCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Memory note',
                    hintText: 'How did it feel to grant this?',
                  ),
                ),
              ],
            ),
          ),
          const Gap(32),
          Text(
            'Slide the green knob to grant',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final maxDrag = (trackWidth - 56).clamp(0.0, double.infinity);

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 56,
                    width: trackWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: context.wishOutline, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: context.wishInk.withValues(alpha: 0.18),
                          offset: WishlistColors.hardShadow,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _knobX > maxDrag * 0.5 ? 'Release to grant!' : 'Drag →',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: context.wishMutedInk,
                          ),
                    ),
                  ),
                  Positioned(
                    left: _knobX,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (d) {
                        setState(() {
                          _knobX = (_knobX + d.delta.dx).clamp(0.0, maxDrag);
                        });
                      },
                      onHorizontalDragEnd: (_) => _onDragEnd(trackWidth),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.wishOutline, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: context.wishInk.withValues(alpha: 0.18),
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
