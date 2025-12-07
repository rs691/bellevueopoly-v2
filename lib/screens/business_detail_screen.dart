import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/index.dart';
import '../models/index.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_theme.dart';

class BusinessDetailScreen extends ConsumerWidget {
  final String businessId;

  const BusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  // --- Actions ---
  void _logVisit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Visit Logged!'),
        backgroundColor: AppTheme.accentGreen,
        duration: Duration(seconds: 2),
      ),
    );
    // Here you would add the logic to update the user's visit count.
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Optionally, show a snackbar or dialog on error
    }
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessByIdProvider(businessId));

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _logVisit(context),
          label: const Text('Log Visit'),
          icon: const Icon(Icons.check_circle_outline),
          backgroundColor: AppTheme.accentGreen,
        ),
        body: businessAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (business) {
            if (business == null) {
              return const Center(child: Text('Business not found'));
            }
            return _buildBusinessDetails(context, business);
          },
        ),
      ),
    );
  }

  Widget _buildBusinessDetails(BuildContext context, Business business) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(business),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, business),
                const SizedBox(height: 24),
                _buildPitch(context, business),
                const SizedBox(height: 24),
                _buildPromotion(context, business),
                const SizedBox(height: 24),
                _buildDescription(context, business),
                const SizedBox(height: 24),
                _buildContactInfo(context, business),
                const SizedBox(height: 24),
                _buildBusinessHours(context, business),
                const SizedBox(height: 100), // To make space for the FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(Business business) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(business.name, style: const TextStyle(shadows: [BoxShadow(blurRadius: 8, color: Colors.black54)])) ,
        background: CachedNetworkImage(
          imageUrl: business.heroImageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Business business) {
    return Column(
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
      ],
    );
  }

  Widget _buildPitch(BuildContext context, Business business) {
    return Text(
      '"${business.pitch}"',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.9)),
    );
  }
  
  Widget _buildPromotion(BuildContext context, Business business) {
    return Container(
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
    );
  }
  
  Widget _buildDescription(BuildContext context, Business business) {
    return Card(
      color: AppTheme.navBarBackground.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(business.description, style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, Business business) {
    return Card(
      color: AppTheme.navBarBackground.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            _ContactTile(icon: Icons.location_on, text: business.address, onTap: () => _launchUrl('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(business.address)}')),
            const Divider(height: 24),
            _ContactTile(icon: Icons.phone, text: business.phoneNumber, onTap: () => _launchUrl('tel:${business.phoneNumber}')),
            const Divider(height: 24),
            _ContactTile(icon: Icons.public, text: business.website, onTap: () => _launchUrl(business.website)),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHours(BuildContext context, Business business) {
    return Card(
      color: AppTheme.navBarBackground.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hours', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            for (var entry in business.businessHours.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                    Text(entry.value, style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContactTile({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentGreen, size: 28),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16))),
          const Icon(Icons.launch, color: Colors.white70, size: 18),
        ],
      ),
    );
  }
}
