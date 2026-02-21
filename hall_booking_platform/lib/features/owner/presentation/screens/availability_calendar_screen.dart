import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/owner/presentation/providers/owner_providers.dart';

/// Screen for managing hall availability with a calendar view.
///
/// Shows available/booked/blocked slots per date and provides
/// block/unblock actions for date ranges.
/// Requirements: 11.1, 11.2, 11.3, 11.4
class AvailabilityCalendarScreen extends ConsumerStatefulWidget {
  const AvailabilityCalendarScreen({super.key, required this.hallId});

  final String hallId;

  @override
  ConsumerState<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends ConsumerState<AvailabilityCalendarScreen> {
  late DateTime _focusedMonth;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(availabilityCalendarNotifierProvider(widget.hallId).notifier)
          .loadMonthSummary(_focusedMonth);
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
    ref
        .read(availabilityCalendarNotifierProvider(widget.hallId).notifier)
        .loadMonthSummary(_focusedMonth);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  Future<void> _blockDates() async {
    if (_selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range first.')),
      );
      return;
    }
    await ref
        .read(availabilityCalendarNotifierProvider(widget.hallId).notifier)
        .blockDates(_selectedRange!.start, _selectedRange!.end);
  }

  Future<void> _unblockDates() async {
    if (_selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range first.')),
      );
      return;
    }
    await ref
        .read(availabilityCalendarNotifierProvider(widget.hallId).notifier)
        .unblockDates(_selectedRange!.start, _selectedRange!.end);
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(availabilityCalendarNotifierProvider(widget.hallId));

