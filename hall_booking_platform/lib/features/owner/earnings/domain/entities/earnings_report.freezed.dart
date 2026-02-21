// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EarningEntry _$EarningEntryFromJson(Map<String, dynamic> json) {
  return _EarningEntry.fromJson(json);
}

/// @nodoc
mixin _$EarningEntry {
  String get hallId => throw _privateConstructorUsedError;
  String get hallName => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;
  int get bookingCount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String hallId,
      String hallName,
      double revenue,
      int bookingCount,
      DateTime date,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String hallId,
      String hallName,
      double revenue,
      int bookingCount,
      DateTime date,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String hallId,
      String hallName,
      double revenue,
      int bookingCount,
      DateTime date,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_EarningEntry value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_EarningEntry value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_EarningEntry value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this EarningEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EarningEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EarningEntryCopyWith<EarningEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EarningEntryCopyWith<$Res> {
  factory $EarningEntryCopyWith(
    EarningEntry value,
    $Res Function(EarningEntry) then,
  ) = _$EarningEntryCopyWithImpl<$Res, EarningEntry>;
  @useResult
  $Res call({
    String hallId,
    String hallName,
    double revenue,
    int bookingCount,
    DateTime date,
  });
}

/// @nodoc
class _$EarningEntryCopyWithImpl<$Res, $Val extends EarningEntry>
    implements $EarningEntryCopyWith<$Res> {
  _$EarningEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EarningEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hallId = null,
    Object? hallName = null,
    Object? revenue = null,
    Object? bookingCount = null,
    Object? date = null,
  }) {
    return _then(
      _value.copyWith(
            hallId: null == hallId
                ? _value.hallId
                : hallId // ignore: cast_nullable_to_non_nullable
                      as String,
            hallName: null == hallName
                ? _value.hallName
                : hallName // ignore: cast_nullable_to_non_nullable
                      as String,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
            bookingCount: null == bookingCount
                ? _value.bookingCount
                : bookingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EarningEntryImplCopyWith<$Res>
    implements $EarningEntryCopyWith<$Res> {
  factory _$$EarningEntryImplCopyWith(
    _$EarningEntryImpl value,
    $Res Function(_$EarningEntryImpl) then,
  ) = __$$EarningEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String hallId,
    String hallName,
    double revenue,
    int bookingCount,
    DateTime date,
  });
}

/// @nodoc
class __$$EarningEntryImplCopyWithImpl<$Res>
    extends _$EarningEntryCopyWithImpl<$Res, _$EarningEntryImpl>
    implements _$$EarningEntryImplCopyWith<$Res> {
  __$$EarningEntryImplCopyWithImpl(
    _$EarningEntryImpl _value,
    $Res Function(_$EarningEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EarningEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hallId = null,
    Object? hallName = null,
    Object? revenue = null,
    Object? bookingCount = null,
    Object? date = null,
  }) {
    return _then(
      _$EarningEntryImpl(
        hallId: null == hallId
            ? _value.hallId
            : hallId // ignore: cast_nullable_to_non_nullable
                  as String,
        hallName: null == hallName
            ? _value.hallName
            : hallName // ignore: cast_nullable_to_non_nullable
                  as String,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
        bookingCount: null == bookingCount
            ? _value.bookingCount
            : bookingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EarningEntryImpl implements _EarningEntry {
  const _$EarningEntryImpl({
    required this.hallId,
    required this.hallName,
    required this.revenue,
    required this.bookingCount,
    required this.date,
  });

  factory _$EarningEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$EarningEntryImplFromJson(json);

  @override
  final String hallId;
  @override
  final String hallName;
  @override
  final double revenue;
  @override
  final int bookingCount;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'EarningEntry(hallId: $hallId, hallName: $hallName, revenue: $revenue, bookingCount: $bookingCount, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarningEntryImpl &&
            (identical(other.hallId, hallId) || other.hallId == hallId) &&
            (identical(other.hallName, hallName) ||
                other.hallName == hallName) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.bookingCount, bookingCount) ||
                other.bookingCount == bookingCount) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, hallId, hallName, revenue, bookingCount, date);

  /// Create a copy of EarningEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EarningEntryImplCopyWith<_$EarningEntryImpl> get copyWith =>
      __$$EarningEntryImplCopyWithImpl<_$EarningEntryImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String hallId,
      String hallName,
      double revenue,
      int bookingCount,
      DateTime date,
    )
    $default,
  ) {
    return $default(hallId, hallName, revenue, bookingCount, date);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String hallId,
      String hallName,
      double revenue,
      int bookingCount,
      DateTime date,
    )?
    $default,
  ) {
    return $default?.call(hallId, hallName, revenue, bookingCount, date);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String hallId,
      String hallName,
      double revenue,
      int bookingCount,
      DateTime date,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(hallId, hallName, revenue, bookingCount, date);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_EarningEntry value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_EarningEntry value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_EarningEntry value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EarningEntryImplToJson(this);
  }
}

