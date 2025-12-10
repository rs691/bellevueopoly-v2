import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:myapp/models/business.dart'; // Updated import to use the correct Business model
import '../providers/index.dart'; // Assuming businessesProvider is correctly defined here

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  gmf.GoogleMapController? _mapController;
  Set<gmf.Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  void _onMapCreated(gmf.GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers();
  }

  void _updateMarkers() {
    ref.read(businessesProvider).whenData((businesses) {
      setState(() {
        _markers = businesses
            .where((business) => business.location != null) // Only include businesses with location
            .map((business) => gmf.Marker(
          markerId: gmf.MarkerId(business.id),
          position: gmf.LatLng(business.location!.latitude, business.location!.longitude), // Null check added
          infoWindow: gmf.InfoWindow(title: business.name, onTap: () => context.go('/business/${business.id}')),
          onTap: () => context.go('/business/${business.id}'),
        ))
            .toSet();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessesProvider);
    final cityConfigAsync = ref.watch(cityConfigProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('BELLEVUEOPOLY'),
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
          final initialPosition = gmf.LatLng(cityConfig.mapCenterLat, cityConfig.mapCenterLng);
          return Stack(
            children: [
              gmf.GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: gmf.CameraPosition(target: initialPosition, zoom: cityConfig.zoomLevel),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
              Positioned(
                bottom: 96,
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (businesses) {
        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              // Filter businesses without location if they shouldn't appear in the sheet either
              if (business.location == null) return const SizedBox.shrink();
              return _BusinessCard(
                business: business,
                onTap: () => context.go('/business/${business.id}'),
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
      child: SizedBox(
        width: 250,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  business.category ?? 'Uncategorized', // Null check and default value
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
