import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:geolocator/geolocator.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  gmf.GoogleMapController? _mapController;
  Set<gmf.Marker> _markers = {};
  final Map<String, DateTime> _lastAutoVisit = {};
  static const double _proximityThresholdMeters = 50.0;
  static const Duration _autoVisitCooldown = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(gmf.GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers();
  }

  Future<void> _onLocationUpdate(Position pos) async {
    // Auto-center the map on the user
    if (_mapController != null) {
      try {
        await _mapController!.animateCamera(
          gmf.CameraUpdate.newCameraPosition(
            gmf.CameraPosition(
              target: gmf.LatLng(pos.latitude, pos.longitude),
              zoom: 16,
            ),
          ),
        );
      } catch (_) {}
    }

    // Proximity detection: check nearby businesses
    final businesses = ref
        .read(businessesProvider)
        .maybeWhen(data: (list) => list, orElse: () => <Business>[]);

    final gameState = ref.read(gameStateProvider);
    final locationService = ref.read(locationServiceProvider);

    for (final business in businesses) {
      final property = gameState[business.id];
      // Skip if already owned
      if (property?.isOwned ?? false) continue;

      final distance = await locationService.calculateDistance(
        pos.latitude,
        pos.longitude,
        business.location.latitude,
        business.location.longitude,
      );

      if (distance <= _proximityThresholdMeters) {
        final last = _lastAutoVisit[business.id];
        final now = DateTime.now();
        if (last == null || now.difference(last) > _autoVisitCooldown) {
          // Record visit in game state and player
          ref.read(gameStateProvider.notifier).recordVisit(business.id);
          final currentPlayer = ref.read(playerProvider);
          if (currentPlayer != null) {
            ref.read(playerProvider.notifier).addVisit();
          }

          _lastAutoVisit[business.id] = now;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Auto-visit recorded for ${business.name}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    }
  }

  void _updateMarkers() {
    final businesses = ref
        .read(businessesProvider)
        .maybeWhen(data: (list) => list, orElse: () => <Business>[]);

    setState(() {
      _markers = businesses
          .map(
            (business) => gmf.Marker(
              markerId: gmf.MarkerId(business.id),
              position: gmf.LatLng(
                business.location.latitude,
                business.location.longitude,
              ),
              infoWindow: gmf.InfoWindow(
                title: business.name,
                snippet: business.category,
                onTap: () => context.go('/business/${business.id}'),
              ),
              onTap: () => context.go('/business/${business.id}'),
            ),
          )
          .toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessesProvider);
    final cityConfigAsync = ref.watch(cityConfigProvider);

    // Refresh markers when businesses list updates
    ref.listen<AsyncValue<List<Business>>>(businessesProvider, (prev, next) {
      // If map is ready, update markers
      if (_mapController != null) {
        _updateMarkers();
      }
    });
    // Listen to user location updates to auto-center map and detect proximity
    ref.listen<AsyncValue<Position?>>(userLocationProvider, (prev, next) {
      final pos = next.maybeWhen(data: (p) => p, orElse: () => null);
      if (pos != null) {
        _onLocationUpdate(pos);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Monopoly man icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentOrange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'BELLEVUEOPOLY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: cityConfigAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading city: $err'),
            ],
          ),
        ),
        data: (cityConfig) {
          final initialPosition = gmf.LatLng(
            cityConfig.mapCenterLat,
            cityConfig.mapCenterLng,
          );

          return Stack(
            children: [
              // Google Maps
              gmf.GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: gmf.CameraPosition(
                  target: initialPosition,
                  zoom: cityConfig.zoomLevel,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                scrollGesturesEnabled: true,
              ),
              // Bottom sheet with business list
              Positioned(
                bottom: 76,
                left: 0,
                right: 0,
                child: _buildBusinessListSheet(businessesAsync),
              ),
              // Custom location button
              Positioned(
                right: 16,
                bottom: 160,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () => _centerOnUserLocation(),
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBusinessListSheet(AsyncValue<List<Business>> businessesAsync) {
    return businessesAsync.when(
      loading: () => Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Container(
        height: 100,
        color: Colors.white,
        child: Center(child: Text('Error: $err')),
      ),
      data: (businesses) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.35,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Nearby Businesses (${businesses.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    itemCount: businesses.length,
                    itemBuilder: (context, index) {
                      final business = businesses[index];
                      return _BusinessCard(
                        business: business,
                        onTap: () => context.go('/business/${business.id}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _centerOnUserLocation() {
    final position = ref
        .read(userLocationProvider)
        .maybeWhen(data: (pos) => pos, orElse: () => null);

    if (position != null && _mapController != null) {
      _mapController!.animateCamera(
        gmf.CameraUpdate.newCameraPosition(
          gmf.CameraPosition(
            target: gmf.LatLng(position.latitude, position.longitude),
            zoom: 16,
          ),
        ),
      );
    } else if (position == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location not available')));
    } else {
      // Map controller not ready yet
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Map not ready')));
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.location_on, color: Colors.blue[700]),
              const SizedBox(height: 4),
              Text(
                business.name,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                business.category,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
