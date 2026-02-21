// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Booking _$BookingFromJson(Map<String, dynamic> json) {
  return _Booking.fromJson(json);
}

/// @nodoc
mixin _$Booking {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get hallId => throw _privateConstructorUsedError;
  String get slotId => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  String get bookingStatus => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Hall? get hall => throw _privateConstructorUsedError;
  Slot? get slot => throw _privateConstructorUsedError;
  AppUser? get user => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String id,
      String userId,
      String hallId,
      String slotId,
      double totalPrice,
      String paymentStatus,
      String bookingStatus,
      DateTime createdAt,
      Hall? hall,
      Slot? slot,
      AppUser? user,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      String userId,
      String hallId,
      String slotId,
      double totalPrice,
      String paymentStatus,
      String bookingStatus,
      DateTime createdAt,
      Hall? hall,
      Slot? slot,
      AppUser? user,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String id,
      String userId,
      String hallId,
      String slotId,
      double totalPrice,
      String paymentStatus,
      String bookingStatus,
      DateTime createdAt,
      Hall? hall,
      Slot? slot,
      AppUser? user,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Booking value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Booking value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Booking value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingCopyWith<Booking> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingCopyWith<$Res> {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) then) =
      _$BookingCopyWithImpl<$Res, Booking>;
  @useResult
  $Res call({
    String id,
    String userId,
    String hallId,
    String slotId,
    double totalPrice,
    String paymentStatus,
    String bookingStatus,
    DateTime createdAt,
    Hall? hall,
    Slot? slot,
    AppUser? user,
  });

  $HallCopyWith<$Res>? get hall;
  $SlotCopyWith<$Res>? get slot;
  $AppUserCopyWith<$Res>? get user;
}

