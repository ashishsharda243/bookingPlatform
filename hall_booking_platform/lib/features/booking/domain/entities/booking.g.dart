// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingImpl _$$BookingImplFromJson(Map<String, dynamic> json) =>
    _$BookingImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      hallId: json['hall_id'] as String,
      slotId: json['slot_id'] as String,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String,
      bookingStatus: json['booking_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      hall: json['hall'] == null
          ? null
          : Hall.fromJson(json['hall'] as Map<String, dynamic>),
      slot: json['slot'] == null
          ? null
          : Slot.fromJson(json['slot'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BookingImplToJson(_$BookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'hall_id': instance.hallId,
      'slot_id': instance.slotId,
      'total_price': instance.totalPrice,
      'payment_status': instance.paymentStatus,
      'booking_status': instance.bookingStatus,
      'created_at': instance.createdAt.toIso8601String(),
      if (instance.hall?.toJson() case final value?) 'hall': value,
      if (instance.slot?.toJson() case final value?) 'slot': value,
      if (instance.user?.toJson() case final value?) 'user': value,
    };
