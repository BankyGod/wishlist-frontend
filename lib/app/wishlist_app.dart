import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/app/app_router.dart';
import 'package:wishlist/core/config/app_config.dart';
import 'package:wishlist/core/motion/haptics.dart';
import 'package:wishlist/core/motion/sounds.dart';

Future<void> runWishlistApp(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Warm the audio player so the first Settings preview isn't silent.
  await WishlistSounds.init();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: WishlistApp(config: config),
    ),
  );
}

class WishlistApp extends ConsumerWidget {
  const WishlistApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(wishlistThemeProvider);
    final router = ref.watch(routerProvider);

    // Keep static gates in sync with Settings toggles.
    WishlistSounds.enabled = themeData.soundsEnabled;
    WishlistHaptics.enabled = themeData.hapticsEnabled;

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: config.flavor != AppFlavor.prod,
      theme: themeData.toThemeData(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        final bodyStyle = Theme.of(context).textTheme.bodyMedium ??
            const TextStyle(fontSize: 14);
        return DefaultTextStyle(
          style: bodyStyle,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
