import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/motion/feedback.dart';
import 'package:wishlist/core/motion/motion_tokens.dart';
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/sticker_button.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';
import 'package:wishlist/core/widgets/wish_image.dart';
import 'package:wishlist/features/lists/domain/models.dart';

class JarScreen extends ConsumerStatefulWidget {
  const JarScreen({super.key});

  @override
  ConsumerState<JarScreen> createState() => _JarScreenState();
}

class _JarScreenState extends ConsumerState<JarScreen>
    with SingleTickerProviderStateMixin {
  Wish? _drawn;
  bool _busy = false;
  bool _revealing = false;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _draw() async {
    if (_busy) return;
    final open = ref.read(demoStoreProvider).openWishes;
    if (open.isEmpty) return;

    final level = ref.read(wishlistThemeProvider).animationLevel;
    final shakeFor = MotionTokens.scale(MotionTokens.hero, level);
    final holdFor = MotionTokens.scale(
      const Duration(milliseconds: 850),
      level,
    );
    _shake.duration = shakeFor == Duration.zero
        ? const Duration(milliseconds: 1)
        : shakeFor;

    setState(() {
      _busy = true;
      _revealing = false;
      _drawn = null;
    });

    WishlistFeedback.tap();
    if (level != AnimationLevel.off) {
      await _shake.forward(from: 0);
    }

    if (!mounted) return;
    setState(() => _revealing = true);
    WishlistFeedback.warning();
    if (holdFor > Duration.zero) {
      await Future<void>.delayed(holdFor);
    }

    final pick = ref.read(demoStoreProvider).drawFromJar();
    if (!mounted) return;
    WishlistFeedback.success();
    setState(() {
      _drawn = pick;
      _revealing = false;
      _busy = false;
    });
  }

  void _clearDrawn() {
    if (_busy) return;
    setState(() => _drawn = null);
  }

  @override
  Widget build(BuildContext context) {
    final open = ref.watch(demoStoreProvider).openWishes;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cardFill = context.wishCardFill;
    final canDraw = open.isNotEmpty && !_busy;
    final showingResult = _revealing || _drawn != null;
    final jarSize = showingResult ? 140.0 : 200.0;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text('Wish Jar', style: text.headlineMedium),
          Text(
            open.isEmpty
                ? 'Add open wishes on Home first'
                : _busy
                    ? (_revealing
                        ? 'Pulling a wish out…'
                        : 'Shaking the jar…')
                    : '${open.length} wishes inside — tap the jar',
            style: text.bodyMedium?.copyWith(color: context.wishMutedInk),
          ),
          const Gap(24),
          Center(
            child: GestureDetector(
              onTap: canDraw ? _draw : null,
              child: AnimatedBuilder(
                animation: _shake,
                builder: (context, child) {
                  final t = _shake.value;
                  final wobble =
                      math.sin(t * math.pi * 12) * (1 - t) * 0.18;
                  final bounce =
                      math.sin(t * math.pi * 6) * (1 - t) * 10;
                  return Transform.translate(
                    offset: Offset(bounce, 0),
                    child: Transform.rotate(angle: wobble, child: child),
                  );
                },
                child: AnimatedScale(
                  scale: _busy ? 1.06 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    width: jarSize,
                    height: jarSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cardFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.28),
                          offset: const Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      '🫙',
                      style: TextStyle(fontSize: showingResult ? 64 : 96),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(24),
          if (_revealing)
            StickerCard(
              color: cardFill,
              child: Column(
                children: [
                  SizedBox(
                    height: 96,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: scheme.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const Gap(10),
                  Text('Drawing your wish…', style: text.titleMedium),
                ],
              ),
            )
          else if (_drawn != null)
            StickerCard(
              color: cardFill,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: WishImage(
                      url: _drawn!.coverUrl,
                      height: 110,
                      width: double.infinity,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    _drawn!.title.isEmpty ? 'Untitled wish' : _drawn!.title,
                    style: text.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(12),
                  StickerButton(
                    label: 'Open wish',
                    expand: true,
                    onPressed: () => context.push('/wishes/${_drawn!.id}'),
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: StickerButton(
                          label: 'Put back',
                          filled: false,
                          onPressed: _clearDrawn,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: StickerButton(
                          label: 'Grant',
                          color: scheme.tertiary,
                          onPressed: () =>
                              context.push('/wishes/${_drawn!.id}/grant'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            StickerButton(
              label: open.isEmpty
                  ? 'No wishes yet'
                  : (_busy ? 'Drawing…' : 'Draw a wish'),
              expand: true,
              onPressed: canDraw ? _draw : null,
            ),
        ],
      ),
    );
  }
}
