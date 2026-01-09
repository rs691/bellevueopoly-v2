import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/main_scaffold.dart';
import '../screens/image_upload_screen.dart';

// Screens
import '../screens/business_detail_screen.dart';
import '../screens/business_list_screen.dart';
// import '../screens/home_screen.dart'; // Map Screen
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/mobile_landing_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/play_session_screen.dart';
import '../screens/leaderboard_screen.dart';
import "../screens/casual_games_lobby_screen.dart";
import '../screens/rewards_nearby_screen.dart';
import '../screens/monopoly_board_screen.dart';
import '../screens/password_reset_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/checkin_history_screen.dart';
import '../screens/instructions_screen.dart';
import '../screens/admin_test_screen.dart';
import '../screens/rules_and_prizes_screen.dart';
import '../screens/prizes_screen.dart';
import '../screens/terms_screen.dart';
import '../screens/qr_scan_history_screen.dart';
import '../models/game_rules.dart';
import '../screens/stop_hub_screen.dart';
import '../screens/game_hub_screen.dart';
import '../screens/game_settings_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/stop_hub_categories/boulevard_partners_screen.dart';
import '../screens/stop_hub_categories/patriotic_partners_screen.dart';
import '../screens/stop_hub_categories/merch_partners_screen.dart';
import '../screens/stop_hub_categories/giving_partners_screen.dart';
import '../screens/stop_hub_categories/community_chest_screen.dart';
import '../screens/stop_hub_categories/wild_cards_screen.dart';
import '../screens/stop_hub_categories/fun_house_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String landing = '/landing';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String passwordReset = '/password-reset';
  static const String emailVerification = '/email-verification';

  // Authenticated Shell Routes
  static const String home = '/'; // <--- THIS must be '/'
  static const String stopHub = '/stop-hub';
  static const String gameHub = '/game-hub';
  static const String businesses = '/businesses';
  static const String profile = '/profile';
  // Root-level business detail modal (works from any tab without changing it)
  static const String businessDetail = '/business/:id';
  static const String upload = '/upload';
  static const String admin = '/admin';
  static const String leaderboard = '/leaderboard';
  static const String game = '/game';
  static const String casualGames = '/casual-games';
  static const String nearMe = '/near-me';
  static const String monopolyBoard = '/monopolyBoard';
  static const String checkinHistory = '/checkin-history';
  static const String instructions = '/instructions';
  static const String adminTest = '/admin-test';
  static const String rulesAndPrizes = '/rules-and-prizes';
  static const String prizes = '/prizes';
  static const String terms = '/terms';
  static const String qrScanHistory = '/qr-scan-history';
  // Stop Hub Categories
  static const String boulevardPartners = '/stop-hub/boulevard-partners';
  static const String patrioticPartners = '/stop-hub/patriotic-partners';
  static const String merchPartners = '/stop-hub/merch-partners';
  static const String givingPartners = '/stop-hub/giving-partners';
  static const String communityChest = '/stop-hub/community-chest';
  static const String wildCards = '/stop-hub/wild-cards';
  static const String funHouse = '/stop-hub/fun-house';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  final isAuthenticated = authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (err, stack) => false,
  );

  final publicRoutes = {
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.welcome,
    AppRoutes.landing,
    AppRoutes.splash,
    AppRoutes.passwordReset,
    AppRoutes.emailVerification,
  };

  return GoRouter(
    initialLocation: AppRoutes.landing,
    navigatorKey: _rootNavigatorKey,
    routes: [
      // ROOT-LEVEL MODAL BUSINESS DETAIL ROUTE
      GoRoute(
        path: AppRoutes.businessDetail,
        pageBuilder: (context, state) {
          final String id = state.pathParameters['id']!;

          return CustomTransitionPage(
            key: state.pageKey,
            child: BusinessDetailScreen(businessId: id),
            barrierDismissible: true,
            barrierColor: Colors.black54,
            opaque: false,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.landing,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.passwordReset,
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (context, state) {
          final email = state.extra as String?;
          return EmailVerificationScreen(
            email: email ?? 'your-email@example.com',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.upload,
        builder: (context, state) => const ImageUploadScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminTest,
        builder: (context, state) => const AdminTestScreen(),
      ),
      // SHELL ROUTE (Persistent Bottom Nav)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          // 1. HOME TAB (The Grid View)
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const MobileLandingScreen(),
          ),
          // 2. STOP HUB TAB (Business Categories)
          GoRoute(
            path: AppRoutes.stopHub,
            builder: (context, state) => const StopHubScreen(),
            routes: [
              GoRoute(
                path: 'boulevard-partners',
                pageBuilder: (context, state) => ZoomTransitionPage(
                  key: state.pageKey,
                  child: const BoulevardPartnersScreen(),
                ),
              ),
              GoRoute(
                path: 'patriotic-partners',
                pageBuilder: (context, state) => ZoomTransitionPage(
                  key: state.pageKey,
                  child: const PatrioticPartnersScreen(),
                ),
              ),
              GoRoute(
                path: 'merch-partners',
                pageBuilder: (context, state) => ZoomTransitionPage(
                  key: state.pageKey,
                  child: const MerchPartnersScreen(),
                ),
              ),
              GoRoute(
                path: 'giving-partners',
                pageBuilder: (context, state) => ZoomTransitionPage(
                  key: state.pageKey,
                  child: const GivingPartnersScreen(),
                ),
              ),
              GoRoute(
                path: 'community-chest',
                pageBuilder: (context, state) => ZoomTransitionPage(
                  key: state.pageKey,
                  child: const CommunityChestScreen(),
                ),
              ),
              GoRoute(
                path: 'wild-cards',
                pageBuilder: (context, state) => ZoomTransitionPage(
                  key: state.pageKey,
                  child: const WildCardsScreen(),
                ),
              ),
              GoRoute(
                path: 'fun-house',
                pageBuilder: (context, state) => ZoomTransitionPage(
                  key: state.pageKey,
                  child: const FunHouseScreen(),
                ),
              ),
            ],
          ),

          // 2B. GAME HUB TAB (Monopoly, Casual Games, Leaderboard)
          GoRoute(
            path: AppRoutes.gameHub,
            builder: (context, state) => const GameHubScreen(),
          ),

          // 3. BUSINESS LIST
          GoRoute(
            path: AppRoutes.businesses,
            builder: (context, state) => const BusinessListScreen(),
          ),

          // 4. PROFILE
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          // 5. GAME
          GoRoute(
            path: AppRoutes.game,
            builder: (context, state) => const PlaySessionScreen(),
          ),
          // 6. LEADERBOARD
          GoRoute(
            path: AppRoutes.leaderboard,
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.casualGames,
            builder: (context, state) => const CasualGamesLobbyScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const GameSettingsScreen(),
              ),
              GoRoute(
                path: 'achievements',
                builder: (context, state) => const AchievementsScreen(),
              ),
            ],
          ),
          // 7. NEAR ME (Map with nearby rewards)
          GoRoute(
            path: AppRoutes.nearMe,
            builder: (context, state) => const RewardsNearbyScreen(),
          ),
          // 8. MONOPOLY BOARD GAME
          GoRoute(
            path: AppRoutes.monopolyBoard,
            builder: (context, state) => const MonopolyBoardScreen(),
          ),
          // 9. CHECK-IN HISTORY
          GoRoute(
            path: AppRoutes.checkinHistory,
            builder: (context, state) => const CheckinHistoryScreen(),
          ),
          // 10. INSTRUCTIONS
          GoRoute(
            path: AppRoutes.instructions,
            builder: (context, state) => const InstructionsScreen(),
          ),
          // 11. PRIZES
          GoRoute(
            path: AppRoutes.prizes,
            builder: (context, state) => const PrizesScreen(),
          ),
          // 11B. RULES & PRIZES (full details)
          GoRoute(
            path: AppRoutes.rulesAndPrizes,
            builder: (context, state) {
              final gameRules = state.extra as GameRules?;
              return RulesAndPrizesScreen(
                gameRules: gameRules ?? const GameRulesPlaceholder(),
              );
            },
          ),
          // 12. TERMS & CONDITIONS
          GoRoute(
            path: AppRoutes.terms,
            builder: (context, state) => const TermsScreen(),
          ),
          // 13. QR SCAN HISTORY
          GoRoute(
            path: AppRoutes.qrScanHistory,
            builder: (context, state) {
              final playerId = state.extra as String?;
              if (playerId == null) {
                return const Scaffold(
                  body: Center(child: Text('Player ID required')),
                );
              }
              return QrScanHistoryScreen(playerId: playerId);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (location == AppRoutes.splash) return null;

      if (isAuthenticated) {
        // If logged in and trying to access login/landing pages, send to HOME
        if (location == AppRoutes.login ||
            location == AppRoutes.register ||
            location == AppRoutes.landing ||
            location == AppRoutes.welcome) {
          return AppRoutes.home; // <--- Redirects to MobileLandingScreen
        }
        return null;
      } else {
        if (publicRoutes.contains(location)) return null;
        return AppRoutes.landing;
      }
    },
  );
});

// Custom Transition Page for Zoom/Fade Effect
class ZoomTransitionPage<T> extends CustomTransitionPage<T> {
  ZoomTransitionPage({
    required Widget child,
    required LocalKey key,
  }) : super(
          key: key,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuart,
                  reverseCurve: Curves.easeInQuart,
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}

