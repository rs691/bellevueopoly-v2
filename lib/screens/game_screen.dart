import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import '../providers/game_logic_provider.dart';
import '../providers/business_provider.dart';
import '../providers/config_provider.dart';
import '../models/business_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glassmorphic_card.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  gmf.GoogleMapController? _mapController;
  Set<gmf.Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Start the game loop when this screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameControllerProvider).startGameLoop(context);
    });
  }

  void _onMapCreated(gmf.GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    // Watch businesses to populate map markers
    final businessesAsync = ref.watch(businessListProvider);
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
            infoWindow: gmf.InfoWindow(
              title: business.name,
              snippet: 'Visit to earn points!',
            ),
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
              icon: const Icon(Icons.leaderboard),
              onPressed: () => context.push('/leaderboard'),
            ),
          ],
        ),
        body: Column(
          children: [
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
}
