import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/reveal_meter.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/features/lists/domain/models.dart';

const _quickAmounts = [20.0, 50.0, 100.0, 200.0, 500.0];

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key, required this.wishId});

  final String wishId;

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  final _amountCtrl = TextEditingController(text: '100');
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _showMilestoneSnackbars(double before, double after) {
    final milestones = <double, String>{
      0.25: '25% — great start! 🌱',
      0.5: 'Halfway there! 🎯',
      0.75: '75% — almost yours! ✨',
      1.0: '100% — jar is full! 🫙',
    };
    for (final entry in milestones.entries) {
      if (before < entry.key && after >= entry.key) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(entry.value)),
        );
      }
    }
  }

  void _add() {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;
    final store = ref.read(demoStoreProvider);
    final wish = store.wishById(widget.wishId);
    if (wish == null) return;
    final before = wish.savingsProgress;
    store.addSavings(
      widget.wishId,
      amount,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    final after = store.wishById(widget.wishId)?.savingsProgress ?? before;
    _showMilestoneSnackbars(before, after);
    _noteCtrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(demoStoreProvider);
    final wish = store.wishById(widget.wishId);
    if (wish == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Wish not found')),
      );
    }

    final entries = store.savings
        .where((e) => e.wishId == widget.wishId)
        .toList()
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

    final goal = wish.savingsGoalAmount ?? wish.priceAmount ?? 0;
    final atFull = wish.savingsProgress >= 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings jar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: context.wishScrollPadding(),
        children: [
          RevealMeter(
            imageUrl: wish.coverUrl,
            progress: wish.savingsProgress,
          ),
          const Gap(8),
          Text(
            '${wish.savingsTotal.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} GHS',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(20),
          Text('Quick add', style: Theme.of(context).textTheme.titleSmall),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickAmounts.map((a) {
              return ActionChip(
                label: Text('GHS ${a.toStringAsFixed(0)}'),
                backgroundColor: Theme.of(context).colorScheme.surface,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
                onPressed: () {
                  _amountCtrl.text = a.toStringAsFixed(0);
                  setState(() {});
                },
              );
            }).toList(),
          ),
          const Gap(16),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount to add',
              prefixText: 'GHS ',
            ),
          ),
          const Gap(12),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'Allowance, side hustle…',
            ),
          ),
          const Gap(16),
          StickerButton(label: 'Log savings', expand: true, onPressed: _add),
          if (atFull && wish.status == WishStatus.open) ...[
            const Gap(12),
            StickerButton(
              label: 'Grant this wish 🎉',
              color: WishlistColors.mintGreen,
              expand: true,
              onPressed: () => context.push('/wishes/${widget.wishId}/grant'),
            ),
          ],
          const Gap(24),
          Text('History', style: Theme.of(context).textTheme.titleLarge),
          const Gap(8),
          if (entries.isEmpty)
            StickerCard(
              child: Text(
                'No entries yet — log your first savings!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: StickerCard(
                    child: Row(
                      children: [
                        Text(
                          '+${e.amount.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: WishlistColors.mintGreen,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Gap(8),
                        Text(e.currency),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat.MMMd().format(e.entryDate),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            if (e.note != null && e.note!.isNotEmpty)
                              Text(
                                e.note!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
