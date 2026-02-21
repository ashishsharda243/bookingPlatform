import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Razorpay key provided via --dart-define=RAZORPAY_KEY_ID=your-key-id
const razorpayKeyId = String.fromEnvironment('RAZORPAY_KEY_ID');

/// Represents the result of a Razorpay payment attempt.
sealed class PaymentResult {}

/// Payment completed successfully.
class PaymentSuccess extends PaymentResult {
  PaymentSuccess({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  final String paymentId;
  final String orderId;
  final String signature;
}

/// Payment failed.
class PaymentFailure extends PaymentResult {
  PaymentFailure({
    required this.code,
    required this.message,
  });

  final int code;
  final String message;
}

/// User chose an external wallet (e.g. Paytm, PhonePe).
class PaymentExternalWallet extends PaymentResult {
  PaymentExternalWallet({required this.walletName});

  final String walletName;
}

/// Service wrapping the razorpay_flutter plugin.
///
/// Provides a stream-based API for payment results and a method
/// to open the Razorpay checkout with order details.
class RazorpayService {
  /// Creates a [RazorpayService].
  ///
  /// Accepts an optional [Razorpay] instance for testing.
  /// If not provided, a new instance is created.
  RazorpayService({Razorpay? razorpay}) : _razorpay = razorpay ?? Razorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  final Razorpay _razorpay;
  final _resultController = StreamController<PaymentResult>.broadcast();

  /// Stream of payment results. Listen to this to handle
  /// success, failure, and external wallet events.
  Stream<PaymentResult> get paymentResults => _resultController.stream;

  /// Opens the Razorpay checkout UI.
  ///
  /// [orderId] – Razorpay order ID created on the server.
  /// [amount] – Amount in paise (INR smallest unit). e.g. ₹500 = 50000.
  /// [bookingId] – Internal booking ID stored in notes for reconciliation.
  /// [description] – Description shown on the checkout screen.
  /// [prefillContact] – Optional phone number to prefill.
  /// [prefillEmail] – Optional email to prefill.
  void openCheckout({
    required String orderId,
    required int amount,
    required String bookingId,
    String description = 'Hall Booking Payment',
    String? prefillContact,
    String? prefillEmail,
  }) {
    assert(
      razorpayKeyId.isNotEmpty,
      'RAZORPAY_KEY_ID must be provided via --dart-define',
    );

    final options = <String, dynamic>{
      'key': razorpayKeyId,
      'amount': amount,
      'order_id': orderId,
      'name': 'Hall Booking Platform',
      'description': description,
      'notes': {'booking_id': bookingId},
      'prefill': {
        if (prefillContact != null) 'contact': prefillContact,
        if (prefillEmail != null) 'email': prefillEmail,
      },
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _resultController.add(
      PaymentSuccess(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _resultController.add(
      PaymentFailure(
        code: response.code ?? 0,
        message: response.message ?? 'Payment failed',
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _resultController.add(
      PaymentExternalWallet(
        walletName: response.walletName ?? '',
      ),
    );
  }

  /// Disposes the Razorpay instance and closes the stream.
  /// Call this when the service is no longer needed.
  void dispose() {
    _razorpay.clear();
    _resultController.close();
  }
}

/// Riverpod provider for the RazorpayService.
/// The service is created once and disposed when the provider is disposed.
final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  final service = RazorpayService();
  ref.onDispose(service.dispose);
  return service;
});
