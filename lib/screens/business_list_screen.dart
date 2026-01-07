import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/business_provider.dart'; // Ensure this matches your provider file
import '../models/business_model.dart';
import '../widgets/async_image.dart';
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
        error: (err, stack) {
          debugPrint("❌ Business List Error: $err");
          debugPrint(stack.toString());
          return Center(child: Text('Error: $err'));
        },
        data: (businesses) {
          // Start the animation when data is loaded
          _controller.forward();

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // Breakpoints: <600 => 1 col, <1000 => 2 cols, else 3 cols
              final crossAxisCount = width < 600
                  ? 1
                  : (width < 1000 ? 2 : 3);

              // When 1 column, keep ListView for native list feel
              if (crossAxisCount == 1) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    final business = businesses[index];

                    final double start = (index * 0.08).clamp(0.0, 0.8);
                    final double end = (start + 0.35).clamp(0.0, 1.0);

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
                              begin: const Offset(0, 0.2),
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
                      child: _BusinessListCard(business: business, margin: const EdgeInsets.only(bottom: 16)),
                    );
                  },
                );
              }

              // Grid for 2+ columns
              // Adjust aspect ratio to keep row-like cards without overflow
              final tileWidth = (width - 16 * 2 - 16 * (crossAxisCount - 1)) / crossAxisCount;
              final tileHeight = 140.0; // Target height close to image size + padding
              final aspectRatio = tileWidth / tileHeight;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: aspectRatio.clamp(2.6, 5.0),
                ),
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  final business = businesses[index];

                  final double start = (index * 0.06).clamp(0.0, 0.8);
                  final double end = (start + 0.3).clamp(0.0, 1.0);

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
                            begin: const Offset(0, 0.1),
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
                    child: _BusinessListCard(business: business, margin: EdgeInsets.zero),
                  );
                },
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
  final EdgeInsetsGeometry? margin;

  const _BusinessListCard({required this.business, this.margin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the Rich Profile
        // Ensure your router handles this path: /map/business/:id or similar
        // Since this is the "Directory" tab, we might need a specific route
        // For now, assuming standard GoRouter path:
        context.push('/business/${business.id}');
      },
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive card layout: compact on narrow, roomy on wide
            final isCompact = constraints.maxWidth < 480;
            final imageSize = isCompact ? 72.0 : 100.0;
            final titleSize = isCompact ? 14.0 : 16.0;
            final padding = isCompact ? 10.0 : 12.0;

            return Row(
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: imageSize,
                height: imageSize,
                child: AsyncImage(
                  imageUrl: business.heroImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Text Info Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.category,
                      style: TextStyle(
                        color: AppTheme.accentOrange, // Use your theme color
                        fontSize: isCompact ? 11 : 12,
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
                padding: EdgeInsets.only(right: isCompact ? 8 : 12),
              child: Icon(Icons.chevron_right, color: Colors.grey[400]),
            ),
            ],
            );
          },
        ),
      ),
    );
  }
}

