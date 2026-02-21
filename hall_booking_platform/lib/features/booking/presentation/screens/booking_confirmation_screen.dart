import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/features/booking/presentation/providers/booking_flow_coordinator.dart';
import 'package:hall_booking_platform/features/booking/presentation/screens/slot_selection_screen.dart';
import 'package:hall_booking_platform/features/payment/presentation/screens/payment_screen.dart';

/// Confirmation screen showing hall, slot, and price summary before booking.
/// On confirm: creates booking → creates Razorpay order → navigates to PaymentScreen.
/// Requirements: 4.3, 4.6, 5.1, 19.2.
class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key, required this.params});

  final BookingConfirmationParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowCoordinatorProvider);
    final isLoading = flowState.phase == BookingFlowPhase.creatingOrder;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking summary card
            Card(
              elevation: AppSpacing.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking Summary',
                        style: AppTypography.headlineSmall),
                    const SizedBox(height: AppSpacing.md),
                    _SummaryRow(label: 'Hall', value: params.hallName),
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryRow(label: 'Date', value: params.slotDate),
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryRow(label: 'Time', value: params.slotInfo),
                    const Divider(height: AppSpacing.lg),
                    _SummaryRow(
                      label: 'Total Price',
                      value: '₹${params.price.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Error message
            if (flowState.phase == BookingFlowPhase.error &&
                flowState.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  flowState.errorMessage!,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Confirm & Pay button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _onConfirmAndPay(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Confirm & Pay',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  /// Creates the booking, then creates a Razorpay order, then navigates
  /// to PaymentScreen with the order details.
  ///
  /// Requirements: 4.3, 5.1
  Future<void> _onConfirmAndPay(BuildContext context, WidgetRef ref) async {
    final coordinator =
        ref.read(bookingFlowCoordinatorProvider.notifier);

    final orderId = await coordinator.confirmBookingAndCreateOrder(
      hallId: params.hallId,
      slotId: params.slotId,
    );

    if (!context.mounted) return;

    if (orderId != null) {
      if (orderId == 'skipped_payment') {
        context.go('/booking/success');
        return;
      }
      
      final flowState = ref.read(bookingFlowCoordinatorProvider);
      final booking = flowState.booking!;

      context.push(
        '/booking/payment',
        extra: PaymentScreenParams(
          bookingId: booking.id,
          orderId: orderId,
          amount: booking.totalPrice,
        ),
      );
    }
    // If orderId is null, the coordinator already set the error state
    // which is displayed by the error container above.
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold ? AppTypography.titleMedium : AppTypography.bodyMedium,
        ),
        Text(
          value,
          style: isBold
              ? AppTypography.headlineSmall.copyWith(color: AppColors.primary)
              : AppTypography.titleMedium,
        ),
      ],
    );
  }
}
