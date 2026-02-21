// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      if (instance.razorpayPaymentId case final value?)
        'razorpay_payment_id': value,
      'status': instance.status,
      'amount': instance.amount,
    };
