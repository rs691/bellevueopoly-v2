import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/index.dart';
import '../widgets/main_scaffold.dart';

// Navigator keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/landing',
  routes: [
    // App shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/stops',
          builder: (context, state) => const BusinessListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        // Placeholder routes for the other nav items
        GoRoute(
          path: '/scan',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Scan'))),
        ),
        GoRoute(
          path: '/prizes',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Prizes'))),
        ),
      ],
    ),
    // Top-level routes that don't need the main scaffold
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/welcome-back',
      builder: (context, state) => const WelcomeBackScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey, // So it covers the scaffold
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/business/:id',
      parentNavigatorKey: _rootNavigatorKey, // So it covers the scaffold
      builder: (context, state) =>
          BusinessDetailScreen(businessId: state.pathParameters['id']!),
    ),
  ],
);
