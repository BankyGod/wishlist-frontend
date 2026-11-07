import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:wishlist/app/app_providers.dart';
import 'package:wishlist/features/auth/presentation/auth_screen.dart';
import 'package:wishlist/features/auth/presentation/create_account_screen.dart';
import 'package:wishlist/features/auth/presentation/otp_screen.dart';
import 'package:wishlist/features/auth/presentation/profile_setup_screen.dart';
import 'package:wishlist/features/board/presentation/vision_board_screen.dart';
import 'package:wishlist/features/gamification/presentation/stardust_screen.dart';
import 'package:wishlist/features/gamification/presentation/trophy_room_screen.dart';
import 'package:wishlist/features/home/presentation/app_shell.dart';
import 'package:wishlist/features/lists/presentation/bin_screen.dart';
import 'package:wishlist/features/lists/presentation/list_screen.dart';
import 'package:wishlist/features/notifications/presentation/inbox_screen.dart';
import 'package:wishlist/features/onboarding/presentation/onboarding_screen.dart';
import 'package:wishlist/features/onboarding/presentation/splash_screen.dart';
import 'package:wishlist/features/savings/presentation/savings_screen.dart';
import 'package:wishlist/features/settings/presentation/appearance_screen.dart';
import 'package:wishlist/features/settings/presentation/help_screen.dart';
import 'package:wishlist/features/settings/presentation/privacy_screen.dart';
import 'package:wishlist/features/settings/presentation/profile_settings_screen.dart';
import 'package:wishlist/features/settings/presentation/settings_screen.dart';
import 'package:wishlist/features/sharing/presentation/share_list_screen.dart';
import 'package:wishlist/features/wishes/presentation/celebration_screen.dart';
import 'package:wishlist/features/wishes/presentation/edit_wish_screen.dart';
import 'package:wishlist/features/wishes/presentation/grant_screen.dart';
import 'package:wishlist/features/wishes/presentation/wish_detail_screen.dart';

bool _isAuthRoute(String location) {
  return location == '/splash' ||
      location == '/onboarding' ||
      location == '/auth' ||
      location.startsWith('/auth/') ||
      location == '/profile-setup';
}

final routerProvider = Provider<GoRouter>((ref) {
  final store = ref.read(demoStoreProvider);

  final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: store,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final signedIn = store.signedIn;
      final onboarded = store.onboardingComplete;

      if (loc == '/splash') {
        if (signedIn) return '/home';
        return null;
      }
      if (signedIn) {
        // Guests may still open create-account / OTP / vibe setup to upgrade.
        final guestUpgrade = store.profile.isGuest &&
            (loc == '/auth/create' ||
                loc.startsWith('/auth/otp') ||
                loc == '/profile-setup');
        if (_isAuthRoute(loc) && !guestUpgrade) return '/home';
        return null;
      }
      if (_isAuthRoute(loc)) return null;
      return onboarded ? '/auth' : '/onboarding';
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreateAccountScreen(),
          ),
          GoRoute(
            path: 'otp',
            builder: (context, state) {
              final extra = state.extra;
              String? channel;
              String? value;
              Map<String, dynamic>? pending;
              if (extra is Map) {
                channel = extra['channel'] as String?;
                value = extra['value'] as String?;
                final rawPending = extra['pending'];
                if (rawPending is Map) {
                  pending = Map<String, dynamic>.from(rawPending);
                }
              }
              return OtpScreen(
                channel: channel,
                value: value,
                pendingProfile: pending,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      // One shell hosts Home / Jar / Shelf / Me via IndexedStack.
      GoRoute(
        path: '/home',
        builder: (context, state) => AppShell(),
      ),
      GoRoute(
        path: '/lists/:listId',
        builder: (context, state) =>
            ListScreen(listId: state.pathParameters['listId']!),
        routes: [
          GoRoute(
            path: 'board',
            builder: (context, state) =>
                VisionBoardScreen(listId: state.pathParameters['listId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/wishes/:wishId',
        builder: (context, state) =>
            WishDetailScreen(wishId: state.pathParameters['wishId']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) =>
                EditWishScreen(wishId: state.pathParameters['wishId']!),
          ),
          GoRoute(
            path: 'savings',
            builder: (context, state) =>
                SavingsScreen(wishId: state.pathParameters['wishId']!),
          ),
          GoRoute(
            path: 'grant',
            builder: (context, state) =>
                GrantScreen(wishId: state.pathParameters['wishId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/celebration/:wishId',
        builder: (context, state) =>
            CelebrationScreen(wishId: state.pathParameters['wishId']!),
      ),
      GoRoute(
        path: '/share/:listId',
        builder: (context, state) =>
            ShareListScreen(listId: state.pathParameters['listId']!),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileSettingsScreen(),
          ),
          GoRoute(
            path: 'appearance',
            builder: (context, state) => const AppearanceScreen(),
          ),
          GoRoute(
            path: 'help',
            builder: (context, state) => const HelpScreen(),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacyScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/trophies',
        builder: (context, state) => const TrophyRoomScreen(),
      ),
      GoRoute(
        path: '/stardust',
        builder: (context, state) => const StardustScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const InboxScreen(),
      ),
      GoRoute(
        path: '/bin',
        builder: (context, state) => const BinScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