abstract class _EarningEntry implements EarningEntry {
  const factory _EarningEntry({
    required final String hallId,
    required final String hallName,
    required final double revenue,
    required final int bookingCount,
    required final DateTime date,
  }) = _$EarningEntryImpl;

  factory _EarningEntry.fromJson(Map<String, dynamic> json) =
      _$EarningEntryImpl.fromJson;

  @override
  String get hallId;
  @override
  String get hallName;
  @override
  double get revenue;
  @override
  int get bookingCount;
  @override
  DateTime get date;

  /// Create a copy of EarningEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EarningEntryImplCopyWith<_$EarningEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EarningsReport _$EarningsReportFromJson(Map<String, dynamic> json) {
  return _EarningsReport.fromJson(json);
}

/// @nodoc
mixin _$EarningsReport {
  double get grossRevenue => throw _privateConstructorUsedError;
  double get commissionAmount => throw _privateConstructorUsedError;
  double get netEarnings => throw _privateConstructorUsedError;
  double get commissionPercentage => throw _privateConstructorUsedError;
  List<EarningEntry> get entries => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      double grossRevenue,
      double commissionAmount,
      double netEarnings,
      double commissionPercentage,
      List<EarningEntry> entries,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      double grossRevenue,
      double commissionAmount,
      double netEarnings,
      double commissionPercentage,
      List<EarningEntry> entries,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      double grossRevenue,
      double commissionAmount,
      double netEarnings,
      double commissionPercentage,
      List<EarningEntry> entries,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_EarningsReport value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_EarningsReport value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_EarningsReport value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this EarningsReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EarningsReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EarningsReportCopyWith<EarningsReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EarningsReportCopyWith<$Res> {
  factory $EarningsReportCopyWith(
    EarningsReport value,
    $Res Function(EarningsReport) then,
  ) = _$EarningsReportCopyWithImpl<$Res, EarningsReport>;
  @useResult
  $Res call({
    double grossRevenue,
    double commissionAmount,
    double netEarnings,
    double commissionPercentage,
    List<EarningEntry> entries,
  });
}

/// @nodoc
class _$EarningsReportCopyWithImpl<$Res, $Val extends EarningsReport>
    implements $EarningsReportCopyWith<$Res> {
  _$EarningsReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EarningsReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grossRevenue = null,
    Object? commissionAmount = null,
    Object? netEarnings = null,
    Object? commissionPercentage = null,
    Object? entries = null,
  }) {
    return _then(
      _value.copyWith(
            grossRevenue: null == grossRevenue
                ? _value.grossRevenue
                : grossRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            commissionAmount: null == commissionAmount
                ? _value.commissionAmount
                : commissionAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            netEarnings: null == netEarnings
                ? _value.netEarnings
                : netEarnings // ignore: cast_nullable_to_non_nullable
                      as double,
            commissionPercentage: null == commissionPercentage
                ? _value.commissionPercentage
                : commissionPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<EarningEntry>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EarningsReportImplCopyWith<$Res>
    implements $EarningsReportCopyWith<$Res> {
  factory _$$EarningsReportImplCopyWith(
    _$EarningsReportImpl value,
    $Res Function(_$EarningsReportImpl) then,
  ) = __$$EarningsReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double grossRevenue,
    double commissionAmount,
    double netEarnings,
    double commissionPercentage,
    List<EarningEntry> entries,
  });
}

/// @nodoc
class __$$EarningsReportImplCopyWithImpl<$Res>
    extends _$EarningsReportCopyWithImpl<$Res, _$EarningsReportImpl>
    implements _$$EarningsReportImplCopyWith<$Res> {
  __$$EarningsReportImplCopyWithImpl(
    _$EarningsReportImpl _value,
    $Res Function(_$EarningsReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EarningsReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grossRevenue = null,
    Object? commissionAmount = null,
    Object? netEarnings = null,
    Object? commissionPercentage = null,
    Object? entries = null,
  }) {
    return _then(
      _$EarningsReportImpl(
        grossRevenue: null == grossRevenue
            ? _value.grossRevenue
            : grossRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        commissionAmount: null == commissionAmount
            ? _value.commissionAmount
            : commissionAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        netEarnings: null == netEarnings
            ? _value.netEarnings
            : netEarnings // ignore: cast_nullable_to_non_nullable
                  as double,
        commissionPercentage: null == commissionPercentage
            ? _value.commissionPercentage
            : commissionPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<EarningEntry>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EarningsReportImpl implements _EarningsReport {
  const _$EarningsReportImpl({
    required this.grossRevenue,
    required this.commissionAmount,
    required this.netEarnings,
    required this.commissionPercentage,
    required final List<EarningEntry> entries,
  }) : _entries = entries;

  factory _$EarningsReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$EarningsReportImplFromJson(json);

  @override
  final double grossRevenue;
  @override
  final double commissionAmount;
  @override
  final double netEarnings;
  @override
  final double commissionPercentage;
  final List<EarningEntry> _entries;
  @override
  List<EarningEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  String toString() {
    return 'EarningsReport(grossRevenue: $grossRevenue, commissionAmount: $commissionAmount, netEarnings: $netEarnings, commissionPercentage: $commissionPercentage, entries: $entries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarningsReportImpl &&
            (identical(other.grossRevenue, grossRevenue) ||
                other.grossRevenue == grossRevenue) &&
            (identical(other.commissionAmount, commissionAmount) ||
                other.commissionAmount == commissionAmount) &&
            (identical(other.netEarnings, netEarnings) ||
                other.netEarnings == netEarnings) &&
            (identical(other.commissionPercentage, commissionPercentage) ||
                other.commissionPercentage == commissionPercentage) &&
            const DeepCollectionEquality().equals(other._entries, _entries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    grossRevenue,
    commissionAmount,
    netEarnings,
    commissionPercentage,
    const DeepCollectionEquality().hash(_entries),
  );

  /// Create a copy of EarningsReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EarningsReportImplCopyWith<_$EarningsReportImpl> get copyWith =>
      __$$EarningsReportImplCopyWithImpl<_$EarningsReportImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      double grossRevenue,
      double commissionAmount,
      double netEarnings,
      double commissionPercentage,
      List<EarningEntry> entries,
    )
    $default,
  ) {
    return $default(
      grossRevenue,
      commissionAmount,
      netEarnings,
      commissionPercentage,
      entries,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      double grossRevenue,
      double commissionAmount,
      double netEarnings,
      double commissionPercentage,
      List<EarningEntry> entries,
    )?
    $default,
  ) {
    return $default?.call(
      grossRevenue,
      commissionAmount,
      netEarnings,
      commissionPercentage,
      entries,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      double grossRevenue,
      double commissionAmount,
      double netEarnings,
      double commissionPercentage,
      List<EarningEntry> entries,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
        grossRevenue,
        commissionAmount,
        netEarnings,
        commissionPercentage,
        entries,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_EarningsReport value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_EarningsReport value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_EarningsReport value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EarningsReportImplToJson(this);
  }
}

abstract class _EarningsReport implements EarningsReport {
  const factory _EarningsReport({
    required final double grossRevenue,
    required final double commissionAmount,
    required final double netEarnings,
    required final double commissionPercentage,
    required final List<EarningEntry> entries,
  }) = _$EarningsReportImpl;

  factory _EarningsReport.fromJson(Map<String, dynamic> json) =
      _$EarningsReportImpl.fromJson;

  @override
  double get grossRevenue;
  @override
  double get commissionAmount;
  @override
  double get netEarnings;
  @override
  double get commissionPercentage;
  @override
  List<EarningEntry> get entries;

  /// Create a copy of EarningsReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EarningsReportImplCopyWith<_$EarningsReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
