import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:geolocator/geolocator.dart';
import '../widgets/async_image.dart';
import '../widgets/async_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/business_model.dart';
import '../providers/business_provider.dart';
import '../services/location_service.dart';
import '../utils/distance_calculator.dart';

/// Screen that displays nearby businesses with rewards on a map
/// with a scrollable list below showing distances from user's location
class RewardsNearbyScreen extends ConsumerStatefulWidget {
  const RewardsNearbyScreen({super.key});

  @override
  ConsumerState<RewardsNearbyScreen> createState() =>
      _RewardsNearbyScreenState();
}

class _RewardsNearbyScreenState extends ConsumerState<RewardsNearbyScreen> {
  Position? _userPosition;
  Set<gmf.Marker> _markers = {};
  gmf.GoogleMapController? _mapController;
  bool _isLoadingLocation = true;
  String? _locationError;

  // Default to Bellevue, NE
  final gmf.LatLng _defaultLocation = const gmf.LatLng(41.15, -95.92);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      if (mounted && position != null) {
        setState(() {
          _userPosition = position;
          _isLoadingLocation = false;
        });
        _updateMapCamera();
      } else if (mounted) {
        setState(() {
          _locationError = 'Unable to get location';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString();
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _updateMapCamera() {
    if (_mapController != null && _userPosition != null) {
      _mapController!.animateCamera(
        gmf.CameraUpdate.newLatLngZoom(
          gmf.LatLng(_userPosition!.latitude, _userPosition!.longitude),
          14.0,
        ),
      );
    }
  }

  void _updateMarkers(List<Business> businesses) {
    final markers = <gmf.Marker>{};

    // Add user location marker if available
    if (_userPosition != null) {
      markers.add(
        gmf.Marker(
          markerId: const gmf.MarkerId('user_location'),
          position: gmf.LatLng(
            _userPosition!.latitude,
            _userPosition!.longitude,
          ),
          icon: gmf.BitmapDescriptor.defaultMarkerWithHue(
            gmf.BitmapDescriptor.hueAzure,
          ),
          infoWindow: const gmf.InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add business markers
    for (final business in businesses) {
      if (business.latitude != 0.0 && business.longitude != 0.0) {
        markers.add(
          gmf.Marker(
            markerId: gmf.MarkerId(business.id),
            position: gmf.LatLng(business.latitude, business.longitude),
            icon: gmf.BitmapDescriptor.defaultMarkerWithHue(
              gmf.BitmapDescriptor.hueRed,
            ),
            infoWindow: gmf.InfoWindow(
              title: business.name,
              onTap: () => context.push('/business/${business.id}'),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessListAsync = ref.watch(businessListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rewards Nearby'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getUserLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Section (Top Half)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                gmf.GoogleMap(
                  initialCameraPosition: gmf.CameraPosition(
                    target: _userPosition != null
                        ? gmf.LatLng(
                            _userPosition!.latitude,
                            _userPosition!.longitude,
                          )
                        : _defaultLocation,
                    zoom: 13.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                // Location status overlay
                if (_isLoadingLocation)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('Getting your location...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_locationError != null && !_isLoadingLocation)
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Card(
                      color: Colors.orange.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Location unavailable. Showing default area.',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Business List Section (Bottom Half)
          Expanded(
            child: businessListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading businesses: $err'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(businessListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (businesses) {
                // Update markers when business data loads
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateMarkers(businesses);
                });

                // Calculate distances and sort by proximity
                final businessesWithDistance = businesses
                    .where((b) => b.latitude != 0.0 && b.longitude != 0.0)
                    .map((business) {
                      double? distance;
                      if (_userPosition != null) {
                        distance = DistanceCalculator.calculateDistance(
                          _userPosition!.latitude,
                          _userPosition!.longitude,
                          business.latitude,
                          business.longitude,
                        );
                      }
                      return _BusinessWithDistance(business, distance);
                    })
                    .toList();

                // Sort by distance if available
                if (_userPosition != null) {
                  businessesWithDistance.sort((a, b) {
                    if (a.distance == null) return 1;
                    if (b.distance == null) return -1;
                    return a.distance!.compareTo(b.distance!);
                  });
                }

                if (businessesWithDistance.isEmpty) {
                  return const Center(
                    child: Text('No businesses found with rewards'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: businessesWithDistance.length,
                  itemBuilder: (context, index) {
                    final item = businessesWithDistance[index];
                    return _BusinessDistanceCard(
                      business: item.business,
                      distance: item.distance,
                      userPosition: _userPosition,
                      onTap: () {
                        // Animate map to business location
                        if (_mapController != null) {
                          _mapController!.animateCamera(
                            gmf.CameraUpdate.newLatLngZoom(
                              gmf.LatLng(
                                item.business.latitude,
                                item.business.longitude,
                              ),
                              15.0,
                            ),
                          );
                        }
                        // Navigate to detail screen (modal overlay under Stop Hub)
                        context.push('/business/${item.business.id}');
                      },
                      context: context,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

/// Helper class to pair a business with its calculated distance
class _BusinessWithDistance {
  final Business business;
  final double? distance;

  _BusinessWithDistance(this.business, this.distance);
}

/// Card widget that displays business information with distance
class _BusinessDistanceCard extends StatelessWidget {
  final Business business;
  final double? distance;
  final Position? userPosition;
  final VoidCallback onTap;
  final BuildContext context;

  const _BusinessDistanceCard({
    required this.business,
    required this.distance,
    required this.userPosition,
    required this.onTap,
    required this.context,
  });

  String _formatDistance(double? distanceInKm) {
    if (distanceInKm == null) return 'Distance unknown';
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m away';
    }
    return '${distanceInKm.toStringAsFixed(1)} km away';
  }

  Future<void> _openDirections() async {
    if (userPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location not available')));
      return;
    }

    final url =
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${userPosition!.latitude},${userPosition!.longitude}'
        '&destination=${business.latitude},${business.longitude}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open directions')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening directions: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AsyncImage(
                  imageUrl: business.heroImageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholderAsset: 'assets/images/restaurant_placeholder.png',
                ),
              ),
              const SizedBox(width: 12),

              // Business Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          business.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (business.address != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business.address!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Distance Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: distance != null && distance! < 1
                            ? Colors.green.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.navigation,
                            size: 14,
                            color: distance != null && distance! < 1
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDistance(distance),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: distance != null && distance! < 1
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Directions Button
                    IconButton(
                      icon: const Icon(Icons.directions),
                      iconSize: 18,
                      onPressed: _openDirections,
                      tooltip: 'Get Directions',
                      color: Colors.blue.shade700,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: Icon(Icons.store, size: 40, color: Colors.grey[500]),
    );
  }
}
