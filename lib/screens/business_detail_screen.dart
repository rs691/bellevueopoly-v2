import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Added import for the correct Business model
import '../providers/index.dart'; // Assuming businessByIdProvider is here
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

            return CustomScrollView(
              slivers: [
                // 1. High-Quality Hero Image (Property Card Header)
                SliverAppBar(
                  expandedHeight: 300, // Increased height for better visual impact
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white, shadows: [
                    BoxShadow(blurRadius: 10, color: Colors.black)
                  ]),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.all(16.0),
                    centerTitle: false,
                    title: Text(
                      business.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        shadows: [BoxShadow(blurRadius: 10, color: Colors.black87)],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        business.heroImageUrl != null &&
                            business.heroImageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: business.heroImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey),
                        )
                            : Image.asset(
                          'assets/images/no_image_available.png', // Fallback image
                          fit: BoxFit.cover,
                        ),
                        // Gradient Overlay for text readability
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black54,
                              ],
                              stops: [0.6, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            business.category ?? 'General Business',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. "The Pitch": A short, catchy description
                        if (business.pitch != null &&
                            business.pitch!.isNotEmpty) ...[
                          Text(
                            "The Pitch",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                color: AppTheme.accentOrange,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"${business.pitch!}"',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                height: 1.3),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 3. Active Promotions (The real value driver)
                        // Using current data if available, or placeholder if not
                        _buildSectionCard(
                          context,
                          title: "Active Promotion",
                          icon: Icons.local_offer,
                          color: AppTheme.accentOrange,
                          content: business.promotion != null
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                business.promotion!.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                business.promotion!.description,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.9)),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement "Redeem" logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text("Show to Redeem"),
                                ),
                              )
                            ],
                          )
                              : const Text(
                            "No active promotions at this time. Check back later!",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 4. Loyalty Integration: "Check in to own!"
                        // Placeholder for future gamification logic
                        _buildSectionCard(
                          context,
                          title: "Property Mastery",
                          icon: Icons.emoji_events,
                          color: Colors.purpleAccent,
                          content: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Ownership Progress",
                                      style: TextStyle(color: Colors.white)),
                                  Text("2 / 5 Check-ins", // Placeholder data
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: 0.4, // Placeholder: 2/5 = 0.4
                                backgroundColor: Colors.black26,
                                color: Colors.purpleAccent,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Check in 3 more times to 'Own' this property and earn passive rewards!",
                                style:
                                TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 5. Contact / Info Section
                        _buildSectionCard(
                          context,
                          title: "Info",
                          icon: Icons.info_outline,
                          color: Colors.blueAccent,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.location_on,
                                  business.address ?? "Address not available"),
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.phone,
                                  business.phoneNumber ?? "Phone not available"),
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.web,
                                  business.website ?? "Website not available"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
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

  Widget _buildSectionCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white60),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
