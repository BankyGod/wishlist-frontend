import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/brand_logo.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final usingPhone = _tabs.index == 0;
    if (usingPhone && phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a phone number')),
      );
      return;
    }
    if (!usingPhone && (email.isEmpty || !email.contains('@'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }
    context.push(
      '/auth/otp',
      extra: {
        'channel': usingPhone ? 'phone' : 'email',
        'value': usingPhone ? phone : email,
      },
    );
  }

  void _guest() {
    ref.read(demoStoreProvider).signInAsGuest();
    context.go('/home');
  }

  Future<void> _providerSignIn({
    required String provider,
    required String displayName,
    required String email,
    required String handle,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    ref.read(demoStoreProvider).signIn(
          displayName: displayName,
          email: email,
          handle: handle,
        );
    setState(() => _busy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed in with $provider (demo)')),
    );
    context.go('/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome back')),
      body: ListView(
        padding: context.wishScrollPadding(),
        children: [
          const Center(child: BrandLogo(size: 132)),
          const Gap(16),
          StickerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  controller: _tabs,
                  tabs: const [
                    Tab(text: 'Phone'),
                    Tab(text: 'Email'),
                  ],
                ),
                const Gap(16),
                SizedBox(
                  height: 56,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          hintText: '+233 …',
                        ),
                      ),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                StickerButton(
                  label: 'Continue',
                  expand: true,
                  onPressed: _busy ? null : _continue,
                ),
              ],
            ),
          ),
          const Gap(12),
          StickerButton(
            label: 'Create account',
            expand: true,
            color: Theme.of(context).colorScheme.primary,
            onPressed: _busy ? null : () => context.push('/auth/create'),
          ),
          const Gap(16),
          StickerButton(
            label: _busy ? 'Signing in…' : 'Continue with Google',
            filled: false,
            icon: Icons.g_mobiledata_rounded,
            expand: true,
            onPressed: _busy
                ? null
                : () => _providerSignIn(
                      provider: 'Google',
                      displayName: 'Ama Google',
                      email: 'ama.google@example.com',
                      handle: 'ama_google',
                    ),
          ),
          const Gap(8),
          StickerButton(
            label: _busy ? 'Signing in…' : 'Continue with Apple',
            filled: false,
            icon: Icons.apple,
            expand: true,
            onPressed: _busy
                ? null
                : () => _providerSignIn(
                      provider: 'Apple',
                      displayName: 'Ama Apple',
                      email: 'ama.apple@example.com',
                      handle: 'ama_apple',
                    ),
          ),
          const Gap(16),
          StickerButton(
            label: 'Continue as guest (demo)',
            filled: false,
            expand: true,
            onPressed: _busy ? null : _guest,
          ),
          const Gap(8),
          Text(
            'Create account or OAuth completes a local demo session until the real API is connected.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
