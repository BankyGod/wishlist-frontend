enum AppFlavor { dev, staging, prod }

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
    this.demoMode = true,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String appName;
  final bool demoMode;

  static const dev = AppConfig(
    flavor: AppFlavor.dev,
    apiBaseUrl: 'http://10.0.2.2:8000/v1',
    appName: 'Wishlist Dev',
    demoMode: true,
  );

  static const staging = AppConfig(
    flavor: AppFlavor.staging,
    apiBaseUrl: 'https://staging-api.wishlist.app/v1',
    appName: 'Wishlist Staging',
    demoMode: false,
  );

  static const prod = AppConfig(
    flavor: AppFlavor.prod,
    apiBaseUrl: 'https://api.wishlist.app/v1',
    appName: 'Wishlist',
    demoMode: false,
  );
}
