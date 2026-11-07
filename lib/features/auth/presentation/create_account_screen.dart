import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/brand_logo.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _handleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _currency = 'GHS';
  bool _obscure = true;

  static const _currencies = ['GHS', 'USD', 'EUR', 'GBP', 'NGN'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _handleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameCtrl.text.trim();
    final handle = _normalizeHandle(_handleCtrl.text);
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    context.push(
      '/auth/otp',
      extra: {
        'channel': 'email',
        'value': email,
        'pending': {
          'displayName': name,
          'handle': handle.isEmpty
              ? name.toLowerCase().replaceAll(' ', '_')
              : handle,
          'email': email,
          'phone': phone.isEmpty ? null : phone,
          'currencyDefault': _currency,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: context.wishScrollPadding(),
          children: [
            const Center(child: BrandLogo(size: 96)),
            const Gap(12),
            Text(
              'Wish it. Snap it. Chase it.',
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(color: context.wishMutedInk),
            ),
            const Gap(20),
            StickerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      hintText: 'Ama',
                    ),
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
                      hintText: 'ama_accra',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                    ],
                    validator: (v) {
                      final h = _normalizeHandle(v ?? '');
                      if (h.length < 3) return 'At least 3 characters';
                      return null;
                    },
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                    ),
                    validator: (v) {
                      final email = v?.trim() ?? '';
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                      hintText: '+233 …',
                    ),
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password (demo)',
                      hintText: 'At least 6 characters',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return 'Use at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const Gap(16),
                  Text('Default currency', style: text.titleSmall),
                  const Gap(8),
                  Wrap(
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
                ],
              ),
            ),
            const Gap(20),
            StickerButton(
              label: 'Continue',
              expand: true,
              onPressed: _submit,
            ),
            const Gap(8),
            TextButton(
              onPressed: () => context.go('/auth'),
              child: const Text('Already have an account? Sign in'),
            ),
            const Gap(8),
            Text(
              'Demo only — password stays on this device flow and is not uploaded.',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: context.wishMutedInk),
            ),
          ],
        ),
      ),
    );
  }
}
