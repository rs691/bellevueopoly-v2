import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/index.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_theme.dart';

class BusinessDetailScreen extends ConsumerWidget {
  final String businessId;

  const BusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch business details from the local JSON data provider.
    final businessAsync = ref.watch(businessByIdProvider(businessId));

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: businessAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (business) {
            if (business == null) {
              return const Center(child: Text('Business not found'));
            }

            // A simple, stable UI that only uses data from the local Business object.
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(business.name, style: const TextStyle(shadows: [BoxShadow(blurRadius: 8, color: Colors.black54)])) ,
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
                        Text(
                          business.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          business.category,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                        // Pitch
                        Text(
                          '"${business.pitch}"',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.9)),
                        ),
                        const SizedBox(height: 24),
                        // Promotion
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.1),
                            border: Border.all(color: AppTheme.accentOrange),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                business.promotion.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(business.promotion.description, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
