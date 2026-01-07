import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Current user position stream
final userLocationProvider = StreamProvider<Position?>((ref) async* {
  final locationService = ref.watch(locationServiceProvider);
  final hasPermission = await locationService.requestLocationPermission();
  
  if (!hasPermission) {
    yield null;
    return;
  }

  // Get initial position
  final initial = await locationService.getCurrentPosition();
  yield initial;

  // Stream updates
  await for (final position in locationService.getPositionStream()) {
    yield position;
  }
});
