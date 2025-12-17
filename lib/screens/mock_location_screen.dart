import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/location_provider.dart';

class MockLocationScreen extends ConsumerStatefulWidget {
  const MockLocationScreen({super.key});

  @override
  ConsumerState<MockLocationScreen> createState() => _MockLocationScreenState();
}

class _MockLocationScreenState extends ConsumerState<MockLocationScreen> {
  final _addressController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final Set<Marker> _markers = {};
  bool _mapInitialized = false;

  // Default to Bellevue, NE
  static const _defaultLocation = LatLng(41.1544, -95.9145);

  // Preset test locations in Bellevue, NE
  final List<Map<String, dynamic>> _presetLocations = [
    {
      'name': 'Chick-fil-A (Cornhusker)',
      'address': '2016 Cornhusker Rd',
      'location': const LatLng(41.1844, -95.9292),
    },
    {
      'name': 'Edward Jones (Galvin)',
      'address': '1103 Galvin Rd S',
      'location': const LatLng(41.1505, -95.9397),
    },
    {
      'name': 'Bellevue Downtown',
      'address': 'Mission Ave & Franklin St',
      'location': const LatLng(41.1369, -95.8908),
    },
    {
      'name': 'Custom Test Location',
      'address': 'Tap map or search',
      'location': const LatLng(41.1544, -95.9145),
    },
  ];

  @override
  void dispose() {
    _addressController.dispose();
    try {
      if (_mapInitialized && _mapController != null) {
        _mapController?.dispose();
      }
    } catch (e) {
      print('Error disposing map controller: $e');
    }
    super.dispose();
  }

  Future<void> _setMockLocationFromAddress() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final locations = await locationFromAddress(_addressController.text);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);
        _updateSelectedLocation(latLng);
      } else {
        setState(() {
          _errorText = 'Address not found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateSelectedLocation(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('mock_location'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 15),
    );
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      final position = Position(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
      print('Setting mock location: ${position.latitude}, ${position.longitude}');
      ref.read(mockLocationProvider.notifier).setMockLocation(position);
      print('Mock location set, popping screen');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Location'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmLocation,
              tooltip: 'Confirm Location',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Search Address',
                    errorText: _errorText,
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _setMockLocationFromAddress,
                          ),
                  ),
                  onSubmitted: (_) => _setMockLocationFromAddress(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap map or select a preset location',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Preset locations chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _presetLocations.length,
              itemBuilder: (context, index) {
                final preset = _presetLocations[index];
                final isSelected = _selectedLocation == preset['location'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(preset['name']),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _updateSelectedLocation(preset['location']);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          
          // Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _defaultLocation,
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
                _mapInitialized = true;
                print('Mock location map created');
              },
              onTap: _updateSelectedLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Selected: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(mockLocationProvider.notifier).clearMockLocation();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Clear & Exit'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedLocation != null ? _confirmLocation : null,
                        child: const Text('Set Location'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
