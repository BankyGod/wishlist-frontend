import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/widgets/brand_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    final store = ref.read(demoStoreProvider);
    final config = ref.read(appConfigProvider);
    await store.ensureHydrated();
    if (!mounted) return;

    // Demo flavor: jump straight into the seeded app so Home is never empty.
    if (config.demoMode && !store.signedIn) {
      store.signInAsGuest();
      context.go('/home');
      return;
    }

    if (store.signedIn) {
      context.go('/home');
      return;
    }
    context.go(store.onboardingComplete ? '/auth' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLogo(size: 200)
                .animate()
                .scale(duration: 700.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 350.ms),
            const SizedBox(height: 20),
            Text(
              'Wish it. Snap it. Chase it.',
              style: text.titleMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
            const SizedBox(height: 28),
            TextButton(
              onPressed: _goNext,
              child: const Text('Enter app'),
            ),
          ],
        ),
      ),
    );
  }
}
