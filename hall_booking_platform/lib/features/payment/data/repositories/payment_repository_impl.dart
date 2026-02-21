import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:hall_booking_platform/features/payment/domain/entities/payment.dart';
import 'package:hall_booking_platform/features/payment/domain/repositories/payment_repository.dart';

/// Implementation of [PaymentRepository] backed by Supabase Edge Functions.
class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._dataSource);

  final PaymentRemoteDataSource _dataSource;

  /// Creates a Razorpay order via the `create-order` Edge Function.
  ///
  /// Returns the Razorpay order ID on success.
  /// Requirement: 5.1
  @override
  Future<Either<Failure, String>> createRazorpayOrder({
    required String bookingId,
    required double amount,
  }) async {
    try {
      final response = await _dataSource.createOrder(
        bookingId: bookingId,
        amount: amount,
      );

      final orderId = response['order_id'] as String?;
      if (orderId == null || orderId.isEmpty) {
        return const Left(
          Failure.server(message: 'No order ID returned from server.'),
        );
      }

      return Right(orderId);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Verifies a Razorpay payment via the verify-payment Edge Function.
  ///
  /// On success, returns a [Payment] entity with status "completed".
  /// On failure (invalid signature), returns a [Failure].
  @override
  Future<Either<Failure, Payment>> verifyPayment({
    required String bookingId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _dataSource.verifyPayment(
        bookingId: bookingId,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );

      // Build a Payment entity from the successful verification response.
      final payment = Payment(
        id: response['payment_id'] as String? ?? '',
        bookingId: bookingId,
        razorpayPaymentId: razorpayPaymentId,
        status: response['payment_status'] as String? ?? 'completed',
        amount: 0, // Amount is stored server-side; not returned in response.
      );

      return Right(payment);
    } on PaymentVerificationException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}

/// Riverpod provider for [PaymentRepositoryImpl].
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(paymentRemoteDataSourceProvider));
});
