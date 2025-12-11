// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'city_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CityConfig _$CityConfigFromJson(Map<String, dynamic> json) {
  return _CityConfig.fromJson(json);
}

/// @nodoc
mixin _$CityConfig {
  String get id =>
      throw _privateConstructorUsedError; // Could be 'bellevue_config'
  double get mapCenterLat => throw _privateConstructorUsedError;
  double get mapCenterLng => throw _privateConstructorUsedError;
  double get zoomLevel => throw _privateConstructorUsedError;

  /// Serializes this CityConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CityConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CityConfigCopyWith<CityConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityConfigCopyWith<$Res> {
  factory $CityConfigCopyWith(
    CityConfig value,
    $Res Function(CityConfig) then,
  ) = _$CityConfigCopyWithImpl<$Res, CityConfig>;
  @useResult
  $Res call({
    String id,
    double mapCenterLat,
    double mapCenterLng,
    double zoomLevel,
  });
}

/// @nodoc
class _$CityConfigCopyWithImpl<$Res, $Val extends CityConfig>
    implements $CityConfigCopyWith<$Res> {
  _$CityConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CityConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mapCenterLat = null,
    Object? mapCenterLng = null,
    Object? zoomLevel = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            mapCenterLat: null == mapCenterLat
                ? _value.mapCenterLat
                : mapCenterLat // ignore: cast_nullable_to_non_nullable
                      as double,
            mapCenterLng: null == mapCenterLng
                ? _value.mapCenterLng
                : mapCenterLng // ignore: cast_nullable_to_non_nullable
                      as double,
            zoomLevel: null == zoomLevel
                ? _value.zoomLevel
                : zoomLevel // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CityConfigImplCopyWith<$Res>
    implements $CityConfigCopyWith<$Res> {
  factory _$$CityConfigImplCopyWith(
    _$CityConfigImpl value,
    $Res Function(_$CityConfigImpl) then,
  ) = __$$CityConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    double mapCenterLat,
    double mapCenterLng,
    double zoomLevel,
  });
}

/// @nodoc
class __$$CityConfigImplCopyWithImpl<$Res>
    extends _$CityConfigCopyWithImpl<$Res, _$CityConfigImpl>
    implements _$$CityConfigImplCopyWith<$Res> {
  __$$CityConfigImplCopyWithImpl(
    _$CityConfigImpl _value,
    $Res Function(_$CityConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CityConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mapCenterLat = null,
    Object? mapCenterLng = null,
    Object? zoomLevel = null,
  }) {
    return _then(
      _$CityConfigImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        mapCenterLat: null == mapCenterLat
            ? _value.mapCenterLat
            : mapCenterLat // ignore: cast_nullable_to_non_nullable
                  as double,
        mapCenterLng: null == mapCenterLng
            ? _value.mapCenterLng
            : mapCenterLng // ignore: cast_nullable_to_non_nullable
                  as double,
        zoomLevel: null == zoomLevel
            ? _value.zoomLevel
            : zoomLevel // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CityConfigImpl implements _CityConfig {
  const _$CityConfigImpl({
    required this.id,
    required this.mapCenterLat,
    required this.mapCenterLng,
    required this.zoomLevel,
  });

  factory _$CityConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$CityConfigImplFromJson(json);

  @override
  final String id;
  // Could be 'bellevue_config'
  @override
  final double mapCenterLat;
  @override
  final double mapCenterLng;
  @override
  final double zoomLevel;

  @override
  String toString() {
    return 'CityConfig(id: $id, mapCenterLat: $mapCenterLat, mapCenterLng: $mapCenterLng, zoomLevel: $zoomLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mapCenterLat, mapCenterLat) ||
                other.mapCenterLat == mapCenterLat) &&
            (identical(other.mapCenterLng, mapCenterLng) ||
                other.mapCenterLng == mapCenterLng) &&
            (identical(other.zoomLevel, zoomLevel) ||
                other.zoomLevel == zoomLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, mapCenterLat, mapCenterLng, zoomLevel);

  /// Create a copy of CityConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CityConfigImplCopyWith<_$CityConfigImpl> get copyWith =>
      __$$CityConfigImplCopyWithImpl<_$CityConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CityConfigImplToJson(this);
  }
}

abstract class _CityConfig implements CityConfig {
  const factory _CityConfig({
    required final String id,
    required final double mapCenterLat,
    required final double mapCenterLng,
    required final double zoomLevel,
  }) = _$CityConfigImpl;

  factory _CityConfig.fromJson(Map<String, dynamic> json) =
      _$CityConfigImpl.fromJson;

  @override
  String get id; // Could be 'bellevue_config'
  @override
  double get mapCenterLat;
  @override
  double get mapCenterLng;
  @override
  double get zoomLevel;

  /// Create a copy of CityConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CityConfigImplCopyWith<_$CityConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
