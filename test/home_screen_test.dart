import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App starts and shows the HomeScreen with a map', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: BellevueopolyApp()));

    // Since routing is asynchronous, we might need to pump and settle.
    await tester.pumpAndSettle();

    // Verify that the HomeScreen is now visible.
    expect(find.byType(HomeScreen), findsOneWidget);
    // Verify that the GoogleMap widget within the HomeScreen is visible.
    expect(find.byType(GoogleMap), findsOneWidget);
  });

  testWidgets('HomeScreen UI Verification', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: BellevueopolyApp()));
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('BELLEVUEOPOLY'), findsOneWidget);

    // Verify profile icon in AppBar
    expect(find.byIcon(Icons.person_outline), findsOneWidget);

    // Verify Floating Action Button for location
    expect(find.byIcon(Icons.my_location), findsOneWidget);

    // Verify BottomNavBar
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify Business List Sheet (partially)
    // A more thorough test would require mocking the providers to show businesses
    expect(find.textContaining('Nearby Businesses'), findsOneWidget);
  });
}
