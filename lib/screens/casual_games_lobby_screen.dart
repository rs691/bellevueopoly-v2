import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class CasualGamesLobbyScreen extends StatelessWidget {
  const CasualGamesLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arcade Games'),
        leading: canPop ? const BackButton() : null,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _GameTile(
            title: 'Available Rewards Nearby',
            icon: Icons.card_giftcard,
            color: Colors.purple,
            onTap: () => context.push(AppRoutes.nearMe),
          ),
          _GameTile(
            title: 'Mini Game 1',
            icon: Icons.games,
            onTap: () => context.push('/casual-games/game1'),
          ),
          _GameTile(
            title: 'Achievements',
            icon: Icons.emoji_events,
            onTap: () => context.push('/casual-games/achievements'),
          ),
          _GameTile(
            title: 'Settings',
            icon: Icons.settings,
            onTap: () => context.push('/casual-games/settings'),
          ),
          // Add more game tiles as needed
          _GameTile(
            title: 'Good Life Board',
            icon: Icons.dashboard,
            color: Colors.blue,
            onTap: () => context.push(AppRoutes.monopolyBoard),
          ),

          // Add more game tiles as needed
          _GameTile(
            title: 'Coming Soon',
            icon: Icons.lock,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This feature is coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _GameTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
