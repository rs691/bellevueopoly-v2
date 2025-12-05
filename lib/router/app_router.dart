import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/index.dart';
import '../widgets/main_scaffold.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';

// Navigator keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeBackScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    // App shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'business/:id',
                builder: (context, state) {
                  final businessId = state.pathParameters['id']!;
                  return BusinessDetailScreen(businessId: businessId);
                },
              ),
            ]),
        GoRoute(
          path: '/map',
          builder: (context, state) => const Center(child: Text('Map Screen')),
        ),
        GoRoute(
          path: '/businesses',
          builder: (context, state) => const BusinessListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
