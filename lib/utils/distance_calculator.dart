import 'dart:math';

/// Utility class for calculating distances between geographic coordinates
class DistanceCalculator {
  /// Calculate the distance between two points on Earth using the Haversine formula
  /// Returns distance in kilometers
  ///
  /// [lat1] - Latitude of first point in degrees
  /// [lon1] - Longitude of first point in degrees
  /// [lat2] - Latitude of second point in degrees
  /// [lon2] - Longitude of second point in degrees
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Earth's radius in kilometers
    const double earthRadiusKm = 6371.0;

    // Convert degrees to radians
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Distance in kilometers
    return earthRadiusKm * c;
  }

  /// Calculate distance and return in miles instead of kilometers
  static double calculateDistanceInMiles(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final distanceInKm = calculateDistance(lat1, lon1, lat2, lon2);
    return distanceInKm * 0.621371; // Convert km to miles
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Format distance for display
  /// Returns a human-readable string like "1.2 km" or "850 m"
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '$meters m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  /// Format distance in miles for display
  static String formatDistanceInMiles(double distanceInKm) {
    final miles = distanceInKm * 0.621371;
    if (miles < 1) {
      final feet = (miles * 5280).round();
      return '$feet ft';
    }
    return '${miles.toStringAsFixed(1)} mi';
  }

  /// Check if a point is within a certain radius of another point
  /// [radius] in kilometers
  static bool isWithinRadius(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radius,
  ) {
    final distance = calculateDistance(lat1, lon1, lat2, lon2);
    return distance <= radius;
  }

  /// Sort a list of coordinates by distance from a reference point
  /// Returns a list of indices sorted by distance (closest first)
  static List<int> sortByDistance(
    double refLat,
    double refLon,
    List<Map<String, double>> coordinates,
  ) {
    final distances = <int, double>{};

    for (int i = 0; i < coordinates.length; i++) {
      final lat = coordinates[i]['lat'] ?? 0.0;
      final lon = coordinates[i]['lon'] ?? 0.0;
      distances[i] = calculateDistance(refLat, refLon, lat, lon);
    }

    final sortedIndices = distances.keys.toList()
      ..sort((a, b) => distances[a]!.compareTo(distances[b]!));

    return sortedIndices;
  }
}
