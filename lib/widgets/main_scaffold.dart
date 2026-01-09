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
    final isHomeScreen = _calculateCurrentIndex(context) == 0 && GoRouterState.of(context).matchedLocation == '/';
    
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _startPosition = details.globalPosition;
      },
      onHorizontalDragEnd: (details) {
        _handleSwipe(context);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Global background image for post-login screens
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background3.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Dark vignette overlay to darken the edges
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            widget.child,
            // Floating navbar positioned at bottom - hidden on home screen
            if (!isHomeScreen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNavBar(
                  currentIndex: _calculateCurrentIndex(context),
                  onTap: (index) => _onItemTapped(index, context),
                ),
              ),
          ],
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
        newIndex = (currentIndex - 1).clamp(0, 3);
      } else {
        // Swiped left - go to next tab
        newIndex = (currentIndex + 1).clamp(0, 3);
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
      // Tab 2: PRIZES -> /prizes
    } else if (location.startsWith('/prizes') ||
        location.startsWith('/rules-and-prizes')) {
      return 2;
      // Tab 3: NEAR ME -> /near-me
    } else if (location.startsWith('/near-me')) {
      return 3;
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
        context.go(AppRoutes.prizes);
        break;
      case 3:
        context.go(AppRoutes.nearMe);
        break;
    }
  }
}
