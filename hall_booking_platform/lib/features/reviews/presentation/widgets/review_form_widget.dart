import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/features/reviews/presentation/providers/review_providers.dart';

/// A form widget for submitting a review with star rating (1-5) and comment.
/// Requirements 7.1, 7.2.
class ReviewFormWidget extends ConsumerStatefulWidget {
  const ReviewFormWidget({
    super.key,
    required this.hallId,
    this.onReviewSubmitted,
  });

  final String hallId;
  final VoidCallback? onReviewSubmitted;

  @override
  ConsumerState<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends ConsumerState<ReviewFormWidget> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating.')),
      );
      return;
    }

    final comment = _commentController.text.trim();
    final success =
        await ref.read(reviewSubmissionProvider.notifier).submitReview(
              hallId: widget.hallId,
              rating: _selectedRating,
              comment: comment.isEmpty ? null : comment,
            );

    if (success && mounted) {
      _commentController.clear();
      setState(() => _selectedRating = 0);
      // Refresh the review list and eligibility check
      ref.invalidate(hallReviewsProvider(widget.hallId));
      ref.invalidate(canSubmitReviewProvider(widget.hallId));
      ref.invalidate(reviewListProvider(widget.hallId));
      widget.onReviewSubmitted?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(reviewSubmissionProvider);

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
            Text('Write a Review', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),
            // Star rating selector
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starIndex),
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: Icon(
                      starIndex <= _selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: AppColors.warning,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            // Comment input
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.sm),
              ),
            ),
            // Error message
            if (submissionState.error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                submissionState.error!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submissionState.isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                child: submissionState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
