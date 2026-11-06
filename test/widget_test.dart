import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/app/wishlist_app.dart';
import 'package:wishlist/core/config/app_config.dart';
import 'package:wishlist/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('demo splash lands on home with lists', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev),
        ],
        child: const WishlistApp(config: AppConfig.dev),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Enter app'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.getSize(find.byType(HomeScreen)).height, greaterThan(100));
    expect(find.textContaining('Hey,'), findsOneWidget);
    expect(find.textContaining('Someday'), findsOneWidget);

    await tester.tap(find.text('Me'));
    await tester.pump();
    expect(find.text('Trophy room'), findsOneWidget);

    await tester.tap(find.text('Jar'));
    await tester.pump();
    expect(find.text('Wish Jar'), findsOneWidget);

    await tester.tap(find.text('Shelf'));
    await tester.pump();
    expect(find.textContaining('Granted shelf'), findsOneWidget);
  });
}
