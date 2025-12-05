import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/index.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: player == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Player avatar and name
                    _buildHeader(context, player),
                    const SizedBox(height: 24),
                    // Stats grid
                    _buildStatsGrid(player),
                    const SizedBox(height: 24),
                    // Owned properties
                    _buildOwnedProperties(context, ref),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, player) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.accentGreen,
          child: Text(
            player.name[0],
            style: const TextStyle(
              fontSize: 48,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          player.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        Text(
          'Level ${player.level} Explorer', 
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(player) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _StatCard(title: 'Visits', value: player.totalVisits.toString()),
        _StatCard(title: 'Properties', value: player.propertiesOwned.toString()),
        _StatCard(title: 'Trophies', value: player.trophies.length.toString()),
      ],
    );
  }

  Widget _buildOwnedProperties(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final businesses = ref.watch(businessesProvider);

    final ownedProperties = gameState.entries
        .where((entry) => entry.value.isOwned)
        .map((entry) => entry.key)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Owned Properties (${ownedProperties.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        businesses.when(
          data: (businessList) {
            final ownedBusinesses = businessList
                .where((b) => ownedProperties.contains(b.id))
                .toList();

            if (ownedBusinesses.isEmpty) {
              return const Text(
                'You haven\'t acquired any properties yet. Keep exploring!',
                style: TextStyle(color: Colors.white70),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ownedBusinesses.length,
              itemBuilder: (context, index) {
                final business = ownedBusinesses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.business, color: AppTheme.accentGreen),
                    title: Text(business.name),
                    subtitle: Text(business.category),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
