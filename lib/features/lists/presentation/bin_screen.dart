import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class BinScreen extends StatelessWidget {
  const BinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bin')),
      body: Padding(
        padding: context.wishScrollPadding(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StickerCard(
              rotation: 0.04,
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  const Text('🗑️', style: TextStyle(fontSize: 56)),
                  const Gap(12),
                  Text(
                    'Nothing in the bin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Gap(8),
                  Text(
                    'Deleted wishes land here. Use Undo on the snackbar to restore them right away.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
