import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/empty_state_widget.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/owner/presentation/providers/owner_providers.dart';
import 'package:intl/intl.dart';

/// Screen displaying all bookings for halls owned by the current user.
///
/// Bookings are sorted by date (newest first) with pagination support.
/// Requirement 12.1: Display all bookings for halls owned by the Hall_Owner.
class OwnerBookingsScreen extends ConsumerStatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  ConsumerState<OwnerBookingsScreen> createState() =>
      _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends ConsumerState<OwnerBookingsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ownerBookingsNotifierProvider.notifier).loadBookings();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(ownerBookingsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownerBookingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(ownerBookingsNotifierProvider.notifier).loadBookings();
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(OwnerBookingsState state) {
    if (state.isLoading && state.bookings.isEmpty) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.bookings.isEmpty) {
      return ErrorDisplay(
        message: state.error!,
        onRetry: () {
          ref.read(ownerBookingsNotifierProvider.notifier).loadBookings();
        },
      );
    }

    if (state.bookings.isEmpty) {
      return const EmptyStateWidget(
        message: 'No bookings yet.\nBookings for your halls will appear here.',
        icon: Icons.calendar_today_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(ownerBookingsNotifierProvider.notifier).loadBookings();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: AppSpacing.screenPadding,
        itemCount: state.bookings.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == state.bookings.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _BookingCard(booking: state.bookings[index]);
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final hallName = booking.hall?.name ?? 'Hall';

    final (statusColor, statusLabel) = switch (booking.bookingStatus) {
      'confirmed' => (AppColors.success, 'Confirmed'),
      'cancelled' => (AppColors.error, 'Cancelled'),
      'completed' => (AppColors.info, 'Completed'),
      _ => (AppColors.warning, 'Pending'),
    };

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: () => context.push('/bookings/${booking.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Details Section
              if (booking.user != null) ...[
                Row(
                  children: [
                    const Icon(Icons.person,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        booking.user!.name,
                        style: AppTypography.titleLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (booking.user!.phone != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.phone,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        booking.user!.phone!,
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ],
                const Divider(height: AppSpacing.xl),
              ] else ...[
                // Fallback if user data is missing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Booking Status', style: AppTypography.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
              ],
              // Hall Details
              Row(
                children: [
                  const Icon(Icons.meeting_room,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      hallName,
                      style: AppTypography.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    dateFormat.format(booking.createdAt),
                    style: AppTypography.bodySmall,
                  ),
                  if (booking.slot != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${booking.slot!.startTime} - ${booking.slot!.endTime}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${booking.totalPrice.toStringAsFixed(0)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Payment: ${booking.paymentStatus}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
              if (booking.bookingStatus == 'pending') ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showRejectDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAcceptDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ] else if (booking.bookingStatus == 'confirmed') ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Cancel Booking'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAcceptDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Booking'),
        content: const Text('Are you sure you want to accept this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final notifier = ProviderScope.containerOf(context)
          .read(ownerBookingsNotifierProvider.notifier);
      await notifier.acceptBooking(booking.id);
    }
  }

  Future<void> _showRejectDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: const Text(
            'Are you sure you want to reject this booking? The slot will be released.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      if (booking.slotId.isEmpty) return;
      final notifier = ProviderScope.containerOf(context)
          .read(ownerBookingsNotifierProvider.notifier);
      await notifier.rejectBooking(booking.id, booking.slotId);
    }
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
            'Are you sure you want to cancel this confirmed booking? The slot will be released.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      if (booking.slotId.isEmpty) return;
      final notifier = ProviderScope.containerOf(context)
          .read(ownerBookingsNotifierProvider.notifier);
      await notifier.cancelBooking(booking.id, booking.slotId);
    }
  }
}
