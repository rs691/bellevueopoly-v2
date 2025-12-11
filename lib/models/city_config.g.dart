// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CityConfigImpl _$$CityConfigImplFromJson(Map<String, dynamic> json) =>
    _$CityConfigImpl(
      id: json['id'] as String,
      mapCenterLat: (json['mapCenterLat'] as num).toDouble(),
      mapCenterLng: (json['mapCenterLng'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toDouble(),
    );

Map<String, dynamic> _$$CityConfigImplToJson(_$CityConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mapCenterLat': instance.mapCenterLat,
      'mapCenterLng': instance.mapCenterLng,
      'zoomLevel': instance.zoomLevel,
    };
