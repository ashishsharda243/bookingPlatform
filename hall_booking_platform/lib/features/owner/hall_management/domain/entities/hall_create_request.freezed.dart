// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hall_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HallCreateRequest _$HallCreateRequestFromJson(Map<String, dynamic> json) {
  return _HallCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$HallCreateRequest {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  List<String> get amenities => throw _privateConstructorUsedError;
  int get slotDurationMinutes => throw _privateConstructorUsedError;
  double get basePrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'google_map_link')
  String? get googleMapLink => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HallCreateRequest value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HallCreateRequest value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HallCreateRequest value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this HallCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HallCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HallCreateRequestCopyWith<HallCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HallCreateRequestCopyWith<$Res> {
  factory $HallCreateRequestCopyWith(
    HallCreateRequest value,
    $Res Function(HallCreateRequest) then,
  ) = _$HallCreateRequestCopyWithImpl<$Res, HallCreateRequest>;
  @useResult
  $Res call({
    String name,
    String description,
    double lat,
    double lng,
    String address,
    List<String> amenities,
    int slotDurationMinutes,
    double basePrice,
    @JsonKey(name: 'google_map_link') String? googleMapLink,
  });
}

/// @nodoc
class _$HallCreateRequestCopyWithImpl<$Res, $Val extends HallCreateRequest>
    implements $HallCreateRequestCopyWith<$Res> {
  _$HallCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HallCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? lat = null,
    Object? lng = null,
    Object? address = null,
    Object? amenities = null,
    Object? slotDurationMinutes = null,
    Object? basePrice = null,
    Object? googleMapLink = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            amenities: null == amenities
                ? _value.amenities
                : amenities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            slotDurationMinutes: null == slotDurationMinutes
                ? _value.slotDurationMinutes
                : slotDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            basePrice: null == basePrice
                ? _value.basePrice
                : basePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            googleMapLink: freezed == googleMapLink
                ? _value.googleMapLink
                : googleMapLink // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HallCreateRequestImplCopyWith<$Res>
    implements $HallCreateRequestCopyWith<$Res> {
  factory _$$HallCreateRequestImplCopyWith(
    _$HallCreateRequestImpl value,
    $Res Function(_$HallCreateRequestImpl) then,
  ) = __$$HallCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String description,
    double lat,
    double lng,
    String address,
    List<String> amenities,
    int slotDurationMinutes,
    double basePrice,
    @JsonKey(name: 'google_map_link') String? googleMapLink,
  });
}

/// @nodoc
class __$$HallCreateRequestImplCopyWithImpl<$Res>
    extends _$HallCreateRequestCopyWithImpl<$Res, _$HallCreateRequestImpl>
    implements _$$HallCreateRequestImplCopyWith<$Res> {
  __$$HallCreateRequestImplCopyWithImpl(
    _$HallCreateRequestImpl _value,
    $Res Function(_$HallCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HallCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? lat = null,
    Object? lng = null,
    Object? address = null,
    Object? amenities = null,
    Object? slotDurationMinutes = null,
    Object? basePrice = null,
    Object? googleMapLink = freezed,
  }) {
    return _then(
      _$HallCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        amenities: null == amenities
            ? _value._amenities
            : amenities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        slotDurationMinutes: null == slotDurationMinutes
            ? _value.slotDurationMinutes
            : slotDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        basePrice: null == basePrice
            ? _value.basePrice
            : basePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        googleMapLink: freezed == googleMapLink
            ? _value.googleMapLink
            : googleMapLink // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HallCreateRequestImpl implements _HallCreateRequest {
  const _$HallCreateRequestImpl({
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.address,
    required final List<String> amenities,
    required this.slotDurationMinutes,
    required this.basePrice,
    @JsonKey(name: 'google_map_link') this.googleMapLink,
  }) : _amenities = amenities;

  factory _$HallCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$HallCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final String address;
  final List<String> _amenities;
  @override
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  @override
  final int slotDurationMinutes;
  @override
  final double basePrice;
  @override
  @JsonKey(name: 'google_map_link')
  final String? googleMapLink;

  @override
  String toString() {
    return 'HallCreateRequest(name: $name, description: $description, lat: $lat, lng: $lng, address: $address, amenities: $amenities, slotDurationMinutes: $slotDurationMinutes, basePrice: $basePrice, googleMapLink: $googleMapLink)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HallCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.address, address) || other.address == address) &&
            const DeepCollectionEquality().equals(
              other._amenities,
              _amenities,
            ) &&
            (identical(other.slotDurationMinutes, slotDurationMinutes) ||
                other.slotDurationMinutes == slotDurationMinutes) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.googleMapLink, googleMapLink) ||
                other.googleMapLink == googleMapLink));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    lat,
    lng,
    address,
    const DeepCollectionEquality().hash(_amenities),
    slotDurationMinutes,
    basePrice,
    googleMapLink,
  );

  /// Create a copy of HallCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HallCreateRequestImplCopyWith<_$HallCreateRequestImpl> get copyWith =>
      __$$HallCreateRequestImplCopyWithImpl<_$HallCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )
    $default,
  ) {
    return $default(
      name,
      description,
      lat,
      lng,
      address,
      amenities,
      slotDurationMinutes,
      basePrice,
      googleMapLink,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default,
  ) {
    return $default?.call(
      name,
      description,
      lat,
      lng,
      address,
      amenities,
      slotDurationMinutes,
      basePrice,
      googleMapLink,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
        name,
        description,
        lat,
        lng,
        address,
        amenities,
        slotDurationMinutes,
        basePrice,
        googleMapLink,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HallCreateRequest value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HallCreateRequest value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HallCreateRequest value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$HallCreateRequestImplToJson(this);
  }
}

abstract class _HallCreateRequest implements HallCreateRequest {
  const factory _HallCreateRequest({
    required final String name,
    required final String description,
    required final double lat,
    required final double lng,
    required final String address,
    required final List<String> amenities,
    required final int slotDurationMinutes,
    required final double basePrice,
    @JsonKey(name: 'google_map_link') final String? googleMapLink,
  }) = _$HallCreateRequestImpl;

  factory _HallCreateRequest.fromJson(Map<String, dynamic> json) =
      _$HallCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  double get lat;
  @override
  double get lng;
  @override
  String get address;
  @override
  List<String> get amenities;
  @override
  int get slotDurationMinutes;
  @override
  double get basePrice;
  @override
  @JsonKey(name: 'google_map_link')
  String? get googleMapLink;

  /// Create a copy of HallCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HallCreateRequestImplCopyWith<_$HallCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
