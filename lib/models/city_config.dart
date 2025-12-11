// lib/models/city_config.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'city_config.freezed.dart';
part 'city_config.g.dart';

@freezed
class CityConfig with _$CityConfig {
  const factory CityConfig({
    required String id, // Could be 'bellevue_config'
    required double mapCenterLat,
    required double mapCenterLng,
    required double zoomLevel,
    // Add any other city-wide configuration parameters here
  }) = _CityConfig;

  factory CityConfig.fromJson(Map<String, dynamic> json) => _$CityConfigFromJson(json);
}