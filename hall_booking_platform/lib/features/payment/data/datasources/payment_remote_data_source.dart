import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentVerificationException implements Exception {
  final String message;
  PaymentVerificationException(this.message);
}

class PaymentRemoteDataSource {
  final SupabaseClient _client;
  PaymentRemoteDataSource(this._client);

  Future<Map<String, dynamic>> createOrder({
    required String bookingId,
    required double amount,
  }) async {
    final response = await _client.functions.invoke(
      'create-order',
      body: {'booking_id': bookingId, 'amount': amount},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String bookingId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    final response = await _client.functions.invoke(
      'verify-payment',
      body: {
        'booking_id': bookingId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': razorpaySignature,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  return PaymentRemoteDataSource(ref.watch(supabaseClientProvider));
});
