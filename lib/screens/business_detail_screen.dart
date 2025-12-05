import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/index.dart';

class BusinessDetailScreen extends ConsumerWidget {
  final String businessId;

  const BusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  void _logVisit(BuildContext context, WidgetRef ref, String businessId) {
    // Record visit in game state
    ref.read(gameStateProvider.notifier).recordVisit(businessId);
    
    // Update player stats
    final currentPlayer = ref.read(playerProvider);
    if (currentPlayer != null) {
      ref.read(playerProvider.notifier).addVisit();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Visit logged! Check your profile to see progress.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessByIdProvider(businessId));
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      body: businessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Business not found'));
          }

          final property = gameState[businessId];
          final visitCount = property?.visitCount ?? 0;
          final loyaltyRequired = business.loyaltyTier.visitsRequired;
          final progressPercent = (visitCount / loyaltyRequired).clamp(0.0, 1.0);
          final isOwned = property?.isOwned ?? false;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: business.heroImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  business.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                Text(
                                  business.category,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              business.isOpen ? 'Open' : 'Closed',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                business.isOpen ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Ownership/Loyalty Status
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isOwned ? Colors.green[50] : Colors.blue[50],
                          border: Border.all(
                            color: isOwned ? Colors.green : Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isOwned ? '✓ Property Owned' : 'Loyalty Progress',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color:
                                            isOwned ? Colors.green : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  '$visitCount/$loyaltyRequired visits',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progressPercent,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isOwned
                                  ? business.loyaltyTier.rewardDescription
                                  : '${loyaltyRequired - visitCount} more visit${loyaltyRequired - visitCount != 1 ? 's' : ''} to own this property',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pitch
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            business.pitch,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Promotion banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          border: Border.all(color: Colors.amber),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.promotion.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(business.promotion.description),
                            const SizedBox(height: 8),
                            Text(
                              'Expires: ${business.promotion.expiresAt}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact info
                      Text(
                        'Contact',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(business.address),
                      Text(business.phoneNumber),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(business.description),
                      const SizedBox(height: 16),

                      // CTA button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _logVisit(context, ref, businessId),
                          child: const Text('Log Visit'),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
