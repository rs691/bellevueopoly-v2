import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: 'STOPS'),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports),
          label: 'GAMES',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'PRIZES',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          label: 'NEAR ME',
        ),
      ],
    );
  }
}
