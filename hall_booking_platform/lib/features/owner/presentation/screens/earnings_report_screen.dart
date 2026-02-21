import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/owner/earnings/domain/entities/earnings_report.dart';
import 'package:hall_booking_platform/features/owner/presentation/providers/owner_providers.dart';
import 'package:intl/intl.dart';

/// Screen displaying earnings report with period selector and revenue breakdown.
///
/// Requirements 12.2, 12.3, 12.4:
/// - Display total earnings, earnings by hall, and earnings by time period
/// - Calculate earnings as revenue minus platform commission
/// - Show both gross revenue and net earnings after commission
class EarningsReportScreen extends ConsumerStatefulWidget {
  const EarningsReportScreen({super.key});

  @override
  ConsumerState<EarningsReportScreen> createState() =>
      _EarningsReportScreenState();
}

class _EarningsReportScreenState extends ConsumerState<EarningsReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(earningsReportNotifierProvider.notifier).loadEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningsReportNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(earningsReportNotifierProvider.notifier).loadEarnings();
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EarningsReportState state) {
    if (state.isLoading && state.report == null) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.report == null) {
      return ErrorDisplay(
        message: state.error!,
        onRetry: () {
          ref.read(earningsReportNotifierProvider.notifier).loadEarnings();
        },
      );
    }

    final report = state.report;
    if (report == null) {
      return const LoadingIndicator();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(earningsReportNotifierProvider.notifier).loadEarnings();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeriodSelector(
              selectedPeriod: state.selectedPeriod,
              onChanged: (period) {
                ref
                    .read(earningsReportNotifierProvider.notifier)
                    .changePeriod(period);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _RevenueSummaryCard(report: report),
            const SizedBox(height: AppSpacing.lg),
            Text('Breakdown', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            if (report.entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    'No earnings data for this period.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              )
            else
              ...report.entries.map(
                (entry) => _EarningEntryCard(
                  entry: entry,
                  commissionPercentage: report.commissionPercentage,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  final String selectedPeriod;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'daily', label: Text('Daily')),
        ButtonSegment(value: 'weekly', label: Text('Weekly')),
        ButtonSegment(value: 'monthly', label: Text('Monthly')),
      ],
      selected: {selectedPeriod},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}

class _RevenueSummaryCard extends StatelessWidget {
  const _RevenueSummaryCard({required this.report});

  final EarningsReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue Summary', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            _SummaryRow(
              label: 'Gross Revenue',
              value: '₹${report.grossRevenue.toStringAsFixed(2)}',
              valueColor: AppColors.textPrimary,
            ),
            const Divider(height: AppSpacing.lg),
            _SummaryRow(
              label:
                  'Commission (${report.commissionPercentage.toStringAsFixed(1)}%)',
              value: '- ₹${report.commissionAmount.toStringAsFixed(2)}',
              valueColor: AppColors.error,
            ),
            const Divider(height: AppSpacing.lg),
            _SummaryRow(
              label: 'Net Earnings',
              value: '₹${report.netEarnings.toStringAsFixed(2)}',
              valueColor: AppColors.success,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
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
          style: (isBold ? AppTypography.titleLarge : AppTypography.titleMedium)
              .copyWith(color: valueColor),
        ),
      ],
    );
  }
}

class _EarningEntryCard extends StatelessWidget {
  const _EarningEntryCard({
    required this.entry,
    required this.commissionPercentage,
  });

  final EarningEntry entry;
  final double commissionPercentage;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final commission = entry.revenue * (commissionPercentage / 100);
    final net = entry.revenue - commission;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.hallName,
                    style: AppTypography.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateFormat.format(entry.date),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _MetricChip(
                  label: 'Bookings',
                  value: '${entry.bookingCount}',
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.sm),
                _MetricChip(
                  label: 'Gross',
                  value: '₹${entry.revenue.toStringAsFixed(0)}',
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                _MetricChip(
                  label: 'Net',
                  value: '₹${net.toStringAsFixed(0)}',
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.caption),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
