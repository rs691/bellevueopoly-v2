import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

import 'package:myapp/router/app_router.dart';
import 'package:myapp/providers/auth_provider.dart';

// Create a FakeUser.
// Since the router only checks (user != null), we don't need to implement functionality.
class FakeUser extends Fake implements User {
  @override
  String get uid => '123';

  @override
  String get email => 'test@test.com';
}

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
            // User is null (logged out)
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
      // Ensure this text matches your actual Landing Screen UI title/text
      // Note: If you use an icon or image on the landing page, find.byType(Icon) might be better
      expect(find.text('Landing Screen'), findsOneWidget);
    });

    testWidgets('Authenticated user sees Home/MobileLanding', (tester) async {
      // Use FakeUser instead of trying to instantiate User() directly
      final dummyUser = FakeUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // User is present (logged in)
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
      // Ensure this text matches your "Boulevard Partners" or "Welcome" screen
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
