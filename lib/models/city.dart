import 'package:equatable/equatable.dart';

class MapBounds extends Equatable {
  final double northeastLat;
  final double northeastLng;
  final double southwestLat;
  final double southwestLng;

  const MapBounds({
    required this.northeastLat,
    required this.northeastLng,
    required this.southwestLat,
    required this.southwestLng,
  });

  factory MapBounds.fromJson(Map<String, dynamic> json) {
    final northeast = json['northeast'] as Map<String, dynamic>;
    final southwest = json['southwest'] as Map<String, dynamic>;
    return MapBounds(
      northeastLat: (northeast['latitude'] as num).toDouble(),
      northeastLng: (northeast['longitude'] as num).toDouble(),
      southwestLat: (southwest['latitude'] as num).toDouble(),
      southwestLng: (southwest['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'northeast': {'latitude': northeastLat, 'longitude': northeastLng},
    'southwest': {'latitude': southwestLat, 'longitude': southwestLng},
  };

  @override
  List<Object?> get props => [
    northeastLat,
    northeastLng,
    southwestLat,
    southwestLng,
  ];
}

class ThemeConfig extends Equatable {
  final String name;
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String backgroundColor;
  final String textColor;
  final String fontFamily;

  const ThemeConfig({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    required this.fontFamily,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      name: json['name'] as String,
      primaryColor: json['primaryColor'] as String,
      secondaryColor: json['secondaryColor'] as String,
      accentColor: json['accentColor'] as String,
      backgroundColor: json['backgroundColor'] as String,
      textColor: json['textColor'] as String,
      fontFamily: json['fontFamily'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'accentColor': accentColor,
    'backgroundColor': backgroundColor,
    'textColor': textColor,
    'fontFamily': fontFamily,
  };

  @override
  List<Object?> get props => [
    name,
    primaryColor,
    secondaryColor,
    accentColor,
    backgroundColor,
    textColor,
    fontFamily,
  ];
}

class CityConfig extends Equatable {
  final String name;
  final String region;
  final double mapCenterLat;
  final double mapCenterLng;
  final MapBounds mapBounds;
  final double zoomLevel;
  final ThemeConfig theme;

  const CityConfig({
    required this.name,
    required this.region,
    required this.mapCenterLat,
    required this.mapCenterLng,
    required this.mapBounds,
    required this.zoomLevel,
    required this.theme,
  });

  factory CityConfig.fromJson(Map<String, dynamic> json) {
    final city = json['city'] as Map<String, dynamic>;
    final mapCenter = city['mapCenter'] as Map<String, dynamic>;
    return CityConfig(
      name: city['name'] as String,
      region: city['region'] as String,
      mapCenterLat: (mapCenter['latitude'] as num).toDouble(),
      mapCenterLng: (mapCenter['longitude'] as num).toDouble(),
      mapBounds: MapBounds.fromJson(city['mapBounds'] as Map<String, dynamic>),
      zoomLevel: (city['zoomLevel'] as num).toDouble(),
      theme: ThemeConfig.fromJson(json['theme'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'city': {
      'name': name,
      'region': region,
      'mapCenter': {'latitude': mapCenterLat, 'longitude': mapCenterLng},
      'mapBounds': mapBounds.toJson(),
      'zoomLevel': zoomLevel,
    },
    'theme': theme.toJson(),
  };

  @override
  List<Object?> get props => [
    name,
    region,
    mapCenterLat,
    mapCenterLng,
    mapBounds,
    zoomLevel,
    theme,
  ];
}
