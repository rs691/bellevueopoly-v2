import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/main_scaffold.dart';
import '../screens/image_upload_screen.dart';

// Screens
import '../screens/business_detail_screen.dart';
import '../screens/business_list_screen.dart';
import '../screens/home_screen.dart'; // Map Screen
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/mobile_landing_screen.dart';
import '../screens/admin_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String landing = '/landing';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';

  // Authenticated Shell Routes
  static const String home = '/';       // <--- THIS must be '/'
  static const String map = '/map';
  static const String businesses = '/businesses';
  static const String profile = '/profile';
  static const String businessDetail = 'business/:id';
  static const String upload = '/upload';
  static const String admin = '/admin';
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
  };

  return GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.landing, builder: (context, state) => const LandingScreen()),
      GoRoute(path: AppRoutes.welcome, builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegistrationScreen()),
      GoRoute(path: AppRoutes.upload, builder: (context, state) => const ImageUploadScreen()),
      GoRoute(path: AppRoutes.admin, builder: (context, state) => const AdminScreen()),




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
          // 2. MAP TAB
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: AppRoutes.businessDetail,
                parentNavigatorKey: _rootNavigatorKey, // Covers the bottom nav
                pageBuilder: (context, state) {
                  final String id = state.pathParameters['id']!;

                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: BusinessDetailScreen(businessId: id),
                    barrierDismissible: true,
                    barrierColor: Colors.black54, // Darkens the screen behind it
                    opaque: false, // Allows transparency
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      // Scale and Fade animation like a popup
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  );
                },
              ),
            ],
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
