import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/core/config/app_config.dart';
import 'package:wishlist/core/theme/font_packs.dart';
import 'package:wishlist/core/theme/wishlist_colors.dart';
import 'package:wishlist/features/auth/presentation/otp_screen.dart';
import 'package:wishlist/features/settings/presentation/help_screen.dart';
import 'package:wishlist/features/settings/presentation/privacy_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OTP rejects wrong code', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev),
        ],
        child: const MaterialApp(home: OtpScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pump();
    await tester.tap(find.text('Verify'));
    await tester.pump();
    expect(find.textContaining('Wrong code'), findsOneWidget);
    expect(find.textContaining(OtpScreen.demoCode), findsWidgets);
  });

  testWidgets('Help and Privacy screens render content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpScreen()));
    expect(find.text('Quick tips'), findsOneWidget);
    expect(find.text('Snap a wish'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: PrivacyScreen()));
    expect(find.text('Your wishes, your rules'), findsOneWidget);
    expect(find.textContaining('on device'), findsWidgets);
  });

  test('theme notifier persists palette id keys', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.dev),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(wishlistThemeProvider.notifier);
    notifier.update(
      (t) => t.copyWith(
        palette: WishlistThemePalette.byId(WishlistThemeId.forest),
        fontPack: FontPack.byId(FontPackId.clean),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('wishlist_theme_palette'), 'forest');
    expect(prefs.getString('wishlist_font_pack'), 'clean');
  });
}
