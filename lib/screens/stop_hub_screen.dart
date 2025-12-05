import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_background.dart';
import '../widgets/menu_card.dart';
import '../theme/app_theme.dart';

class StopHubScreen extends ConsumerWidget {
  const StopHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Monopoly man icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'CHAMBEROPOLY',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Title
                const Text(
                  'STOP HUB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StyledSearchBar(
                    hintText: 'search',
                    onFilterTap: () {
                      // Show filter options
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Menu cards grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      AnimatedMenuCard(
                        icon: Icons.store,
                        title: 'Boulevard',
                        subtitle: 'Partners',
                        onTap: () => context.go('/'),
                      ),
                      AnimatedMenuCard(
                        icon: Icons.flag,
                        title: 'Patriotic',
                        subtitle: 'Partners',
                        onTap: () => context.go('/'),
                      ),
                      AnimatedMenuCard(
                        icon: Icons.shopping_bag,
                        title: 'Merch',
                        subtitle: 'Partners',
                        onTap: () => context.go('/'),
                      ),
                      AnimatedMenuCard(
                        icon: Icons.volunteer_activism,
                        title: 'Giving',
                        subtitle: 'Partners',
                        onTap: () => context.go('/'),
                      ),
                      AnimatedMenuCard(
                        icon: Icons.people,
                        title: 'Community',
                        subtitle: 'Chest',
                        onTap: () => context.go('/'),
                      ),
                      AnimatedMenuCard(
                        icon: Icons.style,
                        title: 'Wild',
                        subtitle: 'Cards',
                        onTap: () => context.go('/'),
                      ),
                    ],
                  ),
                ),
                // Fun House card (wider)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: AnimatedMenuCard(
                    icon: Icons.celebration,
                    title: 'Fun',
                    subtitle: 'House',
                    onTap: () => context.go('/'),
                    width: double.infinity,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
