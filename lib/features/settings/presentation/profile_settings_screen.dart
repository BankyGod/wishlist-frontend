import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/motion/feedback.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/core/widgets/squash_tap.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _handleCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late String _emoji;
  late int _color;
  late String _currency;
  bool _saving = false;

  static const _emojis = [
    '✨',
    '🌟',
    '💫',
    '🦄',
    '🌈',
    '🔥',
    '💚',
    '🎯',
    '🪼',
    '🦋',
  ];
  static const _colors = [
    WishlistColors.wishViolet,
    WishlistColors.popPink,
    WishlistColors.mintGreen,
    WishlistColors.sunnyGold,
    WishlistColors.skyBlue,
    Color(0xFF1B7A4A),
  ];
  static const _currencies = ['GHS', 'USD', 'EUR', 'GBP', 'NGN'];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(demoStoreProvider).profile;
    _nameCtrl = TextEditingController(text: profile.displayName);
    _handleCtrl = TextEditingController(text: profile.handle);
    _emailCtrl = TextEditingController(text: profile.email ?? '');
    _phoneCtrl = TextEditingController(text: profile.phone ?? '');
    _emoji = profile.avatarEmoji;
    _color = profile.favouriteColor;
    _currency = profile.currencyDefault;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _handleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _normalizeHandle(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    FocusScope.of(context).unfocus();

    final store = ref.read(demoStoreProvider);
    final handle = _normalizeHandle(_handleCtrl.text);
    store.updateProfile(
      store.profile.copyWith(
        displayName: _nameCtrl.text.trim(),
        handle: handle,
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        avatarEmoji: _emoji,
        favouriteColor: _color,
        currencyDefault: _currency,
        isGuest: false,
      ),
    );
    await WishlistFeedback.success();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final outline = context.wishOutline;
    final profile = ref.watch(demoStoreProvider).profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: context.wishScrollPadding(extraBottom: 40),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(_color),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: outline, width: 2.5),
                ),
                child: Text(_emoji, style: const TextStyle(fontSize: 44)),
              ),
            ),
            const Gap(8),
            Text(
              profile.isGuest ? 'Upgrade your guest vibe' : 'Edit your profile',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: context.wishMutedInk),
            ),
            const Gap(20),
            StickerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Display name'),
                    validator: (v) {
                      if (v == null || v.trim().length < 2) {
                        return 'Enter your name';
                      }
                      return null;
                    },
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _handleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Handle',
                      prefixText: '@',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                    ],
                    validator: (v) {
                      if (_normalizeHandle(v ?? '').length < 3) {
                        return 'At least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) {
                      final email = v?.trim() ?? '';
                      if (email.isEmpty) return null;
                      if (!email.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Text('Avatar', style: text.titleMedium),
            const Gap(8),
            StickerCard(
              child: Wrap(
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
                      child: Text(e, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(16),
            Text('Favourite colour', style: text.titleMedium),
            const Gap(8),
            StickerCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
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
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(16),
            Text('Default currency', style: text.titleMedium),
            const Gap(8),
            StickerCard(
              child: Wrap(
                spacing: 8,
                children: [
                  for (final c in _currencies)
                    ChoiceChip(
                      label: Text(c),
                      selected: _currency == c,
                      onSelected: (_) => setState(() => _currency = c),
                    ),
                ],
              ),
            ),
            const Gap(24),
            StickerButton(
              label: _saving ? 'Saving…' : 'Save profile',
              expand: true,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
