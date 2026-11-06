import 'package:wishlist/app/wishlist_app.dart';
import 'package:wishlist/core/config/app_config.dart';

Future<void> main() async {
  await runWishlistApp(AppConfig.staging);
}
