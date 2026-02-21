import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/admin/analytics/presentation/providers/analytics_providers.dart';
import 'package:intl/intl.dart';

/// Admin screen displaying platform analytics with period selector.
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  static const _periods = ['daily', 'weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(analyticsNotifierProvider.notifier).loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(analyticsNotifierProvider.notifier).loadAnalytics();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _PeriodSelector(
            selectedPeriod: state.selectedPeriod,
            periods: _periods,
            onPeriodChanged: (period) {
              ref
                  .read(analyticsNotifierProvider.notifier)
                  .changePeriod(period);
            },
          ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(AnalyticsState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.dashboard == null) {
      return ErrorDisplay(
        message: state.error!,
        onRetry: () {
          ref.read(analyticsNotifierProvider.notifier).loadAnalytics();
        },
      );
    }

    final dashboard = state.dashboard;
    if (dashboard == null) {
      return const LoadingIndicator();
    }

    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(analyticsNotifierProvider.notifier).loadAnalytics();
      },
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _StatCard(
            title: 'Total Bookings',
            value: dashboard.totalBookings.toString(),
            icon: Icons.calendar_today,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatCard(
            title: 'Total Revenue',
            value: currencyFormat.format(dashboard.totalRevenue),
            icon: Icons.attach_money,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatCard(
            title: 'Active Users',
            value: dashboard.activeUsers.toString(),
            icon: Icons.people,
            color: AppColors.info,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatCard(
            title: 'Active Halls',
            value: dashboard.activeHalls.toString(),
            icon: Icons.business,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

/// Period selector chip bar.
class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.periods,
    required this.onPeriodChanged,
  });

  final String selectedPeriod;
  final List<String> periods;
  final ValueChanged<String> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = period == selectedPeriod;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: ChoiceChip(
                label: Text(
                  period[0].toUpperCase() + period.substring(1),
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                onSelected: (_) => onPeriodChanged(period),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A stat card displaying a single analytics metric.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppTypography.headlineMedium.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
