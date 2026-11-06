import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wishlist/core/theme/theme_context.dart';
import 'package:wishlist/core/widgets/jelly_tab_bar.dart';
import 'package:wishlist/core/widgets/playful_backdrop.dart';
import 'package:wishlist/features/home/presentation/home_screen.dart';
import 'package:wishlist/features/jar/presentation/jar_screen.dart';
import 'package:wishlist/features/profile/presentation/me_screen.dart';
import 'package:wishlist/features/shelf/presentation/shelf_screen.dart';
import 'package:wishlist/features/wishes/presentation/add_wish_sheet.dart';

/// Home · Jar · Add · Shelf · Me (SRD §7.1).
class AppShell extends ConsumerStatefulWidget {
  AppShell({super.key, int? initialTab}) : initialTab = initialTab ?? 0;

  final int initialTab;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 4);
    if (_tab == 2) _tab = 0;
  }

  int get _stackIndex {
    switch (_tab) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return 0;
    }
  }

  void _onTab(int index) {
    if (index == 2) {
      showAddWishSheet(context, ref);
      return;
    }
    setState(() => _tab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.wishPalette.background,
      body: Column(
        children: [
          Expanded(
            child: PlayfulBackdrop(
              child: IndexedStack(
                index: _stackIndex,
                children: const [
                  HomeScreen(),
                  JarScreen(),
                  ShelfScreen(),
                  MeScreen(),
                ],
              ),
            ),
          ),
          JellyTabBar(
            selectedIndex: _tab,
            onTap: _onTab,
            onAdd: () => showAddWishSheet(context, ref),
          ),
        ],
      ),
    );
  }
}
