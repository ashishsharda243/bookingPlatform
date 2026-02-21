import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/reviews/data/datasources/review_remote_data_source.dart';
import 'package:hall_booking_platform/features/reviews/domain/entities/review.dart';
import 'package:hall_booking_platform/features/reviews/domain/repositories/review_repository.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of [ReviewRepository] backed by Supabase.
class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._dataSource, this._client);

  final ReviewRemoteDataSource _dataSource;
  final SupabaseClient _client;

  @override
  Future<Either<Failure, void>> submitReview({
    required String hallId,
    required int rating,
    String? comment,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Left(Failure.auth(message: 'User not authenticated.'));
      }

      // Validate rating range
      if (rating < 1 || rating > 5) {
        return const Left(
          Failure.validation(message: 'Rating must be between 1 and 5.'),
        );
      }

      // Check user has a completed booking for this hall (Requirement 7.1, 7.4)
      final hasBooking = await _dataSource.hasCompletedBooking(
        userId: userId,
        hallId: hallId,
      );
      if (!hasBooking) {
        return const Left(Failure.validation(
          message:
              'You can only review halls where you have a completed booking.',
        ));
      }

      // Enforce unique review per user per hall (Requirement 7.2)
      final hasReview = await _dataSource.hasExistingReview(
        userId: userId,
        hallId: hallId,
      );
      if (hasReview) {
        return const Left(Failure.conflict(
          message: 'You have already submitted a review for this hall.',
        ));
      }

      await _dataSource.submitReview(
        userId: userId,
        hallId: hallId,
        rating: rating,
        comment: comment,
      );

      return const Right(null);
    } on PostgrestException catch (e) {
      // Handle DB unique constraint violation as a fallback
      if (e.code == '23505') {
        return const Left(Failure.conflict(
          message: 'You have already submitted a review for this hall.',
        ));
      }
      return Left(Failure.server(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      ));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getHallReviews({
    required String hallId,
    required int page,
  }) async {
    try {
      final reviews = await _dataSource.getHallReviews(
        hallId: hallId,
        page: page,
        pageSize: AppConstants.defaultPageSize,
      );
      return Right(reviews);
    } on PostgrestException catch (e) {
      return Left(Failure.server(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      ));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}

/// Riverpod provider for [ReviewRepositoryImpl].
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(
    ref.watch(reviewRemoteDataSourceProvider),
    ref.watch(supabaseClientProvider),
  );
});
