import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/features/reviews/data/datasources/review_remote_data_source.dart';
import 'package:hall_booking_platform/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:hall_booking_platform/features/reviews/domain/entities/review.dart';
import 'package:hall_booking_platform/features/reviews/domain/repositories/review_repository.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';

/// Fetches the first page of reviews for a hall.
final hallReviewsProvider = FutureProvider.autoDispose
    .family<List<Review>, String>((ref, hallId) async {
  final repo = ref.read(reviewRepositoryProvider);
  final result = await repo.getHallReviews(hallId: hallId, page: 1);
  return result.fold(
    (failure) => throw failure,
    (reviews) => reviews,
  );
});

/// State for review submission.
class ReviewSubmissionState {
  const ReviewSubmissionState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? error;
}

/// Notifier for submitting a review.
class ReviewSubmissionNotifier extends StateNotifier<ReviewSubmissionState> {
  ReviewSubmissionNotifier(this._repository)
      : super(const ReviewSubmissionState());

  final ReviewRepository _repository;

  Future<bool> submitReview({
    required String hallId,
    required int rating,
    String? comment,
  }) async {
    state = const ReviewSubmissionState(isLoading: true);

    final result = await _repository.submitReview(
      hallId: hallId,
      rating: rating,
      comment: comment,
    );

    return result.fold(
      (failure) {
        state = ReviewSubmissionState(error: failure.message);
        return false;
      },
      (_) {
        state = const ReviewSubmissionState(isSuccess: true);
        return true;
      },
    );
  }

  void reset() {
    state = const ReviewSubmissionState();
  }
}

final reviewSubmissionProvider = StateNotifierProvider.autoDispose<
    ReviewSubmissionNotifier, ReviewSubmissionState>((ref) {
  return ReviewSubmissionNotifier(ref.watch(reviewRepositoryProvider));
});

/// Manages paginated review list with load-more support.
class ReviewListNotifier extends StateNotifier<AsyncValue<List<Review>>> {
  ReviewListNotifier(this._repository, this._hallId)
      : super(const AsyncValue.loading());

  final ReviewRepository _repository;
  final String _hallId;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadInitial() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    try {
      final result = await _repository.getHallReviews(
        hallId: _hallId,
        page: 1,
      );
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (reviews) {
          _hasMore = reviews.length >= AppConstants.defaultPageSize;
          state = AsyncValue.data(reviews);
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    try {
      _currentPage++;
      final result = await _repository.getHallReviews(
        hallId: _hallId,
        page: _currentPage,
      );
      result.fold(
        (failure) => _currentPage--,
        (reviews) {
          _hasMore = reviews.length >= AppConstants.defaultPageSize;
          final current = state.asData?.value ?? [];
          state = AsyncValue.data([...current, ...reviews]);
        },
      );
    } catch (_) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }
}

/// Provider for paginated review list, scoped by hall ID.
final reviewListProvider = StateNotifierProvider.autoDispose
    .family<ReviewListNotifier, AsyncValue<List<Review>>, String>(
  (ref, hallId) {
    return ReviewListNotifier(ref.watch(reviewRepositoryProvider), hallId);
  },
);

/// Checks if the current user can submit a review for a hall.
/// Returns true if user has a completed booking and no existing review.
final canSubmitReviewProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, hallId) async {
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return false;

  final dataSource = ref.read(reviewRemoteDataSourceProvider);

  final hasBooking = await dataSource.hasCompletedBooking(
    userId: userId,
    hallId: hallId,
  );
  if (!hasBooking) return false;

  final hasReview = await dataSource.hasExistingReview(
    userId: userId,
    hallId: hallId,
  );
  return !hasReview;
});
