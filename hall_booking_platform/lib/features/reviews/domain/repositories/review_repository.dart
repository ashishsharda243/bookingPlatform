import 'package:dartz/dartz.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/reviews/domain/entities/review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, void>> submitReview({
    required String hallId,
    required int rating,
    String? comment,
  });

  Future<Either<Failure, List<Review>>> getHallReviews({
    required String hallId,
    required int page,
  });
}