/// @nodoc
class _$BookingCopyWithImpl<$Res, $Val extends Booking>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? hallId = null,
    Object? slotId = null,
    Object? totalPrice = null,
    Object? paymentStatus = null,
    Object? bookingStatus = null,
    Object? createdAt = null,
    Object? hall = freezed,
    Object? slot = freezed,
    Object? user = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            hallId: null == hallId
                ? _value.hallId
                : hallId // ignore: cast_nullable_to_non_nullable
                      as String,
            slotId: null == slotId
                ? _value.slotId
                : slotId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalPrice: null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            bookingStatus: null == bookingStatus
                ? _value.bookingStatus
                : bookingStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            hall: freezed == hall
                ? _value.hall
                : hall // ignore: cast_nullable_to_non_nullable
                      as Hall?,
            slot: freezed == slot
                ? _value.slot
                : slot // ignore: cast_nullable_to_non_nullable
                      as Slot?,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as AppUser?,
          )
          as $Val,
    );
  }

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HallCopyWith<$Res>? get hall {
    if (_value.hall == null) {
      return null;
    }

    return $HallCopyWith<$Res>(_value.hall!, (value) {
      return _then(_value.copyWith(hall: value) as $Val);
    });
  }

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SlotCopyWith<$Res>? get slot {
    if (_value.slot == null) {
      return null;
    }

    return $SlotCopyWith<$Res>(_value.slot!, (value) {
      return _then(_value.copyWith(slot: value) as $Val);
    });
  }

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppUserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $AppUserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingImplCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$$BookingImplCopyWith(
    _$BookingImpl value,
    $Res Function(_$BookingImpl) then,
  ) = __$$BookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String hallId,
    String slotId,
    double totalPrice,
    String paymentStatus,
    String bookingStatus,
    DateTime createdAt,
    Hall? hall,
    Slot? slot,
    AppUser? user,
  });

  @override
  $HallCopyWith<$Res>? get hall;
  @override
  $SlotCopyWith<$Res>? get slot;
  @override
  $AppUserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$BookingImplCopyWithImpl<$Res>
    extends _$BookingCopyWithImpl<$Res, _$BookingImpl>
    implements _$$BookingImplCopyWith<$Res> {
  __$$BookingImplCopyWithImpl(
    _$BookingImpl _value,
    $Res Function(_$BookingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? hallId = null,
    Object? slotId = null,
    Object? totalPrice = null,
    Object? paymentStatus = null,
    Object? bookingStatus = null,
    Object? createdAt = null,
    Object? hall = freezed,
    Object? slot = freezed,
    Object? user = freezed,
  }) {
    return _then(
      _$BookingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        hallId: null == hallId
            ? _value.hallId
            : hallId // ignore: cast_nullable_to_non_nullable
                  as String,
        slotId: null == slotId
            ? _value.slotId
            : slotId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalPrice: null == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        bookingStatus: null == bookingStatus
            ? _value.bookingStatus
            : bookingStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        hall: freezed == hall
            ? _value.hall
            : hall // ignore: cast_nullable_to_non_nullable
                  as Hall?,
        slot: freezed == slot
            ? _value.slot
            : slot // ignore: cast_nullable_to_non_nullable
                  as Slot?,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as AppUser?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingImpl implements _Booking {
  const _$BookingImpl({
    required this.id,
    required this.userId,
    required this.hallId,
    required this.slotId,
    this.totalPrice = 0.0,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.createdAt,
    this.hall,
    this.slot,
    this.user,
  });

  factory _$BookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String hallId;
  @override
  final String slotId;
  @override
  @JsonKey()
  final double totalPrice;
  @override
  final String paymentStatus;
  @override
  final String bookingStatus;
  @override
  final DateTime createdAt;
  @override
  final Hall? hall;
  @override
  final Slot? slot;
  @override
  final AppUser? user;

  @override
  String toString() {
    return 'Booking(id: $id, userId: $userId, hallId: $hallId, slotId: $slotId, totalPrice: $totalPrice, paymentStatus: $paymentStatus, bookingStatus: $bookingStatus, createdAt: $createdAt, hall: $hall, slot: $slot, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.hallId, hallId) || other.hallId == hallId) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.hall, hall) || other.hall == hall) &&
            (identical(other.slot, slot) || other.slot == slot) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    hallId,
    slotId,
    totalPrice,
    paymentStatus,
    bookingStatus,
    createdAt,
    hall,
    slot,
    user,
  );

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      __$$BookingImplCopyWithImpl<_$BookingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String id,
      String userId,
      String hallId,
      String slotId,
      double totalPrice,
      String paymentStatus,
      String bookingStatus,
      DateTime createdAt,
      Hall? hall,
      Slot? slot,
      AppUser? user,
    )
    $default,
  ) {
    return $default(
      id,
      userId,
      hallId,
      slotId,
      totalPrice,
      paymentStatus,
      bookingStatus,
      createdAt,
      hall,
      slot,
      user,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      String userId,
      String hallId,
      String slotId,
      double totalPrice,
      String paymentStatus,
      String bookingStatus,
      DateTime createdAt,
      Hall? hall,
      Slot? slot,
      AppUser? user,
    )?
    $default,
  ) {
    return $default?.call(
      id,
      userId,
      hallId,
      slotId,
      totalPrice,
      paymentStatus,
      bookingStatus,
      createdAt,
      hall,
      slot,
      user,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String id,
      String userId,
      String hallId,
      String slotId,
      double totalPrice,
      String paymentStatus,
      String bookingStatus,
      DateTime createdAt,
      Hall? hall,
      Slot? slot,
      AppUser? user,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
        id,
        userId,
        hallId,
        slotId,
        totalPrice,
        paymentStatus,
        bookingStatus,
        createdAt,
        hall,
        slot,
        user,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Booking value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Booking value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Booking value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingImplToJson(this);
  }
}

abstract class _Booking implements Booking {
  const factory _Booking({
    required final String id,
    required final String userId,
    required final String hallId,
    required final String slotId,
    final double totalPrice,
    required final String paymentStatus,
    required final String bookingStatus,
    required final DateTime createdAt,
    final Hall? hall,
    final Slot? slot,
    final AppUser? user,
  }) = _$BookingImpl;

  factory _Booking.fromJson(Map<String, dynamic> json) = _$BookingImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get hallId;
  @override
  String get slotId;
  @override
  double get totalPrice;
  @override
  String get paymentStatus;
  @override
  String get bookingStatus;
  @override
  DateTime get createdAt;
  @override
  Hall? get hall;
  @override
  Slot? get slot;
  @override
  AppUser? get user;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
