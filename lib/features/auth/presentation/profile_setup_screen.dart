import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/core/widgets/squash_tap.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  String _emoji = '✨';
  int _color = WishlistColors.wishViolet.toARGB32();

  static const _emojis = ['✨', '🌟', '💫', '🦄', '🌈', '🔥'];
  static const _colors = [
    WishlistColors.wishViolet,
    WishlistColors.popPink,
    WishlistColors.mintGreen,
    WishlistColors.sunnyGold,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final store = ref.read(demoStoreProvider);
    store.updateProfile(
      store.profile.copyWith(
        displayName: _nameCtrl.text.isEmpty ? store.profile.displayName : _nameCtrl.text,
        avatarEmoji: _emoji,
        favouriteColor: _color,
      ),
    );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your vibe')),
      body: ListView(
        padding: context.wishScrollPadding(),
        children: [
          StickerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Display name'),
                ),
                const Gap(20),
                Text('Pick an avatar', style: Theme.of(context).textTheme.titleMedium),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  children: _emojis.map((e) {
                    final selected = e == _emoji;
                    return SquashTap(
                      onTap: () => setState(() => _emoji = e),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            width: selected ? 3 : 2,
                            color: selected
                                ? WishlistColors.wishViolet
                                : WishlistColors.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  }).toList(),
                ),
                const Gap(20),
                Text('Favourite colour', style: Theme.of(context).textTheme.titleMedium),
                const Gap(8),
                Row(
                  children: _colors.map((c) {
                    final selected = c.toARGB32() == _color;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SquashTap(
                        onTap: () => setState(() => _color = c.toARGB32()),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: selected ? 3 : 2,
                              color: WishlistColors.midnightInk,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Gap(24),
          StickerButton(label: 'Start wishing', expand: true, onPressed: _save),
        ],
      ),
    );
  }
}
