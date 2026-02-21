import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/empty_state_widget.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/features/owner/presentation/providers/owner_providers.dart';

/// Owner dashboard screen displaying the owner's halls with status badges.
///
/// Provides a FAB to add new halls and tap-to-edit functionality.
class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ownerDashboardNotifierProvider.notifier).loadHalls();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownerDashboardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Halls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_outlined),
            tooltip: 'Bookings',
            onPressed: () => context.push('/owner/bookings'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Earnings',
            onPressed: () => context.push('/owner/earnings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(ownerDashboardNotifierProvider.notifier).loadHalls();
            },
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/hall/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Hall'),
      ),
    );
  }

  Widget _buildBody(OwnerDashboardState state) {
    if (state.isLoading && state.halls.isEmpty) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.halls.isEmpty) {
      return ErrorDisplay(
        message: state.error!,
        onRetry: () {
          ref.read(ownerDashboardNotifierProvider.notifier).loadHalls();
        },
      );
    }

    if (state.halls.isEmpty) {
      return EmptyStateWidget(
        message:
            'You haven\'t added any halls yet.\nTap the button below to get started.',
        icon: Icons.business_outlined,
        actionLabel: 'Add Hall',
        onAction: () => context.push('/owner/hall/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(ownerDashboardNotifierProvider.notifier).loadHalls();
      },
      child: ListView.separated(
        padding: AppSpacing.screenPadding,
        itemCount: state.halls.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          return _HallCard(hall: state.halls[index]);
        },
      ),
    );
  }
}

/// Card widget displaying a single hall with status badge.
class _HallCard extends StatelessWidget {
  const _HallCard({required this.hall});

  final Hall hall;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: () => context.push('/owner/hall/${hall.id}/edit'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      hall.name,
                      style: AppTypography.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatusBadge(status: hall.approvalStatus),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      hall.address,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text(
                    '₹${hall.basePrice.toStringAsFixed(0)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${hall.slotDurationMinutes} min',
                    style: AppTypography.bodySmall,
                  ),
                  if (hall.imageUrls != null && hall.imageUrls!.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.image_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${hall.imageUrls!.length} images',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/owner/hall/${hall.id}/availability'),
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: const Text('Availability'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        textStyle: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/owner/hall/${hall.id}/edit'),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        textStyle: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Consumer(
                    builder: (context, ref, _) {
                      return IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        tooltip: 'Delete Hall',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Hall'),
                              content: Text(
                                  'Are you sure you want to delete ${hall.name}? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            ref
                                .read(ownerDashboardNotifierProvider.notifier)
                                .deleteHall(hall.id);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge showing the hall's approval status with appropriate color.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, label) = switch (status) {
      'approved' => (
          AppColors.success,
          AppColors.secondaryLight.withValues(alpha: 0.2),
          'Approved'
        ),
      'rejected' => (
          AppColors.error,
          AppColors.error.withValues(alpha: 0.1),
          'Rejected'
        ),
      _ => (
          AppColors.warning,
          AppColors.warning.withValues(alpha: 0.1),
          'Pending'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
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
