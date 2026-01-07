import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import 'qr_scanner_overlay.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Hub'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 8),
          _GameCard(
            icon: Icons.qr_code_scanner,
            title: 'QR Scanner',
            description: 'Scan QR codes to check in and earn points',
            color: Colors.red.shade500,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    QRScannerOverlay(onClose: () => Navigator.pop(context)),
              );
            },
          ),
          const SizedBox(height: 16),
          _GameCard(
            icon: Icons.games,
            title: 'Monopoly Board',
            description: 'Play and collect properties across Bellevue',
            color: Colors.blue.shade500,
            onTap: () => context.go(AppRoutes.monopolyBoard),
          ),
          const SizedBox(height: 16),
          _GameCard(
            icon: Icons.gamepad,
            title: 'Casual Games',
            description: 'Quick games to earn bonus points',
            color: Colors.green.shade500,
            onTap: () => context.go(AppRoutes.casualGames),
          ),
          const SizedBox(height: 16),
          _GameCard(
            icon: Icons.leaderboard,
            title: 'Leaderboard',
            description: 'See where you rank among players',
            color: Colors.purple.shade500,
            onTap: () => context.go(AppRoutes.leaderboard),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(icon, size: 48, color: Colors.white),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
