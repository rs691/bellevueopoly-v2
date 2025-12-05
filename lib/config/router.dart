import 'package:go_router/go_router.dart';
import '../screens/index.dart';

final router = GoRouter(
  initialLocation: '/landing',
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
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
