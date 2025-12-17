import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/business_provider.dart';
import '../widgets/menu_card.dart';

class BusinessDetailScreen extends ConsumerStatefulWidget {
  final String businessId;

  const BusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends ConsumerState<BusinessDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessByIdProvider(widget.businessId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background dismiss
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          
          // Animated Modal Content
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: businessAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.white)),
                data: (business) {
                  if (business == null) return const Text('Not Found', style: TextStyle(color: Colors.white));

                  return GestureDetector(
                    onTap: () {}, // Prevent tap through
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header Image
                                SizedBox(
                                  height: 200,
                                  child: business.heroImageUrl != null
                                      ? CachedNetworkImage(
                                    imageUrl: business.heroImageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.store, size: 60, color: Colors.white54),
                                  ),
                                ),

                                // Content
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Name and Category
                                        Text(
                                          business.name,
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.orangeAccent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            (business.category).toUpperCase(),
                                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Firestore Fields
                                        _buildInfoRow(Icons.business, "ID (Name)", business.id),
                                        _buildInfoRow(Icons.person, "Name", business.name),
                                        _buildInfoRow(Icons.location_city, "City", "Bellevue"), // Assuming default or from address parsing
                                        _buildInfoRow(Icons.map, "State", "NE"), // Assuming default
                                        _buildInfoRow(Icons.location_on, "Street", business.address ?? "N/A"),
                                        _buildInfoRow(Icons.markunread_mailbox, "Zip", "68005"), // Assuming default
                                        _buildInfoRow(Icons.phone, "Phone", business.phoneNumber ?? "N/A"),
                                        _buildInfoRow(Icons.language, "Website", business.website ?? "N/A"),
                                        _buildInfoRow(Icons.location_on, "Latitude", business.latitude.toString()),
                                        _buildInfoRow(Icons.location_on, "Longitude", business.longitude.toString()),




                                        const SizedBox(height: 24),

                                        // Menu Card Widget
                                        if (business.menuUrl != null) ...[
                                          const Text(
                                            "Menu",
                                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 12),
                                          AnimatedMenuCard(
                                            icon: Icons.restaurant_menu,
                                            title: "View Our Menu",
                                            subtitle: "Check out our delicious offerings",
                                            onTap: () => _launchUrl(business.menuUrl!),
                                            width: double.infinity,
                                            height: 100,
                                          ),
                                          const SizedBox(height: 24),
                                        ],

                                        // Website Button
                                        if (business.website != null)
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: OutlinedButton.icon(
                                              icon: const Icon(Icons.language),
                                              label: const Text("Visit Website"),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                side: BorderSide(color: Colors.white.withOpacity(0.5)),
                                              ),
                                              onPressed: () => _launchUrl(business.website!),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Close Button
                            Positioned(
                              top: 16,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
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
