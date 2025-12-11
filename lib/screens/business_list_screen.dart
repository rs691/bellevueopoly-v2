import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/business_provider.dart'; // Ensure this matches your provider file
import '../models/business_model.dart';
import '../theme/app_theme.dart';

class BusinessListScreen extends ConsumerStatefulWidget {
  const BusinessListScreen({super.key});

  @override
  ConsumerState<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends ConsumerState<BusinessListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Total animation time
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider
    final businessListAsync = ref.watch(businessListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boulevard Partners'),
        centerTitle: true,
      ),
      body: businessListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (businesses) {
          // Start the animation when data is loaded
          _controller.forward();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];

              // Calculate animation interval for staggered effect
              // Each item starts slightly later than the previous one
              final double start = (index * 0.1).clamp(0.0, 0.8);
              final double end = (start + 0.4).clamp(0.0, 1.0);

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Interval(start, end, curve: Curves.easeOut),
                      ),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2), // Start slightly down
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(start, end, curve: Curves.easeOutQuad),
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: _BusinessListCard(business: business),
              );
            },
          );
        },
      ),
    );
  }
}

class _BusinessListCard extends StatelessWidget {
  final Business business;

  const _BusinessListCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the Rich Profile
        // Ensure your router handles this path: /map/business/:id or similar
        // Since this is the "Directory" tab, we might need a specific route
        // For now, assuming standard GoRouter path:
        context.push('/map/business/${business.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: business.heroImageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: business.heroImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.store, color: Colors.grey),
                ),
              ),
            ),

            // Text Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.category ?? 'Business',
                      style: TextStyle(
                        color: AppTheme.accentOrange, // Use your theme color
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.address ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Arrow Icon
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
