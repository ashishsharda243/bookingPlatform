import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/features/booking/presentation/providers/booking_flow_coordinator.dart';
import 'package:hall_booking_platform/features/payment/presentation/providers/payment_providers.dart';
import 'package:hall_booking_platform/services/razorpay_service.dart';

/// Parameters passed to [PaymentScreen] via GoRouter extra.
class PaymentScreenParams {
  const PaymentScreenParams({
    required this.bookingId,
    required this.orderId,
    required this.amount,
    this.contact,
    this.email,
  });

  /// Internal booking ID for reconciliation.
  final String bookingId;

  /// Razorpay order ID created server-side.
  final String orderId;

  /// Amount in INR (rupees). Converted to paise for Razorpay.
  final double amount;

  /// Optional phone number to prefill in Razorpay checkout.
  final String? contact;

  /// Optional email to prefill in Razorpay checkout.
  final String? email;
}

/// Payment screen integrating Razorpay checkout with server-side verification.
///
/// Flow: opens Razorpay checkout → listens to paymentResults stream →
/// on success calls verify-payment Edge Function → shows success/failure.
///
/// Requirements: 5.1, 5.2, 5.3, 5.4.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.params});

  final PaymentScreenParams params;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  StreamSubscription<PaymentResult>? _paymentSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to Razorpay payment results and open checkout after build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToPaymentResults();
      _openCheckout();
    });
  }

  @override
  void dispose() {
    _paymentSubscription?.cancel();
    super.dispose();
  }

  void _listenToPaymentResults() {
    final razorpayService = ref.read(razorpayServiceProvider);
    _paymentSubscription = razorpayService.paymentResults.listen(
      (result) {
        switch (result) {
          case PaymentSuccess():
            _onPaymentSuccess(result);
          case PaymentFailure():
            _onPaymentFailure(result);
          case PaymentExternalWallet():
            // External wallet selected — treat as processing.
            break;
        }
      },
    );
  }

  void _openCheckout() {
    final razorpayService = ref.read(razorpayServiceProvider);
    final notifier = ref.read(paymentNotifierProvider.notifier);

    notifier.startProcessing();

    razorpayService.openCheckout(
      orderId: widget.params.orderId,
      amount: (widget.params.amount * 100).toInt(), // Convert to paise
      bookingId: widget.params.bookingId,
      prefillContact: widget.params.contact,
      prefillEmail: widget.params.email,
    );
  }

  Future<void> _onPaymentSuccess(PaymentSuccess result) async {
    await ref.read(paymentNotifierProvider.notifier).verifyPayment(
          bookingId: widget.params.bookingId,
          razorpayPaymentId: result.paymentId,
          razorpayOrderId: result.orderId,
          razorpaySignature: result.signature,
        );

    // Notify the flow coordinator so it can trigger FCM token refresh
    // and mark the flow as completed. The actual notification is sent
    // server-side by the verify-payment Edge Function (Requirement 8.1).
    final paymentState = ref.read(paymentNotifierProvider);
    if (paymentState.status == PaymentStatus.success) {
      ref.read(bookingFlowCoordinatorProvider.notifier).onPaymentVerified();
    }
  }

  void _onPaymentFailure(PaymentFailure result) {
    ref
        .read(paymentNotifierProvider.notifier)
        .onPaymentFailed(result.message);

    // Notify the flow coordinator about the failure.
    ref
        .read(bookingFlowCoordinatorProvider.notifier)
        .onPaymentFailed(result.message);
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        automaticallyImplyLeading:
            paymentState.status != PaymentStatus.processing &&
                paymentState.status != PaymentStatus.verifying,
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: _buildBody(paymentState),
      ),
    );
  }

  Widget _buildBody(PaymentState state) {
    return switch (state.status) {
      PaymentStatus.idle || PaymentStatus.processing => _buildProcessing(),
      PaymentStatus.verifying => _buildVerifying(),
      PaymentStatus.success => _buildSuccess(),
      PaymentStatus.failed => _buildFailure(state.errorMessage),
    };
  }

  Widget _buildProcessing() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Opening Razorpay checkout...',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '₹${widget.params.amount.toStringAsFixed(2)}',
            style: AppTypography.headlineMedium
                .copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifying() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Verifying payment...',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Please wait while we confirm your payment.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Payment Successful!',
            style: AppTypography.headlineMedium
                .copyWith(color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your booking has been confirmed.',
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () =>
                  context.go('/bookings/${widget.params.bookingId}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('View Booking',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildFailure(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Payment Failed',
            style: AppTypography.headlineMedium
                .copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorMessage ?? 'Something went wrong. Please try again.',
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ref.read(paymentNotifierProvider.notifier).reset();
                _openCheckout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('Retry Payment',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.go('/bookings'),
            child: const Text('View Bookings'),
          ),
        ],
      ),
    );
  }
}
