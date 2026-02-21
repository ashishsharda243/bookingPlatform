import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/reviews/domain/entities/review.dart';
import 'package:hall_booking_platform/features/reviews/presentation/providers/review_providers.dart';
import 'package:intl/intl.dart';

/// Displays a paginated list of reviews for a hall.
/// Requirements 3.3, 7.1.
class ReviewListWidget extends ConsumerStatefulWidget {
  const ReviewListWidget({super.key, required this.hallId});

  final String hallId;

  @override
  ConsumerState<ReviewListWidget> createState() => _ReviewListWidgetState();
}

class _ReviewListWidgetState extends ConsumerState<ReviewListWidget> {
  @override
  void initState() {
    super.initState();
    // Load initial reviews after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewListProvider(widget.hallId).notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(reviewListProvider(widget.hallId));
    final notifier = ref.read(reviewListProvider(widget.hallId).notifier);

    return reviewsState.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: LoadingIndicator(),
      ),
      error: (error, _) => ErrorDisplay(
        message: 'Failed to load reviews.',
        onRetry: () => notifier.loadInitial(),
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text('No reviews yet.', style: AppTypography.bodyMedium),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...reviews.map((review) => _ReviewCard(review: review)),
            if (notifier.hasMore)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: notifier.isLoadingMore
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: () => notifier.loadMore(),
                          child: const Text('Load more reviews'),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A single review card showing user name, star rating, comment, and date.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: user name + date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    review.userName ?? 'Anonymous',
                    style: AppTypography.titleMedium,
                  ),
                  Text(
                    DateFormat.yMMMd().format(review.createdAt),
                    style: AppTypography.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              // Star rating display
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 18,
                  );
                }),
              ),
              // Comment
              if (review.comment != null &&
                  review.comment!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(review.comment!, style: AppTypography.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
