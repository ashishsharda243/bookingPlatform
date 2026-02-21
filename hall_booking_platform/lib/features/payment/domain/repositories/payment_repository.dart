import 'package:dartz/dartz.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/payment/domain/entities/payment.dart';

abstract class PaymentRepository {
  Future<Either<Failure, String>> createRazorpayOrder({
    required String bookingId,
    required double amount,
  });

  Future<Either<Failure, Payment>> verifyPayment({
    required String bookingId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });
}
