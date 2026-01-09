import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:geolocator/geolocator.dart';
import '../widgets/async_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business_model.dart';
import '../providers/business_provider.dart';
import '../services/location_service.dart';
import '../utils/distance_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/search_bar.dart' as custom_search;

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
  String _searchQuery = '';
  
  // Filter States
  String _selectedCategory = 'All';
  bool _onlyWithRewards = false;
  bool _onlyWithPoints = false;

  final List<String> _categories = [
    'All',
    'Boulevard Partners',
    'Patriotic Partners',
    'Merch Partners',
    'Giving Partners',
    'Community Chest',
    'Wild Cards',
    'Fun House',
  ];

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

  Future<void> _refreshBusinesses() async {
    // Refresh the business list provider and user location
    await Future.wait([_getUserLocation()]);
    // Invalidate the provider to refetch data
    ref.invalidate(businessListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final businessListAsync = ref.watch(businessListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Available Rewards Nearby'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
          // Map on top with rounded card styling
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
            ),
          ),

          // Animated business list below map
          Expanded(
            child: Column(
              children: [
                // Search bar and Filter Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: custom_search.SearchBar(
                          hintText: 'Search businesses...',
                          onChanged: (query) => setState(() => _searchQuery = query),
                          onClear: () => setState(() => _searchQuery = ''),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        decoration: BoxDecoration(
                          color: (_onlyWithRewards || _onlyWithPoints || _selectedCategory != 'All')
                              ? AppColors.primaryPurple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: (_onlyWithRewards || _onlyWithPoints || _selectedCategory != 'All')
                                ? Colors.white
                                : AppColors.darkGrey,
                          ),
                          onPressed: () => _showFilterSheet(context),
                          tooltip: 'Filters',
                        ),
                      ),
                    ],
                  ),
                ),

                // Active Filters Summary (Horizontal Scroll)
                if (_onlyWithRewards || _onlyWithPoints || _selectedCategory != 'All')
                   SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      children: [
                        if (_onlyWithRewards)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: const Text('Has Rewards', style: TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => setState(() => _onlyWithRewards = false),
                            ),
                          ),
                        if (_onlyWithPoints)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: const Text('Has Points', style: TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => setState(() => _onlyWithPoints = false),
                            ),
                          ),
                        if (_selectedCategory != 'All')
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(_selectedCategory, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => setState(() => _selectedCategory = 'All'),
                            ),
                          ),
                         Padding(
                           padding: const EdgeInsets.only(right: 8.0),
                           child: TextButton(
                             onPressed: () {
                               setState(() {
                                 _onlyWithRewards = false;
                                 _onlyWithPoints = false;
                                 _selectedCategory = 'All';
                               });
                             },
                             child: const Text('Clear All'),
                           ),
                         ),
                      ],
                    ),
                  ),

                // Business list
                Expanded(
                  child: businessListAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
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
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateMarkers(businesses);
                      });

                      final items = businesses
                          .where((b) {
                            // 1. Search filter
                            if (_searchQuery.isNotEmpty &&
                                !b.name.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                )) {
                              return false;
                            }

                            // 2. Category Filter
                            if (_selectedCategory != 'All' && 
                                b.category != _selectedCategory) {
                              return false;
                            }

                            // 3. Rewards Filter (Has promotion)
                            if (_onlyWithRewards && b.promotion == null) {
                              return false;
                            }

                            // 4. Points Filter (Has check-in points > 0)
                            if (_onlyWithPoints && (b.checkInPoints == null || b.checkInPoints! <= 0)) {
                              return false;
                            }

                            return b.latitude != 0.0 && b.longitude != 0.0;
                          })
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

                      if (_userPosition != null) {
                        items.sort((a, b) {
                          if (a.distance == null) return 1;
                          if (b.distance == null) return -1;
                          return a.distance!.compareTo(b.distance!);
                        });
                      }

                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: AppColors.lightGrey,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Text('No businesses match your search'),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshBusinesses,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _BusinessDistanceCard(
                              business: item.business,
                              distance: item.distance,
                              userPosition: _userPosition,
                              onTap: () {
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
                                context.push('/business/${item.business.id}');
                              },
                              context: context,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Businesses',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                // Update local state inside modal
                                setState(() {
                                  _onlyWithRewards = false;
                                  _onlyWithPoints = false;
                                  _selectedCategory = 'All';
                                });
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Reset All'),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: AppSpacing.md),
                      
                      // 1. Quick Filters
                      Text(
                        'Quick Filters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Rewards Only'),
                            selected: _onlyWithRewards,
                            avatar: _onlyWithRewards 
                                ? const Icon(Icons.check, size: 18) 
                                : const Icon(Icons.local_offer, size: 18),
                            onSelected: (bool selected) {
                              setModalState(() {
                                setState(() => _onlyWithRewards = selected);
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Points Only'),
                            selected: _onlyWithPoints,
                            avatar: _onlyWithPoints 
                                ? const Icon(Icons.check, size: 18) 
                                : const Icon(Icons.star, size: 18),
                            onSelected: (bool selected) {
                              setModalState(() {
                                setState(() => _onlyWithPoints = selected);
                              });
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // 2. Categories
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((category) {
                          return ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (bool selected) {
                              if (selected) {
                                setModalState(() {
                                  setState(() => _selectedCategory = category);
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Show Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _BusinessWithDistance {
  final Business business;
  final double? distance;

  _BusinessWithDistance(this.business, this.distance);
}

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
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3d2b5e), // Lighter purple for center effect
              Color(0xFF2a1d4a), // Darker purple
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                // Business Icon/Image - smaller
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AsyncImage(
                    imageUrl: business.heroImageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholderAsset: 'assets/images/restaurant_placeholder.png',
                  ),
                ),
                const SizedBox(width: 12),

                // Business Name and Offer Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        business.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white, // White text
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'offer details',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70, // White text with opacity
                        ),
                      ),
                    ],
                  ),
                ),

                // Distance in miles/minutes
                Text(
                  _formatDistance(distance),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white, // White text
                  ),
                ),
                const SizedBox(width: 12),

                // Get Directions Icon
                GestureDetector(
                  onTap: _openDirections,
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white, // White icon
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
