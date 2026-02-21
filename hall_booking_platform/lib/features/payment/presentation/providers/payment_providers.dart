import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:hall_booking_platform/features/payment/domain/entities/payment.dart';
import 'package:hall_booking_platform/features/payment/domain/repositories/payment_repository.dart';

/// Possible states of the payment flow.
enum PaymentStatus {
  /// Initial state — waiting for Razorpay checkout to open.
  idle,

  /// Razorpay checkout is open, waiting for user action.
  processing,

  /// Razorpay returned success, now verifying signature server-side.
  verifying,

  /// Payment verified and booking confirmed.
  success,

  /// Payment failed (Razorpay error or signature verification failure).
  failed,
}

/// State for the payment flow.
class PaymentState {
  const PaymentState({
    this.status = PaymentStatus.idle,
    this.payment,
    this.errorMessage,
  });

  final PaymentStatus status;
  final Payment? payment;
  final String? errorMessage;

  PaymentState copyWith({
    PaymentStatus? status,
    Payment? payment,
    String? errorMessage,
    bool clearError = false,
    bool clearPayment = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      payment: clearPayment ? null : (payment ?? this.payment),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier managing the payment flow lifecycle:
/// idle → processing → verifying → success / failed.
class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier(this._repository) : super(const PaymentState());

  final PaymentRepository _repository;

  /// Marks the payment as processing (Razorpay checkout opened).
  void startProcessing() {
    state = state.copyWith(
      status: PaymentStatus.processing,
      clearError: true,
    );
  }

  /// Called when Razorpay returns a successful payment.
  /// Verifies the signature server-side via the Edge Function.
  Future<void> verifyPayment({
    required String bookingId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    state = state.copyWith(status: PaymentStatus.verifying, clearError: true);

    final result = await _repository.verifyPayment(
      bookingId: bookingId,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      razorpaySignature: razorpaySignature,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: failure.message,
        );
      },
      (payment) {
        state = state.copyWith(
          status: PaymentStatus.success,
          payment: payment,
        );
      },
    );
  }

  /// Called when Razorpay returns a payment failure.
  void onPaymentFailed(String message) {
    state = state.copyWith(
      status: PaymentStatus.failed,
      errorMessage: message,
    );
  }

  /// Resets the payment state to idle.
  void reset() {
    state = const PaymentState();
  }
}

/// Riverpod provider for [PaymentNotifier].
final paymentNotifierProvider =
    StateNotifierProvider.autoDispose<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref.watch(paymentRepositoryProvider));
});