    // Show snackbar for errors/success
    ref.listen<AvailabilityCalendarState>(
      availabilityCalendarNotifierProvider(widget.hallId),
      (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: AppColors.error,
            ),
          );
          ref
              .read(
                  availabilityCalendarNotifierProvider(widget.hallId).notifier)
              .clearError();
        }
        if (next.successMessage != null &&
            next.successMessage != prev?.successMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          ref
              .read(
                  availabilityCalendarNotifierProvider(widget.hallId).notifier)
              .clearSuccess();
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Availability Calendar')),
      body: Column(
        children: [
          _MonthNavigator(
            focusedMonth: _focusedMonth,
            onPrevious: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
          ),
          Expanded(
            flex: 3,
            child: state.isLoading
                ? const LoadingIndicator()
                : _CalendarGrid(
                    focusedMonth: _focusedMonth,
                    slotSummary: state.slotSummary,
                    selectedDate: state.selectedDate,
                    onDateTap: (date) => ref
                        .read(availabilityCalendarNotifierProvider(
                                widget.hallId)
                            .notifier)
                        .selectDate(date),
                  ),
          ),
          const Divider(height: 1),
          const _SlotLegend(),
          const Divider(height: 1),
          _DateRangeActions(
            selectedRange: _selectedRange,
            isBlocking: state.isBlocking,
            onPickRange: _pickDateRange,
            onBlock: _blockDates,
            onUnblock: _unblockDates,
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: _SelectedDateSlots(
              selectedDate: state.selectedDate,
              slots: state.slotsForDate,
              isLoading: state.isLoadingSlots,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Private Widgets
// =============================================================================

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(
            '${_monthNames[focusedMonth.month - 1]} ${focusedMonth.year}',
            style: AppTypography.headlineSmall,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.focusedMonth,
    required this.slotSummary,
    required this.selectedDate,
    required this.onDateTap,
  });

  final DateTime focusedMonth;
  final Map<String, Map<String, int>> slotSummary;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateTap;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=Mon

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: AppTypography.caption),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: daysInMonth + startWeekday - 1,
              itemBuilder: (context, index) {
                if (index < startWeekday - 1) {
                  return const SizedBox.shrink();
                }
                final day = index - startWeekday + 2;
                final date =
                    DateTime(focusedMonth.year, focusedMonth.month, day);
                final dateStr =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final summary = slotSummary[dateStr];
                final isSelected = selectedDate != null &&
                    selectedDate!.year == date.year &&
                    selectedDate!.month == date.month &&
                    selectedDate!.day == date.day;

                return _CalendarDayCell(
                  day: day,
                  summary: summary,
                  isSelected: isSelected,
                  onTap: () => onDateTap(date),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.summary,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final Map<String, int>? summary;
  final bool isSelected;
  final VoidCallback onTap;

  Color _dominantColor() {
    if (summary == null) return Colors.transparent;
    final booked = summary!['booked'] ?? 0;
    final blocked = summary!['blocked'] ?? 0;
    final available = summary!['available'] ?? 0;

    if (booked > 0 && blocked == 0 && available == 0) {
      return AppColors.slotBooked;
    }
    if (blocked > 0 && booked == 0 && available == 0) {
      return AppColors.slotBlocked;
    }
    if (available > 0 && booked == 0 && blocked == 0) {
      return AppColors.slotAvailable;
    }
    // Mixed — use a blended indicator
    if (booked > 0) return AppColors.slotBooked;
    if (blocked > 0) return AppColors.slotBlocked;
    return AppColors.slotAvailable;
  }

  @override
  Widget build(BuildContext context) {
    final color = _dominantColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 0.5,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (summary != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Legend showing what each color dot means on the calendar.
class _SlotLegend extends StatelessWidget {
  const _SlotLegend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(AppColors.slotAvailable, 'Available'),
          _legendItem(AppColors.slotBooked, 'Booked'),
          _legendItem(AppColors.slotBlocked, 'Blocked'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}

/// Date range picker and block/unblock action buttons.
class _DateRangeActions extends StatelessWidget {
  const _DateRangeActions({
    required this.selectedRange,
    required this.isBlocking,
    required this.onPickRange,
    required this.onBlock,
    required this.onUnblock,
  });

  final DateTimeRange? selectedRange;
  final bool isBlocking;
  final VoidCallback onPickRange;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: isBlocking ? null : onPickRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              selectedRange != null
                  ? '${_formatDate(selectedRange!.start)} – ${_formatDate(selectedRange!.end)}'
                  : 'Select date range',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isBlocking ? null : onBlock,
                  icon: isBlocking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.block),
                  label: const Text('Block'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slotBlocked,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isBlocking ? null : onUnblock,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark Available'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slotAvailable,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows the slots for the currently selected date.
class _SelectedDateSlots extends StatelessWidget {
  const _SelectedDateSlots({
    required this.selectedDate,
    required this.slots,
    required this.isLoading,
  });

  final DateTime? selectedDate;
  final List<Map<String, dynamic>> slots;
  final bool isLoading;

  Color _statusColor(String status) {
    return switch (status) {
      'available' => AppColors.slotAvailable,
      'booked' => AppColors.slotBooked,
      'blocked' => AppColors.slotBlocked,
      _ => AppColors.textHint,
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'available' => Icons.check_circle_outline,
      'booked' => Icons.event_busy,
      'blocked' => Icons.block,
      _ => Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDate == null) {
      return const Center(
        child: Text(
          'Tap a date to view its slots',
          style: AppTypography.bodyMedium,
        ),
      );
    }

    if (isLoading) {
      return const LoadingIndicator();
    }

    if (slots.isEmpty) {
      return Center(
        child: Text(
          'No slots for ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
          style: AppTypography.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: slots.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final status = slot['status'] as String? ?? 'available';
        final startTime = slot['start_time'] as String? ?? '--:--';
        final endTime = slot['end_time'] as String? ?? '--:--';
        final color = _statusColor(status);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            side: BorderSide(color: color.withValues(alpha: 0.4)),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(_statusIcon(status), color: color, size: 20),
            title: Text(
              '$startTime – $endTime',
              style: AppTypography.titleMedium,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                status[0].toUpperCase() + status.substring(1),
                style: AppTypography.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
