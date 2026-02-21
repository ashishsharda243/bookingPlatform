import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/empty_state_widget.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/slot.dart';
import 'package:hall_booking_platform/features/booking/presentation/providers/booking_providers.dart';
import 'package:hall_booking_platform/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:intl/intl.dart';

/// Screen for selecting a time slot for a hall.
/// Displays a date picker and a grid of slots with visual status indicators.
/// Requirements: 4.1, 4.2, 19.2.
class SlotSelectionScreen extends ConsumerWidget {
  const SlotSelectionScreen({super.key, required this.hallId});

  final String hallId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallState = ref.watch(hallDetailProvider(hallId));
    final hallName = hallState.whenOrNull(data: (hall) => hall.name) ?? 'Select Slot';

    return Scaffold(
      appBar: AppBar(title: Text(hallName)),
      body: Column(
        children: [
          _DatePickerBar(hallId: hallId),
          const Divider(height: 1),
          Expanded(child: _SlotGrid(hallId: hallId)),
        ],
      ),
    );
  }
}

/// Horizontal date picker allowing the user to select a date.
class _DatePickerBar extends ConsumerWidget {
  const _DatePickerBar({required this.hallId});

  final String hallId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateTime.now();
    final dates = List.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day).add(Duration(days: i)),
    );

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = date;
              ref.invalidate(slotsProvider(hallId));
            },
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${date.day}',
                    style: AppTypography.headlineSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date),
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Grid of time slots with visual status indicators.
class _SlotGrid extends ConsumerWidget {
  const _SlotGrid({required this.hallId});

  final String hallId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsState = ref.watch(slotsProvider(hallId));

    return slotsState.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorDisplay(
        message: 'Failed to load slots.',
        onRetry: () => ref.invalidate(slotsProvider(hallId)),
      ),
      data: (slots) {
        if (slots.isEmpty) {
          return const EmptyStateWidget(
            message: 'No slots available for this date.',
            icon: Icons.event_busy,
          );
        }

        return GridView.builder(
          padding: AppSpacing.screenPadding,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.6,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return _SlotTile(
              slot: slot,
              hallId: hallId,
            );
          },
        );
      },
    );
  }
}

/// Individual slot tile with color-coded status.
class _SlotTile extends ConsumerWidget {
  const _SlotTile({required this.slot, required this.hallId});

  final Slot slot;
  final String hallId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = slot.status == 'available';
    final isBooked = slot.status == 'booked';

    Color backgroundColor;
    Color textColor;
    if (isAvailable) {
      backgroundColor = AppColors.slotAvailable.withValues(alpha: 0.12);
      textColor = AppColors.slotAvailable;
    } else if (isBooked) {
      backgroundColor = AppColors.slotBooked.withValues(alpha: 0.12);
      textColor = AppColors.slotBooked;
    } else {
      // blocked
      backgroundColor = AppColors.slotBlocked.withValues(alpha: 0.12);
      textColor = AppColors.slotBlocked;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: isAvailable
            ? () => _onSlotSelected(context, ref)
            : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.startTime,
              style: AppTypography.titleMedium.copyWith(color: textColor),
            ),
            Text(
              slot.endTime,
              style: AppTypography.caption.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  void _onSlotSelected(BuildContext context, WidgetRef ref) {
    final hallState = ref.read(hallDetailProvider(hallId));
    final hall = hallState.asData?.value;

    context.push(
      '/booking/confirm',
      extra: BookingConfirmationParams(
        hallId: hallId,
        slotId: slot.id,
        hallName: hall?.name ?? '',
        slotInfo: '${slot.startTime} – ${slot.endTime}',
        slotDate: DateFormat('EEE, MMM d, yyyy').format(slot.date),
        price: hall?.basePrice ?? 0,
      ),
    );
  }
}

/// Parameters passed to the BookingConfirmationScreen via GoRouter extra.
class BookingConfirmationParams {
  const BookingConfirmationParams({
    required this.hallId,
    required this.slotId,
    required this.hallName,
    required this.slotInfo,
    required this.slotDate,
    required this.price,
  });

  final String hallId;
  final String slotId;
  final String hallName;
  final String slotInfo;
  final String slotDate;
  final double price;
}
