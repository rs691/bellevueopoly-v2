import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/widgets/navigation_box.dart';

class MobileLandingScreen extends StatelessWidget {
  const MobileLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            NavigationBox(
              icon: Icons.star,
              label: 'Stop Hub',
              onTap: () => context.go('/stop_hub'),
            ),
            NavigationBox(
              icon: Icons.people,
              label: 'Near Me',
              onTap: () => context.go('/near_me'),
            ),
            NavigationBox(
              icon: Icons.emoji_events,
              label: 'Prizes',
              onTap: () => context.go('/prizes'),
            ),
            NavigationBox(
              icon: Icons.help_outline,
              label: 'FAQ',
              onTap: () => context.go('/faq'),
            ),
            NavigationBox(
              icon: Icons.person,
              label: 'My Account',
              onTap: () => context.go('/my_account'),
            ),
          ],
        ),
      ),
    );
  }
}
