import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_bar.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _calculateCurrentIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') {
      return 0;
    } else if (location.startsWith('/stops')) {
      return 1;
    } else if (location.startsWith('/scan')) {
      return 2;
    } else if (location.startsWith('/prizes')) {
      return 3;
    } else if (location.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/stops');
        break;
      case 2:
        context.go('/scan');
        break;
      case 3:
        context.go('/prizes');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
