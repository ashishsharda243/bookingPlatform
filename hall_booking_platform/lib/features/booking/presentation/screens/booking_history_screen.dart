import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/empty_state_widget.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/auth/presentation/providers/auth_notifier.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/booking/presentation/providers/booking_providers.dart';
import 'package:intl/intl.dart';

/// Displays the user's booking history with infinite scroll pagination.
/// Sorted newest first. Requirements: 6.1, 19.2, 19.3.
class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial bookings after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingHistoryProvider.notifier).loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(bookingHistoryProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingMore) {
        notifier.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(bookingHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _buildBody(ref, bookingsState),
    );
  }

  Widget _buildBody(WidgetRef ref, AsyncValue<List<Booking>> bookingsState) {
    final authState = ref.watch(authNotifierProvider);
    if (!authState.isAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Please login to view your bookings',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return bookingsState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorDisplay(
          message: 'Failed to load bookings.',
          onRetry: () =>
              ref.read(bookingHistoryProvider.notifier).loadInitial(),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const EmptyStateWidget(
              message: 'No bookings yet.',
              icon: Icons.calendar_today_outlined,
            );
          }

          final notifier = ref.read(bookingHistoryProvider.notifier);

          return ListView.separated(
            controller: _scrollController,
            padding: AppSpacing.screenPadding,
            itemCount: bookings.length + (notifier.hasMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index >= bookings.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return _BookingCard(booking: bookings[index]);
            },
          );
        },
      );
    }
}

/// Card displaying a single booking in the history list.
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final hallName = booking.hall?.name ?? 'Hall';
    final slotDate = booking.slot != null
        ? DateFormat('EEE, MMM d, yyyy').format(booking.slot!.date)
        : '';
    final slotTime = booking.slot != null
        ? '${booking.slot!.startTime} – ${booking.slot!.endTime}'
        : '';

    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: () => context.push('/bookings/${booking.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(hallName,
                        style: AppTypography.titleLarge,
                        overflow: TextOverflow.ellipsis),
                  ),
                  _StatusChip(status: booking.bookingStatus),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (slotDate.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(slotDate, style: AppTypography.bodyMedium),
                  ],
                ),
              if (slotTime.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(slotTime, style: AppTypography.bodyMedium),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                '₹${booking.totalPrice.toStringAsFixed(2)}',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip showing the booking status with appropriate color.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'pending' => (AppColors.warning, 'Pending'),
      'confirmed' => (AppColors.success, 'Confirmed'),
      'cancelled' => (AppColors.error, 'Cancelled'),
      'completed' => (AppColors.info, 'Completed'),
      _ => (AppColors.textSecondary, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
