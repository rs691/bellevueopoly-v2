import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_bar.dart';
import '../router/app_router.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late Offset _startPosition;
  static const double _swipeThreshold = 50.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _startPosition = details.globalPosition;
      },
      onHorizontalDragEnd: (details) {
        _handleSwipe(context);
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavBar(
          currentIndex: _calculateCurrentIndex(context),
          onTap: (index) => _onItemTapped(index, context),
        ),
      ),
    );
  }

  void _handleSwipe(BuildContext context) {
    final currentIndex = _calculateCurrentIndex(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final endPosition = Offset(screenWidth / 2, 0);

    // Check if swipe distance exceeds threshold
    final dx = endPosition.dx - _startPosition.dx;

    if (dx.abs() > _swipeThreshold) {
      int newIndex = currentIndex;

      if (dx > 0) {
        // Swiped right - go to previous tab
        newIndex = (currentIndex - 1).clamp(0, 4);
      } else {
        // Swiped left - go to next tab
        newIndex = (currentIndex + 1).clamp(0, 4);
      }

      if (newIndex != currentIndex) {
        _onItemTapped(newIndex, context);
      }
    }
  }

  int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    // Tab 0: HOME -> /
    if (location == '/') {
      return 0;
      // Tab 1: STOPS -> /stop-hub
    } else if (location.startsWith('/stop-hub')) {
      return 1;
      // Tab 2: GAMES -> /game-hub (QR Scanner, Monopoly, Casual Games, Leaderboard)
    } else if (location.startsWith('/game-hub') ||
        location.startsWith('/monopolyBoard') ||
        location.startsWith('/casual-games') ||
        location.startsWith('/leaderboard')) {
      return 2;
      // Tab 3: PRIZES -> /prizes
    } else if (location.startsWith('/prizes') ||
        location.startsWith('/rules-and-prizes')) {
      return 3;
      // Tab 4: NEAR ME -> /near-me
    } else if (location.startsWith('/near-me')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.stopHub);
        break;
      case 2:
        context.go(AppRoutes.gameHub); // GAMES tab
        break;
      case 3:
        context.go(AppRoutes.prizes);
        break;
      case 4:
        context.go(AppRoutes.nearMe);
        break;
    }
  }
}
