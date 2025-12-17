import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

final mockLocationProvider =
    NotifierProvider<MockLocationNotifier, Position?>(() {
  return MockLocationNotifier();
});

class MockLocationNotifier extends Notifier<Position?> {
  @override
  Position? build() => null;

  void setMockLocation(Position position) {
    state = position;
  }

  void clearMockLocation() {
    state = null;
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Current user position stream
final userLocationProvider = StreamProvider<Position?>((ref) async* {
  final mockLocation = ref.watch(mockLocationProvider);
  if (mockLocation != null) {
    yield mockLocation;
    return;
  }

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