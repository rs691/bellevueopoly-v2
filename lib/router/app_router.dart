// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // IMPORTANT: Add this import for User? type

// Assuming these are in your providers/index.dart
import '../providers/index.dart';

// Import all screens used in the router
// Ensure these paths are correct relative to your app_router.dart
import '../screens/business_detail_screen.dart';
import '../screens/business_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/main_scaffold.dart'; // Assuming you have a MainScaffold widget


// Define route name constants for better maintainability
class AppRoutes {
  static const String splash = '/splash';
  static const String landing = '/landing';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/'; // Home screen
  static const String businessDetail = 'business/:id'; // Relative path for nested route
  static const String map = '/map';
  static const String businesses = '/businesses';
  static const String profile = '/profile';
}


// Private navigators for the root and shell (MainScaffold)
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider); // This is now AsyncValue<User?>

  // Determine isAuthenticated based on the AsyncValue state.
  // A user is considered authenticated if the AsyncValue has data and the User object is not null.
  // During loading or error states, we'll treat them as not authenticated for redirection logic.
  final isAuthenticated = authState.when(
    data: (user) => user != null, // If 'user' is not null, they are authenticated
    loading: () => false,         // While loading, consider them not authenticated for redirect purposes
    error: (err, stack) => false, // On error, consider them not authenticated for redirect purposes
  );


  // Public routes that don't require authentication
  final publicRoutes = {
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.welcome,
    AppRoutes.landing,
    AppRoutes.splash,
    AppRoutes.home, // <<< CHANGED: Home screen is now considered a public route
  };

  return GoRouter(
    initialLocation: AppRoutes.splash, // Start at the splash screen
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Splash Screen - Always accessible
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // Public Routes - Accessible without authentication
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

      // Authenticated Routes - Protected by the redirect logic
      // These routes use a ShellRoute for a persistent UI (e.g., bottom navigation bar)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // Your MainScaffold should be here to provide the common UI wrapper
          // If you don't have a MainScaffold, you might need to create one,
          // or just return the child directly if no persistent UI is needed for now.
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
            routes: [
              // Nested route for business details relative to the home route
              GoRoute(
                path: AppRoutes.businessDetail, // path: 'business/:id'
                parentNavigatorKey: _rootNavigatorKey, // Use root navigator for full-screen overlay
                builder: (context, state) {
                  final String id = state.pathParameters['id']!;
                  return BusinessDetailScreen(businessId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const Center(child: Text('Map Screen')), // Placeholder
          ),
          GoRoute(
            path: AppRoutes.businesses,
            builder: (context, state) => const BusinessListScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;

      // If the app is still showing the splash screen, don't redirect yet
      if (location == AppRoutes.splash) return null;

      if (isAuthenticated) {
        // If the user is authenticated and they are not currently on the home screen,
        // or if they are on any public route (like login/register after auth),
        // always redirect them to the home screen.
        if (location != AppRoutes.home) {
          return AppRoutes.home;
        }
        return null; // User is authenticated and already on the home screen, allow.
      } else {
        // If the user is NOT authenticated,
        // 1. If they are trying to access a public route (including home), allow it.
        // 2. If they are trying to access a private route, redirect them to the landing screen.
        if (publicRoutes.contains(location)) {
          return null; // Allow unauthenticated users to access public routes (including Home)
        }
        return AppRoutes.landing; // Redirect unauthenticated users from any private route to landing
      }
    },
    debugLogDiagnostics: true, // Keep this for debugging router behavior
  );
});