import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/booking/presentation/providers/booking_providers.dart';
import 'package:intl/intl.dart';

/// Detail screen for a single booking showing full info and cancel button.
/// Cancel button is only visible if booking is >= 24hrs away and not
/// already cancelled/completed. Requirements: 6.2, 6.3, 6.4, 19.2, 19.4.
class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: bookingState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorDisplay(
          message: 'Failed to load booking details.',
          onRetry: () => ref.invalidate(bookingDetailProvider(bookingId)),
        ),
        data: (booking) => _BookingDetailBody(
          booking: booking,
          bookingId: bookingId,
        ),
      ),
    );
  }
}

class _BookingDetailBody extends ConsumerWidget {
  const _BookingDetailBody({
    required this.booking,
    required this.bookingId,
  });

  final Booking booking;
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancellationState = ref.watch(bookingCancellationProvider);
    final canCancel = _canCancelBooking(booking);

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          _StatusBanner(status: booking.bookingStatus),
          const SizedBox(height: AppSpacing.lg),

          // Hall info
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
                  Text('Hall', style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    booking.hall?.name ?? 'N/A',
                    style: AppTypography.headlineSmall,
                  ),
                  if (booking.hall?.address != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(booking.hall!.address,
                              style: AppTypography.bodyMedium),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Slot info
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
                  Text('Slot Details', style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.sm),
                  if (booking.slot != null) ...[
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: DateFormat('EEE, MMM d, yyyy')
                          .format(booking.slot!.date),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value:
                          '${booking.slot!.startTime} – ${booking.slot!.endTime}',
                    ),
                  ] else
                    Text('Slot details unavailable',
                        style: AppTypography.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // User details (Owner perspective typically, though users might see their own info)
          if (booking.user != null) ...[
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
                    Text('User Details', style: AppTypography.caption),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(
                      icon: Icons.person,
                      label: 'Name',
                      value: booking.user!.name,
                    ),
                    if (booking.user!.phone != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _DetailRow(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: booking.user!.phone!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Payment info
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
                  Text('Payment', style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.sm),
                  _DetailRow(
                    icon: Icons.payment,
                    label: 'Amount',
                    value: '₹${booking.totalPrice.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DetailRow(
                    icon: Icons.receipt_long,
                    label: 'Payment Status',
                    value: booking.paymentStatus.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Booking meta
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
                  Text('Booking Info', style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.sm),
                  _DetailRow(
                    icon: Icons.confirmation_number,
                    label: 'Booking ID',
                    value: booking.id.length > 8
                        ? '${booking.id.substring(0, 8)}...'
                        : booking.id,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DetailRow(
                    icon: Icons.schedule,
                    label: 'Created',
                    value: DateFormat('MMM d, yyyy – HH:mm')
                        .format(booking.createdAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Error message from cancellation
          if (cancellationState.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                cancellationState.error!,
                style:
                    AppTypography.bodyMedium.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Cancel button (conditionally visible)
          if (canCancel)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: cancellationState.isLoading
                    ? null
                    : () => _onCancel(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: cancellationState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    : const Text('Cancel Booking',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// Determines if the booking can be cancelled:
  /// - Not already cancelled or completed
  /// - Slot start time is >= 24 hours from now
  bool _canCancelBooking(Booking booking) {
    if (booking.bookingStatus == 'cancelled' ||
        booking.bookingStatus == 'completed') {
      return false;
    }

    if (booking.slot == null) return false;

    final slotDateTime = _buildSlotDateTime(
      booking.slot!.date,
      booking.slot!.startTime,
    );
    final hoursUntilSlot = slotDateTime.difference(DateTime.now()).inHours;

    return hoursUntilSlot >= AppConstants.cancellationWindowHours;
  }

  DateTime _buildSlotDateTime(DateTime date, String startTime) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future<void> _onCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(bookingCancellationProvider.notifier)
          .cancelBooking(bookingId);

      if (success && context.mounted) {
        // Refresh the booking detail
        ref.invalidate(bookingDetailProvider(bookingId));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

/// Banner showing the current booking status.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      'pending' => (AppColors.warning, Icons.hourglass_empty, 'Pending'),
      'confirmed' => (AppColors.success, Icons.check_circle, 'Confirmed'),
      'cancelled' => (AppColors.error, Icons.cancel, 'Cancelled'),
      'completed' => (AppColors.info, Icons.task_alt, 'Completed'),
      _ => (AppColors.textSecondary, Icons.info, status),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.headlineSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Row showing an icon, label, and value.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTypography.bodyMedium),
        const Spacer(),
        Text(value, style: AppTypography.titleMedium),
      ],
    );
  }
}
