import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/motion/feedback.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/wish_image.dart';

/// Full-screen grant celebration (SRD FR-F2): confetti, stamp slam, haptics.
class CelebrationScreen extends ConsumerStatefulWidget {
  const CelebrationScreen({super.key, required this.wishId});

  final String wishId;

  @override
  ConsumerState<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends ConsumerState<CelebrationScreen>
    with SingleTickerProviderStateMixin {
  // Initialize at declaration so hot reload cannot leave `late` fields unset.
  final ConfettiController _centerConfetti =
      ConfettiController(duration: const Duration(seconds: 4));
  final ConfettiController _leftConfetti =
      ConfettiController(duration: const Duration(seconds: 3));
  final ConfettiController _rightConfetti =
      ConfettiController(duration: const Duration(seconds: 3));

  AnimationController? _shake;
  bool _leaving = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startParty());
  }

  @override
  void dispose() {
    _centerConfetti.dispose();
    _leftConfetti.dispose();
    _rightConfetti.dispose();
    _shake?.dispose();
    super.dispose();
  }

  void _startParty() {
    if (!mounted || _started) return;
    _started = true;
    final confettiOn = ref.read(wishlistThemeProvider).confettiEnabled;
    WishlistFeedback.celebration();
    if (confettiOn) {
      _centerConfetti.play();
      _leftConfetti.play();
      _rightConfetti.play();
    }
    _shake?.forward(from: 0);
  }

  void _continue() {
    if (_leaving || !mounted) return;
    _leaving = true;
    WishlistFeedback.success();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final wish = ref.watch(demoStoreProvider).wishById(widget.wishId);
    final title = (wish?.title.isNotEmpty ?? false) ? wish!.title : 'Your wish';
    final size = MediaQuery.sizeOf(context);
    final shake = _shake;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5A2BD1),
                  WishlistColors.wishViolet,
                  WishlistColors.popPink,
                  Color(0xFFFF8A5C),
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -30,
            child: _GlowOrb(
              color: WishlistColors.sunnyGold.withValues(alpha: 0.35),
              size: 160,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -50,
            child: _GlowOrb(
              color: Colors.white.withValues(alpha: 0.18),
              size: 180,
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: _SparkleField())),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _centerConfetti,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.08,
              numberOfParticles: 28,
              maxBlastForce: 28,
              minBlastForce: 10,
              gravity: 0.18,
              colors: const [
                WishlistColors.sunnyGold,
                WishlistColors.popPink,
                Colors.white,
                WishlistColors.mintGreen,
                WishlistColors.skyBlue,
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _leftConfetti,
              blastDirection: -math.pi / 4,
              emissionFrequency: 0.06,
              numberOfParticles: 14,
              maxBlastForce: 22,
              gravity: 0.2,
              colors: const [
                WishlistColors.sunnyGold,
                Colors.white,
                WishlistColors.mintGreen,
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _rightConfetti,
              blastDirection: math.pi + math.pi / 4,
              emissionFrequency: 0.06,
              numberOfParticles: 14,
              maxBlastForce: 22,
              gravity: 0.2,
              colors: const [
                WishlistColors.popPink,
                WishlistColors.sunnyGold,
                Colors.white,
              ],
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _continue,
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: shake == null
                  ? _buildContent(context, title, wish?.coverUrl ?? '', size)
                  : AnimatedBuilder(
                      animation: shake,
                      builder: (context, child) {
                        final t = Curves.easeOut.transform(shake.value);
                        final dx = math.sin(t * math.pi * 6) * (1 - t) * 10;
                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child: child,
                        );
                      },
                      child: _buildContent(
                        context,
                        title,
                        wish?.coverUrl ?? '',
                        size,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String title,
    String coverUrl,
    Size size,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: math.min(360, size.width - 48),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: WishlistColors.mintGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        offset: Offset(6, 6),
                      ),
                    ],
                  ),
                  child: const Text(
                    'GRANTED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      height: 1,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(3.2, 3.2),
                      end: const Offset(1, 1),
                      duration: 700.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 200.ms),
                const Gap(28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: WishlistColors.outline,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        offset: Offset(6, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: WishImage(
                          url: coverUrl,
                          height: 180,
                          width: double.infinity,
                        ),
                      ),
                      const Gap(14),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: WishlistColors.midnightInk,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        'Wish came true ✨',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: WishlistColors.wishViolet.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 280.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.25, end: 0, curve: Curves.easeOutBack),
                const Gap(28),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: _continue,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: WishlistColors.outline,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x44000000),
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Continue wishing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: WishlistColors.wishViolet,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
                const Gap(14),
                Text(
                  'Tap anywhere to skip',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _SparkleField extends StatelessWidget {
  const _SparkleField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SparklePainter());
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (var i = 0; i < 24; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = 1.5 + rnd.nextDouble() * 2.5;
      canvas.drawCircle(Offset(x, y), r, paint);
      if (i.isEven) {
        canvas.drawLine(
          Offset(x - 5, y),
          Offset(x + 5, y),
          paint..strokeWidth = 1.5,
        );
        canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
