// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hall.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Hall _$HallFromJson(Map<String, dynamic> json) {
  return _Hall.fromJson(json);
}

/// @nodoc
mixin _$Hall {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  List<String> get amenities => throw _privateConstructorUsedError;
  int get slotDurationMinutes => throw _privateConstructorUsedError;
  double get basePrice => throw _privateConstructorUsedError;
  String get approvalStatus => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  double? get distance => throw _privateConstructorUsedError;
  double? get averageRating => throw _privateConstructorUsedError;
  List<String>? get imageUrls => throw _privateConstructorUsedError;
  @JsonKey(name: 'google_map_link')
  String? get googleMapLink => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String id,
      String ownerId,
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      String approvalStatus,
      bool isActive,
      DateTime createdAt,
      double? distance,
      double? averageRating,
      List<String>? imageUrls,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      String ownerId,
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      String approvalStatus,
      bool isActive,
      DateTime createdAt,
      double? distance,
      double? averageRating,
      List<String>? imageUrls,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String id,
      String ownerId,
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      String approvalStatus,
      bool isActive,
      DateTime createdAt,
      double? distance,
      double? averageRating,
      List<String>? imageUrls,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Hall value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Hall value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Hall value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this Hall to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Hall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HallCopyWith<Hall> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HallCopyWith<$Res> {
  factory $HallCopyWith(Hall value, $Res Function(Hall) then) =
      _$HallCopyWithImpl<$Res, Hall>;
  @useResult
  $Res call({
    String id,
    String ownerId,
    String name,
    String description,
    double lat,
    double lng,
    String address,
    List<String> amenities,
    int slotDurationMinutes,
    double basePrice,
    String approvalStatus,
    bool isActive,
    DateTime createdAt,
    double? distance,
    double? averageRating,
    List<String>? imageUrls,
    @JsonKey(name: 'google_map_link') String? googleMapLink,
  });
}

/// @nodoc
class _$HallCopyWithImpl<$Res, $Val extends Hall>
    implements $HallCopyWith<$Res> {
  _$HallCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Hall
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? description = null,
    Object? lat = null,
    Object? lng = null,
    Object? address = null,
    Object? amenities = null,
    Object? slotDurationMinutes = null,
    Object? basePrice = null,
    Object? approvalStatus = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? distance = freezed,
    Object? averageRating = freezed,
    Object? imageUrls = freezed,
    Object? googleMapLink = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
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
            approvalStatus: null == approvalStatus
                ? _value.approvalStatus
                : approvalStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            distance: freezed == distance
                ? _value.distance
                : distance // ignore: cast_nullable_to_non_nullable
                      as double?,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            imageUrls: freezed == imageUrls
                ? _value.imageUrls
                : imageUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
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
abstract class _$$HallImplCopyWith<$Res> implements $HallCopyWith<$Res> {
  factory _$$HallImplCopyWith(
    _$HallImpl value,
    $Res Function(_$HallImpl) then,
  ) = __$$HallImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ownerId,
    String name,
    String description,
    double lat,
    double lng,
    String address,
    List<String> amenities,
    int slotDurationMinutes,
    double basePrice,
    String approvalStatus,
    bool isActive,
    DateTime createdAt,
    double? distance,
    double? averageRating,
    List<String>? imageUrls,
    @JsonKey(name: 'google_map_link') String? googleMapLink,
  });
}

