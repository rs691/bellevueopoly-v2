import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/router/app_router.dart';
import 'package:myapp/providers/auth_provider.dart';

// Simple mock for Auth State
class MockAuthNotifier extends AsyncNotifier<User?> {
  final User? initialUser;
  MockAuthNotifier(this.initialUser);

  @override
  Future<User?> build() async => initialUser;
}

void main() {
  group('Router Navigation Tests', () {
    testWidgets('Unauthenticated user starts at Landing Page', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Force auth state to null (logged out)
            authStateProvider.overrideWith(() => MockAuthNotifier(null)),
          ],
          child: Builder(
            builder: (context) {
              final router = context.watch(appRouterProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      // Verify redirection logic sends us to Landing
      // Note: You might need to update findsOneWidget depending on your Splash screen duration
      // or if your router redirects immediately.
      await tester.pumpAndSettle();
      expect(find.text('Landing Screen'), findsOneWidget); // Update text to match your actual Landing UI
    });

    testWidgets('Authenticated user sees Home/MobileLanding', (tester) async {
      // Create a dummy user object (adjust based on your actual User model)
      final dummyUser = User(uid: '123', email: 'test@test.com');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(() => MockAuthNotifier(dummyUser)),
          ],
          child: Builder(
            builder: (context) {
              final router = context.read(appRouterProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find the MobileLandingScreen content (e.g. "Boulevard Partners" or "Welcome")
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
