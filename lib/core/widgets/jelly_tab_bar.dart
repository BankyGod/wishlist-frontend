import 'package:flutter/material.dart';

import '../motion/feedback.dart';
import '../theme/theme_context.dart';

/// Sticker-pop bottom nav: Home · Jar · + · Shelf · Me
class JellyTabBar extends StatelessWidget {
  const JellyTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.onAdd,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final p = context.wishPalette;
    final barFill = p.brightness == Brightness.dark ? p.surface : Colors.white;
    final outline = context.wishOutline;

    return Material(
      color: barFill,
      elevation: 12,
      shadowColor: p.onBackground.withValues(alpha: 0.2),
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 10, 8, 10 + bottom),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: outline.withValues(alpha: 0.55), width: 2.5),
          ),
        ),
        child: Row(
          children: [
            _NavItem(
              emoji: '🏠',
              label: 'Home',
              selected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              emoji: '🫙',
              label: 'Jar',
              selected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            Expanded(
              child: Center(
                child: _AddButton(onTap: onAdd),
              ),
            ),
            _NavItem(
              emoji: '🏆',
              label: 'Shelf',
              selected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              emoji: '👤',
              label: 'Me',
              selected: selectedIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final outline = context.wishOutline;

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        WishlistFeedback.tap();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.9 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.secondary,
            shape: BoxShape.circle,
            border: Border.all(color: outline, width: 3),
            boxShadow: [
              BoxShadow(
                color: scheme.onSurface.withValues(alpha: 0.28),
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: InkWell(
        onTap: () {
          WishlistFeedback.tap();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: selected
                ? Border.all(color: scheme.primary, width: 2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: selected ? 22 : 20)),
              const SizedBox(height: 2),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
