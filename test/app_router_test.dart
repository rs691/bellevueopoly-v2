import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED: Import for User type
import 'package:belle_opoly/router/app_router.dart'; // Ensure this matches your pubspec name
import 'package:belle_opoly/providers/auth_provider.dart';

// 1. DEFINE A FAKE USER
// Since we cannot instantiate 'User' directly, we make a fake one that looks like it.
class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String email;

  FakeUser({required this.uid, required this.email});
}

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

      await tester.pumpAndSettle();
      expect(find.text('Landing Screen'), findsOneWidget);
    });

    testWidgets('Authenticated user sees Home/MobileLanding', (tester) async {
      // 2. USE FAKE USER HERE
      // Instead of User(), we use our FakeUser wrapper.
      final dummyUser = FakeUser(uid: '123', email: 'test@test.com');

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

      // Should find the MobileLandingScreen content
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
