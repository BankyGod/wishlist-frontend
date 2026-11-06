import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/theme/font_packs.dart' show FontPack;
import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/core/widgets/sticker_card.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  TextStyle _packSample(FontPack pack, {required Color color}) {
    try {
      return GoogleFonts.getFont(
        pack.displayFamily,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(wishlistThemeProvider);
    final notifier = ref.read(wishlistThemeProvider.notifier);
    final p = themeData.palette;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: context.wishScrollPadding(),
        children: [
          StickerCard(
            rotation: -0.02,
            color: p.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live preview',
                  style: text.labelSmall?.copyWith(color: Colors.white70),
                ),
                const Gap(8),
                Text(
                  'Wish sticker',
                  style: _packSample(themeData.fontPack, color: Colors.white),
                ),
                Text(
                  'GHS 980 · ${p.label} · ${themeData.fontPack.label}',
                  style: text.bodyMedium?.copyWith(
                    color: p.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),
          Text('Theme colour', style: text.titleLarge),
          const Gap(4),
          Text(
            'Applies to backgrounds, buttons, chips, and accents everywhere.',
            style: text.bodySmall?.copyWith(color: context.wishMutedInk),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WishlistThemePalette.catalogue.map((palette) {
              final selected = themeData.palette.id == palette.id;
              return FilterChip(
                selected: selected,
                avatar: CircleAvatar(
                  backgroundColor: palette.primary,
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                label: Text(palette.label),
                onSelected: (_) {
                  notifier.setTheme(themeData.copyWith(palette: palette));
                },
              );
            }).toList(),
          ),
          const Gap(24),
          Text('Font pack', style: text.titleLarge),
          const Gap(4),
          Text(
            'Titles, buttons, and body copy follow the pack you pick.',
            style: text.bodySmall?.copyWith(color: context.wishMutedInk),
          ),
          const Gap(8),
          ...FontPack.catalogue.map((pack) {
            final selected = themeData.fontPack.id == pack.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StickerCard(
                onTap: () {
                  notifier.setTheme(themeData.copyWith(fontPack: pack));
                },
                color: selected
                    ? scheme.primary.withValues(alpha: 0.16)
                    : context.wishCardFill,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    pack.label,
                    style: _packSample(pack, color: scheme.onSurface),
                  ),
                  subtitle: Text(
                    'Aa Bb Cc — ${pack.headingFamily} / ${pack.bodyFamily}',
                    style: text.bodySmall,
                  ),
                  trailing: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
