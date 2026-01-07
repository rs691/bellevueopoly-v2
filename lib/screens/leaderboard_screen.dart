import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firestore_provider.dart';
import '../models/player.dart';
import '../theme/app_spacing.dart';

final leaderboardProvider = StreamProvider<List<Player>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTopPlayersStream();
});

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshLeaderboard() async {
    // Invalidate the provider to refetch data
    ref.invalidate(leaderboardProvider);
    // Wait a moment for the refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Time'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All-time leaderboard
          _buildLeaderboardList(leaderboardAsync),
          // Weekly leaderboard
          _buildLeaderboardList(leaderboardAsync, timeframe: 'weekly'),
          // Monthly leaderboard
          _buildLeaderboardList(leaderboardAsync, timeframe: 'monthly'),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(
    AsyncValue<List<Player>> leaderboardAsync, {
    String timeframe = 'all',
  }) {
    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (players) {
        // Filter players based on timeframe
        final filteredPlayers = _filterPlayersByTimeframe(players, timeframe);

        if (filteredPlayers.isEmpty) {
          return const Center(child: Text('No players found yet!'));
        }

        return RefreshIndicator(
          onRefresh: _refreshLeaderboard,
          child: ListView.builder(
            itemCount: filteredPlayers.length,
            itemBuilder: (context, index) {
              final player = filteredPlayers[index];
              final rank = index + 1;

              // Highlight top 3
              Color? rankColor;
              if (rank == 1)
                rankColor = Colors.amber;
              else if (rank == 2)
                rankColor = Colors.grey[400];
              else if (rank == 3)
                rankColor = Colors.brown[300];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rankColor ?? Colors.blueAccent,
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${player.totalVisits} visits'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${player.totalPoints}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text('Points', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Player> _filterPlayersByTimeframe(
    List<Player> players,
    String timeframe,
  ) {
    // For now, return all players for each timeframe
    // In a real app, you'd filter based on points earned in that period
    // This would require tracking points by date in Firestore
    return players;
  }
}