/// @nodoc
class __$$HallImplCopyWithImpl<$Res>
    extends _$HallCopyWithImpl<$Res, _$HallImpl>
    implements _$$HallImplCopyWith<$Res> {
  __$$HallImplCopyWithImpl(_$HallImpl _value, $Res Function(_$HallImpl) _then)
    : super(_value, _then);

  /// Create a copy of Hall
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? description = null,
    Object? lat = null,
    Object? lng = null,
    Object? address = null,
    Object? amenities = null,
    Object? slotDurationMinutes = null,
    Object? basePrice = null,
    Object? approvalStatus = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? distance = freezed,
    Object? averageRating = freezed,
    Object? imageUrls = freezed,
    Object? googleMapLink = freezed,
  }) {
    return _then(
      _$HallImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
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
        approvalStatus: null == approvalStatus
            ? _value.approvalStatus
            : approvalStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        distance: freezed == distance
            ? _value.distance
            : distance // ignore: cast_nullable_to_non_nullable
                  as double?,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        imageUrls: freezed == imageUrls
            ? _value._imageUrls
            : imageUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
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
class _$HallImpl implements _Hall {
  const _$HallImpl({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.lat = 0.0,
    this.lng = 0.0,
    required this.address,
    required final List<String> amenities,
    this.slotDurationMinutes = 60,
    this.basePrice = 0.0,
    required this.approvalStatus,
    this.isActive = true,
    required this.createdAt,
    this.distance,
    this.averageRating,
    final List<String>? imageUrls,
    @JsonKey(name: 'google_map_link') this.googleMapLink,
  }) : _amenities = amenities,
       _imageUrls = imageUrls;

  factory _$HallImpl.fromJson(Map<String, dynamic> json) =>
      _$$HallImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey()
  final double lat;
  @override
  @JsonKey()
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
  @JsonKey()
  final int slotDurationMinutes;
  @override
  @JsonKey()
  final double basePrice;
  @override
  final String approvalStatus;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final double? distance;
  @override
  final double? averageRating;
  final List<String>? _imageUrls;
  @override
  List<String>? get imageUrls {
    final value = _imageUrls;
    if (value == null) return null;
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'google_map_link')
  final String? googleMapLink;

  @override
  String toString() {
    return 'Hall(id: $id, ownerId: $ownerId, name: $name, description: $description, lat: $lat, lng: $lng, address: $address, amenities: $amenities, slotDurationMinutes: $slotDurationMinutes, basePrice: $basePrice, approvalStatus: $approvalStatus, isActive: $isActive, createdAt: $createdAt, distance: $distance, averageRating: $averageRating, imageUrls: $imageUrls, googleMapLink: $googleMapLink)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HallImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
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
            (identical(other.approvalStatus, approvalStatus) ||
                other.approvalStatus == approvalStatus) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            const DeepCollectionEquality().equals(
              other._imageUrls,
              _imageUrls,
            ) &&
            (identical(other.googleMapLink, googleMapLink) ||
                other.googleMapLink == googleMapLink));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ownerId,
    name,
    description,
    lat,
    lng,
    address,
    const DeepCollectionEquality().hash(_amenities),
    slotDurationMinutes,
    basePrice,
    approvalStatus,
    isActive,
    createdAt,
    distance,
    averageRating,
    const DeepCollectionEquality().hash(_imageUrls),
    googleMapLink,
  );

  /// Create a copy of Hall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HallImplCopyWith<_$HallImpl> get copyWith =>
      __$$HallImplCopyWithImpl<_$HallImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String id,
      String ownerId,
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      String approvalStatus,
      bool isActive,
      DateTime createdAt,
      double? distance,
      double? averageRating,
      List<String>? imageUrls,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )
    $default,
  ) {
    return $default(
      id,
      ownerId,
      name,
      description,
      lat,
      lng,
      address,
      amenities,
      slotDurationMinutes,
      basePrice,
      approvalStatus,
      isActive,
      createdAt,
      distance,
      averageRating,
      imageUrls,
      googleMapLink,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      String ownerId,
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      String approvalStatus,
      bool isActive,
      DateTime createdAt,
      double? distance,
      double? averageRating,
      List<String>? imageUrls,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default,
  ) {
    return $default?.call(
      id,
      ownerId,
      name,
      description,
      lat,
      lng,
      address,
      amenities,
      slotDurationMinutes,
      basePrice,
      approvalStatus,
      isActive,
      createdAt,
      distance,
      averageRating,
      imageUrls,
      googleMapLink,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String id,
      String ownerId,
      String name,
      String description,
      double lat,
      double lng,
      String address,
      List<String> amenities,
      int slotDurationMinutes,
      double basePrice,
      String approvalStatus,
      bool isActive,
      DateTime createdAt,
      double? distance,
      double? averageRating,
      List<String>? imageUrls,
      @JsonKey(name: 'google_map_link') String? googleMapLink,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
        id,
        ownerId,
        name,
        description,
        lat,
        lng,
        address,
        amenities,
        slotDurationMinutes,
        basePrice,
        approvalStatus,
        isActive,
        createdAt,
        distance,
        averageRating,
        imageUrls,
        googleMapLink,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(TResult Function(_Hall value) $default) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Hall value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Hall value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$HallImplToJson(this);
  }
}

abstract class _Hall implements Hall {
  const factory _Hall({
    required final String id,
    required final String ownerId,
    required final String name,
    required final String description,
    final double lat,
    final double lng,
    required final String address,
    required final List<String> amenities,
    final int slotDurationMinutes,
    final double basePrice,
    required final String approvalStatus,
    final bool isActive,
    required final DateTime createdAt,
    final double? distance,
    final double? averageRating,
    final List<String>? imageUrls,
    @JsonKey(name: 'google_map_link') final String? googleMapLink,
  }) = _$HallImpl;

  factory _Hall.fromJson(Map<String, dynamic> json) = _$HallImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
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
  String get approvalStatus;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  double? get distance;
  @override
  double? get averageRating;
  @override
  List<String>? get imageUrls;
  @override
  @JsonKey(name: 'google_map_link')
  String? get googleMapLink;

  /// Create a copy of Hall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HallImplCopyWith<_$HallImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
