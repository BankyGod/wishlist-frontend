import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/brand_logo.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const List<(String?, String, String)> _pages = [
    (null, 'Dream big', 'Collect wishes with photos, notes, and vibes.'),
    ('💰', 'Save & reveal', 'Track savings and watch your wish come into focus.'),
    ('🎉', 'Grant & celebrate', 'When it\'s yours, slide to grant and party!'),
  ];

  void _finish(WidgetRef ref) {
    ref.read(demoStoreProvider).completeOnboarding();
    context.go('/auth');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _finish(ref),
                    child: const Text('Skip'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      final (emoji, title, body) = _pages[i];
                      return Padding(
                        padding: const EdgeInsets.all(WishlistColors.screenPadding),
                        child: StickerCard(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (emoji == null)
                                const BrandLogo(size: 148)
                              else
                                Text(emoji, style: const TextStyle(fontSize: 72)),
                              const Gap(24),
                              Text(title, style: Theme.of(context).textTheme.headlineLarge),
                              const Gap(12),
                              Text(
                                body,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => Container(
                      width: _page == i ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _page == i
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    WishlistColors.screenPadding,
                    8,
                    WishlistColors.screenPadding,
                    WishlistColors.screenPadding + context.wishBottomInset,
                  ),
                  child: StickerButton(
                    label: _page == _pages.length - 1 ? 'Get started' : 'Next',
                    expand: true,
                    onPressed: () {
                      if (_page < _pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                        );
                      } else {
                        _finish(ref);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
