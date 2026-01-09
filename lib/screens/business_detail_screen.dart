import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../providers/config_provider.dart';
import '../widgets/async_image.dart';

class BusinessDetailScreen extends ConsumerWidget {
  final String businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessByIdProvider(businessId));

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.pop(),
        child: Center(
          child: businessAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text(
              'Error: $err',
              style: const TextStyle(color: Colors.white),
            ),
            data: (business) {
              if (business == null) {
                return const Text(
                  'Not Found',
                  style: TextStyle(color: Colors.white),
                );
              }

              return GestureDetector(
                onTap: () {},
                child: Hero(
                  tag: 'business_card_${business.id}',
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.85,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          CustomScrollView(
                            slivers: [
                              // 1. Hero Image Header
                              SliverAppBar(
                                automaticallyImplyLeading: false,
                                expandedHeight: 250,
                                backgroundColor: Colors.transparent,
                                flexibleSpace: FlexibleSpaceBar(
                                  background: AsyncImage(
                                    imageUrl: business.heroImageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // 2. Body Content
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title and Category
                                      Text(
                                        business.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          business.category
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Action Buttons
                                      if (business.menuUrl != null ||
                                          business.website != null)
                                        Row(
                                          children: [
                                            if (business.menuUrl != null)
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                    Icons.restaurant_menu,
                                                  ),
                                                  label: const Text(
                                                    "View Menu",
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                        foregroundColor:
                                                            Colors.black,
                                                      ),
                                                  onPressed: () => _launchUrl(
                                                    business.menuUrl!,
                                                  ),
                                                ),
                                              ),
                                            if (business.menuUrl != null &&
                                                business.website != null)
                                              const SizedBox(width: 10),
                                            if (business.website != null)
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  icon: const Icon(
                                                    Icons.language,
                                                  ),
                                                  label: const Text("Website"),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                  onPressed: () => _launchUrl(
                                                    business.website!,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),

                                      const SizedBox(height: 24),

                                      // Hours
                                      if (business.hours != null) ...[
                                        _buildSectionTitle(
                                          context,
                                          "Hours of Operation",
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 
                                              0.05,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            children: business.hours!.entries.map((
                                              entry,
                                            ) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      entry.key,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                    Text(
                                                      entry.value,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                      ],

                                      // Location
                                      _buildSectionTitle(context, "Location"),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.white54,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              business.address ??
                                                  "Address not available",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // KEY CHANGE 3: Removed the Positioned Close Button from here.
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 14,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

