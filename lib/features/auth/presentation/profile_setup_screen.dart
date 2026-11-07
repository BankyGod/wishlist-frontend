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
  late final TextEditingController _nameCtrl;
  late String _emoji;
  late int _color;

  static const _emojis = ['✨', '🌟', '💫', '🦄', '🌈', '🔥', '💚', '🎯'];
  static const _colors = [
    WishlistColors.wishViolet,
    WishlistColors.popPink,
    WishlistColors.mintGreen,
    WishlistColors.sunnyGold,
    WishlistColors.skyBlue,
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(demoStoreProvider).profile;
    _nameCtrl = TextEditingController(text: profile.displayName);
    _emoji = profile.avatarEmoji;
    _color = profile.favouriteColor;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final store = ref.read(demoStoreProvider);
    final name = _nameCtrl.text.trim();
    store.updateProfile(
      store.profile.copyWith(
        displayName: name.isEmpty ? store.profile.displayName : name,
        avatarEmoji: _emoji,
        favouriteColor: _color,
        isGuest: false,
      ),
    );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final outline = context.wishOutline;
    return Scaffold(
      appBar: AppBar(title: const Text('Your vibe')),
      body: ListView(
        padding: context.wishScrollPadding(),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(_color),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: outline, width: 2.5),
              ),
              child: Text(_emoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
          const Gap(16),
          StickerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Display name'),
                ),
                const Gap(20),
                Text(
                  'Pick an avatar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                                ? Theme.of(context).colorScheme.primary
                                : outline,
                          ),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  }).toList(),
                ),
                const Gap(20),
                Text(
                  'Favourite colour',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(8),
                Wrap(
                  spacing: 12,
                  children: _colors.map((c) {
                    final selected = c.toARGB32() == _color;
                    return SquashTap(
                      onTap: () => setState(() => _color = c.toARGB32()),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: selected ? 3 : 2,
                            color: context.wishInk,
                          ),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Gap(24),
          StickerButton(
            label: 'Start wishing',
            expand: true,
            onPressed: _save,
          ),
          const Gap(8),
          TextButton(
            onPressed: () => context.push('/settings/profile'),
            child: const Text('More profile settings'),
          ),
        ],
      ),
    );
  }
}
