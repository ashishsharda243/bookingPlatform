// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Slot _$SlotFromJson(Map<String, dynamic> json) {
  return _Slot.fromJson(json);
}

/// @nodoc
mixin _$Slot {
  String get id => throw _privateConstructorUsedError;
  String get hallId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String id,
      String hallId,
      DateTime date,
      String startTime,
      String endTime,
      String status,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      String hallId,
      DateTime date,
      String startTime,
      String endTime,
      String status,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String id,
      String hallId,
      DateTime date,
      String startTime,
      String endTime,
      String status,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Slot value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Slot value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Slot value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this Slot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlotCopyWith<Slot> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlotCopyWith<$Res> {
  factory $SlotCopyWith(Slot value, $Res Function(Slot) then) =
      _$SlotCopyWithImpl<$Res, Slot>;
  @useResult
  $Res call({
    String id,
    String hallId,
    DateTime date,
    String startTime,
    String endTime,
    String status,
  });
}

/// @nodoc
class _$SlotCopyWithImpl<$Res, $Val extends Slot>
    implements $SlotCopyWith<$Res> {
  _$SlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hallId = null,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            hallId: null == hallId
                ? _value.hallId
                : hallId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SlotImplCopyWith<$Res> implements $SlotCopyWith<$Res> {
  factory _$$SlotImplCopyWith(
    _$SlotImpl value,
    $Res Function(_$SlotImpl) then,
  ) = __$$SlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String hallId,
    DateTime date,
    String startTime,
    String endTime,
    String status,
  });
}

/// @nodoc
class __$$SlotImplCopyWithImpl<$Res>
    extends _$SlotCopyWithImpl<$Res, _$SlotImpl>
    implements _$$SlotImplCopyWith<$Res> {
  __$$SlotImplCopyWithImpl(_$SlotImpl _value, $Res Function(_$SlotImpl) _then)
    : super(_value, _then);

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hallId = null,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
  }) {
    return _then(
      _$SlotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        hallId: null == hallId
            ? _value.hallId
            : hallId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SlotImpl implements _Slot {
  const _$SlotImpl({
    required this.id,
    required this.hallId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory _$SlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$SlotImplFromJson(json);

  @override
  final String id;
  @override
  final String hallId;
  @override
  final DateTime date;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  final String status;

  @override
  String toString() {
    return 'Slot(id: $id, hallId: $hallId, date: $date, startTime: $startTime, endTime: $endTime, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.hallId, hallId) || other.hallId == hallId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, hallId, date, startTime, endTime, status);

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlotImplCopyWith<_$SlotImpl> get copyWith =>
      __$$SlotImplCopyWithImpl<_$SlotImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String id,
      String hallId,
      DateTime date,
      String startTime,
      String endTime,
      String status,
    )
    $default,
  ) {
    return $default(id, hallId, date, startTime, endTime, status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      String hallId,
      DateTime date,
      String startTime,
      String endTime,
      String status,
    )?
    $default,
  ) {
    return $default?.call(id, hallId, date, startTime, endTime, status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String id,
      String hallId,
      DateTime date,
      String startTime,
      String endTime,
      String status,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(id, hallId, date, startTime, endTime, status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(TResult Function(_Slot value) $default) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Slot value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Slot value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SlotImplToJson(this);
  }
}

abstract class _Slot implements Slot {
  const factory _Slot({
    required final String id,
    required final String hallId,
    required final DateTime date,
    required final String startTime,
    required final String endTime,
    required final String status,
  }) = _$SlotImpl;

  factory _Slot.fromJson(Map<String, dynamic> json) = _$SlotImpl.fromJson;

  @override
  String get id;
  @override
  String get hallId;
  @override
  DateTime get date;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  String get status;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlotImplCopyWith<_$SlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
