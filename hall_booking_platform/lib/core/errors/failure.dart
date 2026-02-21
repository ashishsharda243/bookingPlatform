import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.server({required String message, int? statusCode}) = ServerFailure;
  const factory Failure.network({required String message}) = NetworkFailure;
  const factory Failure.auth({required String message}) = AuthFailure;
  const factory Failure.validation({required String message, Map<String, String>? fieldErrors}) = ValidationFailure;
  const factory Failure.notFound({required String message}) = NotFoundFailure;
  const factory Failure.conflict({required String message}) = ConflictFailure;
  const factory Failure.forbidden({required String message}) = ForbiddenFailure;
  const factory Failure.unknown({required String message}) = UnknownFailure;
}
