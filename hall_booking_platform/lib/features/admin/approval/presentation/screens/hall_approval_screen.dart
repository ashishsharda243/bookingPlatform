import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/empty_state_widget.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/admin/approval/presentation/providers/admin_approval_providers.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';

/// Admin screen for reviewing and approving/rejecting pending hall listings.
class HallApprovalScreen extends ConsumerStatefulWidget {
  const HallApprovalScreen({super.key});

  @override
  ConsumerState<HallApprovalScreen> createState() =>
      _HallApprovalScreenState();
}

class _HallApprovalScreenState extends ConsumerState<HallApprovalScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(hallApprovalNotifierProvider.notifier).loadPendingHalls();
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
      ref.read(hallApprovalNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallApprovalNotifierProvider);

    ref.listen<HallApprovalState>(hallApprovalNotifierProvider,
        (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(hallApprovalNotifierProvider.notifier).clearSuccess();
      }
      if (next.error != null && next.error != prev?.error && next.halls.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(hallApprovalNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hall Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(hallApprovalNotifierProvider.notifier)
                  .loadPendingHalls();
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(HallApprovalState state) {
    if (state.isLoading && state.halls.isEmpty) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.halls.isEmpty) {
      return ErrorDisplay(
        message: state.error!,
        onRetry: () {
          ref
              .read(hallApprovalNotifierProvider.notifier)
              .loadPendingHalls();
        },
      );
    }

    if (state.halls.isEmpty) {
      return const EmptyStateWidget(
        message: 'No pending halls to review.\nAll caught up!',
        icon: Icons.check_circle_outline,
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(hallApprovalNotifierProvider.notifier)
                .loadPendingHalls();
          },
          child: ListView.separated(
            controller: _scrollController,
            padding: AppSpacing.screenPadding,
            itemCount: state.halls.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == state.halls.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _PendingHallCard(
                hall: state.halls[index],
                isProcessing: state.isProcessing,
              );
            },
          ),
        ),
        if (state.isProcessing)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}


/// Card displaying a pending hall with approve/reject actions.
class _PendingHallCard extends ConsumerWidget {
  const _PendingHallCard({
    required this.hall,
    required this.isProcessing,
  });

  final Hall hall;
  final bool isProcessing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Text(
              hall.name,
              style: AppTypography.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
            if (hall.description.isNotEmpty) ...[
              Text(
                hall.description,
                style: AppTypography.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
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
              ],
            ),
            if (hall.amenities.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: hall.amenities
                    .map((a) => Chip(
                          label: Text(a, style: AppTypography.caption),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Submitted: ${_formatDate(hall.createdAt)}',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () => _showRejectDialog(context, ref),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () {
                            ref
                                .read(hallApprovalNotifierProvider.notifier)
                                .approveHall(hall.id);
                          },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Hall'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Rejection reason',
            hintText: 'Enter the reason for rejection...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.of(dialogContext).pop();
              ref
                  .read(hallApprovalNotifierProvider.notifier)
                  .rejectHall(hall.id, reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
