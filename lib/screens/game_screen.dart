import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import '../providers/game_logic_provider.dart';
import '../providers/business_provider.dart';
import '../providers/config_provider.dart';
import '../providers/location_provider.dart';
import '../providers/business_check_in_provider.dart';
import '../models/business_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/property_card.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Set<gmf.Marker> _markers = {};
  bool _showDebugPanel = false;
  bool _isShowingPropertyCard = false;

  @override
  void initState() {
    super.initState();
    // Start the game loop when this screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameControllerProvider).startGameLoop(context);
    });
  }

  void _onMapCreated(gmf.GoogleMapController controller) {
    print('Map created successfully');
    // Map is ready, but we don't need to store the controller
    // The framework manages the lifecycle
  }

  @override
  void dispose() {
    super.dispose();
    print('Game screen disposed');
  }

  void _showPropertyCard(Business business) {
    if (_isShowingPropertyCard) {
      return; // Prevent showing multiple property cards
    }
    
    _isShowingPropertyCard = true;
    print('Showing property card for: ${business.name}');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final checkInsAsync = ref.watch(businessCheckInsProvider(business.id));

            return checkInsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => PropertyCard(
                business: business,
                currentCheckIns: 0,
                onDismiss: () => Navigator.pop(context),
              ),
              data: (checkIns) => PropertyCard(
                business: business,
                currentCheckIns: checkIns,
                onDismiss: () => Navigator.pop(context),
              ),
            );
          },
        );
      },
    ).then((_) {
      _isShowingPropertyCard = false;
      print('Property card dismissed');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch businesses to populate map markers
    final cityConfigAsync = ref.watch(cityConfigProvider);

    // Update markers when businesses are loaded
    ref.listen<AsyncValue<List<Business>>>(businessListProvider, (previous, next) {
      next.whenData((businesses) {
        setState(() {
          _markers = businesses
              .where((b) => b.latitude != 0.0 && b.longitude != 0.0)
              .map((business) => gmf.Marker(
                markerId: gmf.MarkerId(business.id),
                position: gmf.LatLng(business.latitude, business.longitude),
                icon: gmf.BitmapDescriptor.defaultMarkerWithHue(gmf.BitmapDescriptor.hueViolet),
                onTap: () => _showPropertyCard(business),
              ))
              .toSet();
        });
      });
    });

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Game Active'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(_showDebugPanel ? Icons.bug_report : Icons.bug_report_outlined),
              onPressed: () {
                setState(() {
                  _showDebugPanel = !_showDebugPanel;
                });
              },
              tooltip: 'Toggle Debug Panel',
            ),
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () => context.push('/mock-location'),
              tooltip: 'Mock Location',
            ),
            IconButton(
              icon: const Icon(Icons.leaderboard),
              onPressed: () => context.push('/leaderboard'),
            ),
          ],
        ),
        body: Column(
          children: [
            // Debug Panel
            if (_showDebugPanel) _buildDebugPanel(),
            
            // Map Section (Game Board)
            Expanded(
              flex: 2, // Takes up more space
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: cityConfigAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (cityConfig) {
                      // Use hardcoded defaults if config is missing lat/lng
                      const double defaultLat = 41.15;
                      const double defaultLng = -95.92;
                      const double defaultZoom = 13.0;
                      final initialPosition = gmf.LatLng(defaultLat, defaultLng);

                      return gmf.GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: gmf.CameraPosition(
                          target: initialPosition,
                          zoom: defaultZoom,
                        ),
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Info Card Section
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GlassmorphicCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.radar, size: 40, color: Colors.white70),
                        const SizedBox(height: 12),
                        Text(
                          'Location Tracking On',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Visit the marked locations (pins) on the map above to earn points! Get within 100ft to trigger a reward.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugPanel() {
    final locationAsync = ref.watch(userLocationProvider);
    final businessesAsync = ref.watch(businessListProvider);
    final mockLocation = ref.watch(mockLocationProvider);

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              const Text(
                'DEBUG PANEL',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (mockLocation != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'MOCK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(color: Colors.orange),
          locationAsync.when(
            loading: () => const Text(
              'Loading location...',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            error: (err, _) => Text(
              'Error: $err',
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
            data: (position) {
              if (position == null) {
                return const Text(
                  'No location available',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                );
              }

              // Calculate distances to all businesses
              final businesses = businessesAsync.value ?? [];
              final nearbyBusinesses = businesses
                  .where((b) => b.latitude != 0.0 && b.longitude != 0.0)
                  .map((b) {
                final distance = Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  b.latitude,
                  b.longitude,
                );
                return {'business': b, 'distance': distance};
              }).toList()
                ..sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lat: ${position.latitude.toStringAsFixed(6)}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  Text(
                    'Lng: ${position.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nearest Businesses:',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...nearbyBusinesses.take(3).map((item) {
                    final business = item['business'] as Business;
                    final distance = item['distance'] as double;
                    final inRange = distance <= 30.48; // 100 feet threshold
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Icon(
                            inRange ? Icons.check_circle : Icons.location_on,
                            color: inRange ? Colors.green : Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business.name,
                              style: TextStyle(
                                color: inRange ? Colors.green : Colors.white70,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${distance.toStringAsFixed(0)}m',
                            style: TextStyle(
                              color: inRange ? Colors.green : Colors.white70,
                              fontSize: 10,
                              fontWeight: inRange ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
