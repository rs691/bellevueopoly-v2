import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import '../models/business_model.dart';
import '../providers/config_provider.dart'; // FIX: Use correct provider import

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Set<gmf.Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // No need to call _updateMarkers here manually if we watch the provider below,
    // but usually good to sync once data is loaded.
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the providers
    final businessesAsync = ref.watch(businessesProvider);
    final cityConfigAsync = ref.watch(cityConfigProvider);

    // 2. Handle Marker Logic when data arrives
    ref.listen<AsyncValue<List<Business>>>(businessesProvider, (previous, next) {
      next.whenData((businesses) {
        setState(() {
          _markers = businesses
          // FIX: The new model uses latitude/longitude directly, not business.location
              .where((b) => b.latitude != 0.0 && b.longitude != 0.0)
              .map((business) => gmf.Marker(
            markerId: gmf.MarkerId(business.id),
            // FIX: Direct access to fields
            position: gmf.LatLng(business.latitude, business.longitude),
            infoWindow: gmf.InfoWindow(
              title: business.name,
              onTap: () => context.push('/business/${business.id}'),
            ),
            onTap: () => context.push('/business/${business.id}'),
          ))
              .toSet();
        });
      });
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent, // Allows map to show behind
      appBar: AppBar(
        title: const Text('BELLEVUEOPOLY'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: cityConfigAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading city: $err')),
        data: (cityConfig) {
          // FIX: Your new CityConfig model doesn't have lat/lng/zoom.
          // We will use hardcoded defaults for Bellevue, NE for now.
          const double defaultLat = 41.15;
          const double defaultLng = -95.92;
          const double defaultZoom = 13.0;

          final initialPosition = gmf.LatLng(defaultLat, defaultLng);

          return Stack(
            children: [
              gmf.GoogleMap(
                initialCameraPosition: gmf.CameraPosition(
                  target: initialPosition,
                  zoom: defaultZoom,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                padding: const EdgeInsets.only(bottom: 150), // Make space for the sheet
              ),
              Positioned(
                bottom: 96, // Adjust based on your bottom nav bar height
                left: 0,
                right: 0,
                child: _buildBusinessListSheet(businessesAsync),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBusinessListSheet(AsyncValue<List<Business>> businessesAsync) {
    return businessesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (businesses) {
        return SizedBox(
          height: 160, // Slightly taller for better touch targets
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              // FIX: Direct field access check
              if (business.latitude == 0.0 && business.longitude == 0.0) {
                return const SizedBox.shrink();
              }
              return _BusinessCard(
                business: business,
                onTap: () => context.push('/business/${business.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback onTap;

  const _BusinessCard({required this.business, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  business.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  business.category, // Now non-nullable in your new model
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  business.address ?? "No Address",
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
