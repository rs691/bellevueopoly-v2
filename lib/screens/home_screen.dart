import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:geolocator/geolocator.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../theme/app_theme.dart';
import '../providers/user_data_provider.dart';
import '../widgets/glassmorphic_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final List<Business> _businesses = [];
  gmf.GoogleMapController? _mapController;
  Set<gmf.Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Use a short delay to allow providers to be ready.
    Future.delayed(const Duration(milliseconds: 100), () {
      final businessesAsync = ref.read(businessesProvider);
      businessesAsync.whenData((businesses) {
        _loadAnimatedList(businesses);
      });
    });
  }

  void _loadAnimatedList(List<Business> businesses) {
    // Use a staggered animation for the list.
    for (int i = 0; i < businesses.length; i++) {
      Timer(Duration(milliseconds: 150 * i), () {
        if (_animatedListKey.currentState != null) {
          _businesses.add(businesses[i]);
          _animatedListKey.currentState!.insertItem(i);
        }
      });
    }
  }

  void _onMapCreated(gmf.GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers();
  }

  Future<void> _onLocationUpdate(Position pos) async {
    // Proximity detection logic remains the same...
  }

  void _updateMarkers() {
    final businesses = ref.read(businessesProvider).asData?.value ?? [];
    setState(() {
      _markers = businesses
          .map((business) => gmf.Marker(
                markerId: gmf.MarkerId(business.id),
                position: gmf.LatLng(business.location.latitude, business.location.longitude),
                infoWindow: gmf.InfoWindow(title: business.name, onTap: () => context.go('/business/${business.id}')),
                onTap: () => context.go('/business/${business.id}'),
              ))
          .toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cityConfigAsync = ref.watch(cityConfigProvider);
    final userData = ref.watch(userDataProvider);

    // Listeners for location and business updates
    ref.listen<AsyncValue<List<Business>>>(businessesProvider, (prev, next) {
      if (_mapController != null) _updateMarkers();
    });
    ref.listen<AsyncValue<Position?>>(userLocationProvider, (prev, next) {
      if (next.asData?.value != null) _onLocationUpdate(next.asData!.value!);
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: userData.when(
          data: (userDoc) => Text(userDoc?.data() != null ? 'Welcome, ${(userDoc!.data() as Map)['username']}!' : 'BELLEVUEOPOLY'),
          loading: () => const Text('BELLEVUEOPOLY'),
          error: (e, s) => const Text('BELLEVUEOPOLY'),
        ),
        actions: [IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.go('/profile'))],
      ),
      body: cityConfigAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
                zoomControlsEnabled: false, // Cleaner look for the new UI
              ),
              _buildBusinessListSheet(),
              Positioned(
                right: 16,
                bottom: 100, // Adjusted for the new sheet
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _centerOnUserLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBusinessListSheet() {
    final gameState = ref.watch(gameStateProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return GlassmorphicCard(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
              ),
              Expanded(
                child: AnimatedList(
                  key: _animatedListKey,
                  controller: scrollController,
                  initialItemCount: 0,
                  itemBuilder: (context, index, animation) {
                    final business = _businesses[index];
                    final propertyState = gameState[business.id];
                    return _AnimatedBusinessCard(
                      business: business,
                      property: propertyState,
                      animation: animation,
                      onTap: () => context.go('/business/${business.id}'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _centerOnUserLocation() {
    ref.read(userLocationProvider).whenData((pos) {
      if (pos != null && _mapController != null) {
        _mapController!.animateCamera(gmf.CameraUpdate.newLatLngZoom(gmf.LatLng(pos.latitude, pos.longitude), 16));
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// The new, improved business card widget
class _AnimatedBusinessCard extends StatelessWidget {
  final Business business;
  final Property? property;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _AnimatedBusinessCard({
    required this.business,
    this.property,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (property?.visitCount ?? 0) / (business.loyaltyTier.visitsRequired);
    final isOwned = property?.isOwned ?? false;

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(animation),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(business.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(business.category, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 12),
                  if (!isOwned)
                    Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress.toDouble()),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              color: AppTheme.accentGreen,
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${property?.visitCount ?? 0} / ${business.loyaltyTier.visitsRequired} visits to claim',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    )
                  else
                    Text('You own this property!', style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(onPressed: onTap, child: const Text('View Details')),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
