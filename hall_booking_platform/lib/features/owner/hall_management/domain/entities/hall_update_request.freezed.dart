// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hall_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HallUpdateRequest _$HallUpdateRequestFromJson(Map<String, dynamic> json) {
  return _HallUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$HallUpdateRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double? get lat => throw _privateConstructorUsedError;
  double? get lng => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  List<String>? get amenities => throw _privateConstructorUsedError;
  int? get slotDurationMinutes => throw _privateConstructorUsedError;
  double? get basePrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'google_map_link')
  String? get googleMapLink => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String? name,
      String? description,
      double? lat,
      double? lng,
      String? address,
      List<String>? amenities,
      int? slotDurationMinutes,
      double? basePrice,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String? name,
      String? description,
      double? lat,
      double? lng,
      String? address,
      List<String>? amenities,
      int? slotDurationMinutes,
      double? basePrice,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String? name,
      String? description,
      double? lat,
      double? lng,
      String? address,
      List<String>? amenities,
      int? slotDurationMinutes,
      double? basePrice,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HallUpdateRequest value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HallUpdateRequest value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HallUpdateRequest value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this HallUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HallUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HallUpdateRequestCopyWith<HallUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HallUpdateRequestCopyWith<$Res> {
  factory $HallUpdateRequestCopyWith(
    HallUpdateRequest value,
    $Res Function(HallUpdateRequest) then,
  ) = _$HallUpdateRequestCopyWithImpl<$Res, HallUpdateRequest>;
  @useResult
  $Res call({
    String? name,
    String? description,
    double? lat,
    double? lng,
    String? address,
    List<String>? amenities,
    int? slotDurationMinutes,
    double? basePrice,
    @JsonKey(name: 'google_map_link') String? googleMapLink,
  });
}

/// @nodoc
class _$HallUpdateRequestCopyWithImpl<$Res, $Val extends HallUpdateRequest>
    implements $HallUpdateRequestCopyWith<$Res> {
  _$HallUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HallUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? address = freezed,
    Object? amenities = freezed,
    Object? slotDurationMinutes = freezed,
    Object? basePrice = freezed,
    Object? googleMapLink = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            lat: freezed == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double?,
            lng: freezed == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            amenities: freezed == amenities
                ? _value.amenities
                : amenities // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            slotDurationMinutes: freezed == slotDurationMinutes
                ? _value.slotDurationMinutes
                : slotDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            basePrice: freezed == basePrice
                ? _value.basePrice
                : basePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
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
abstract class _$$HallUpdateRequestImplCopyWith<$Res>
    implements $HallUpdateRequestCopyWith<$Res> {
  factory _$$HallUpdateRequestImplCopyWith(
    _$HallUpdateRequestImpl value,
    $Res Function(_$HallUpdateRequestImpl) then,
  ) = __$$HallUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? description,
    double? lat,
    double? lng,
    String? address,
    List<String>? amenities,
    int? slotDurationMinutes,
    double? basePrice,
    @JsonKey(name: 'google_map_link') String? googleMapLink,
  });
}

/// @nodoc
class __$$HallUpdateRequestImplCopyWithImpl<$Res>
    extends _$HallUpdateRequestCopyWithImpl<$Res, _$HallUpdateRequestImpl>
    implements _$$HallUpdateRequestImplCopyWith<$Res> {
  __$$HallUpdateRequestImplCopyWithImpl(
    _$HallUpdateRequestImpl _value,
    $Res Function(_$HallUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HallUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? address = freezed,
    Object? amenities = freezed,
    Object? slotDurationMinutes = freezed,
    Object? basePrice = freezed,
    Object? googleMapLink = freezed,
  }) {
    return _then(
      _$HallUpdateRequestImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        lat: freezed == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double?,
        lng: freezed == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        amenities: freezed == amenities
            ? _value._amenities
            : amenities // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        slotDurationMinutes: freezed == slotDurationMinutes
            ? _value.slotDurationMinutes
            : slotDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        basePrice: freezed == basePrice
            ? _value.basePrice
            : basePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
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
class _$HallUpdateRequestImpl implements _HallUpdateRequest {
  const _$HallUpdateRequestImpl({
    this.name,
    this.description,
    this.lat,
    this.lng,
    this.address,
    final List<String>? amenities,
    this.slotDurationMinutes,
    this.basePrice,
    @JsonKey(name: 'google_map_link') this.googleMapLink,
  }) : _amenities = amenities;

  factory _$HallUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$HallUpdateRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  final double? lat;
  @override
  final double? lng;
  @override
  final String? address;
  final List<String>? _amenities;
  @override
  List<String>? get amenities {
    final value = _amenities;
    if (value == null) return null;
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? slotDurationMinutes;
  @override
  final double? basePrice;
  @override
  @JsonKey(name: 'google_map_link')
  final String? googleMapLink;

  @override
  String toString() {
    return 'HallUpdateRequest(name: $name, description: $description, lat: $lat, lng: $lng, address: $address, amenities: $amenities, slotDurationMinutes: $slotDurationMinutes, basePrice: $basePrice, googleMapLink: $googleMapLink)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HallUpdateRequestImpl &&
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

  /// Create a copy of HallUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HallUpdateRequestImplCopyWith<_$HallUpdateRequestImpl> get copyWith =>
      __$$HallUpdateRequestImplCopyWithImpl<_$HallUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String? name,
      String? description,
      double? lat,
      double? lng,
      String? address,
      List<String>? amenities,
      int? slotDurationMinutes,
      double? basePrice,
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
      String? name,
      String? description,
      double? lat,
      double? lng,
      String? address,
      List<String>? amenities,
      int? slotDurationMinutes,
      double? basePrice,
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
      String? name,
      String? description,
      double? lat,
      double? lng,
      String? address,
      List<String>? amenities,
      int? slotDurationMinutes,
      double? basePrice,
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
    TResult Function(_HallUpdateRequest value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HallUpdateRequest value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HallUpdateRequest value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$HallUpdateRequestImplToJson(this);
  }
}

abstract class _HallUpdateRequest implements HallUpdateRequest {
  const factory _HallUpdateRequest({
    final String? name,
    final String? description,
    final double? lat,
    final double? lng,
    final String? address,
    final List<String>? amenities,
    final int? slotDurationMinutes,
    final double? basePrice,
    @JsonKey(name: 'google_map_link') final String? googleMapLink,
  }) = _$HallUpdateRequestImpl;

  factory _HallUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$HallUpdateRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  double? get lat;
  @override
  double? get lng;
  @override
  String? get address;
  @override
  List<String>? get amenities;
  @override
  int? get slotDurationMinutes;
  @override
  double? get basePrice;
  @override
  @JsonKey(name: 'google_map_link')
  String? get googleMapLink;

  /// Create a copy of HallUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HallUpdateRequestImplCopyWith<_$HallUpdateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
