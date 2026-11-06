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
    context.push('/auth/otp');
  }

  void _guest() {
    ref.read(demoStoreProvider).signInAsGuest();
    context.go('/home');
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
                StickerButton(label: 'Continue', expand: true, onPressed: _continue),
              ],
            ),
          ),
          const Gap(16),
          StickerButton(
            label: 'Continue with Google',
            filled: false,
            icon: Icons.g_mobiledata_rounded,
            expand: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google sign-in coming soon')),
              );
            },
          ),
          const Gap(16),
          StickerButton(
            label: 'Continue as guest (demo)',
            expand: true,
            color: Theme.of(context).colorScheme.primary,
            onPressed: _guest,
          ),
          const Gap(8),
          Text(
            'Explore the full app with seeded Accra demo data.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
