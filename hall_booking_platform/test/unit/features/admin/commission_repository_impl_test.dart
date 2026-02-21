import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/commission/data/datasources/commission_remote_data_source.dart';
import 'package:hall_booking_platform/features/admin/commission/data/repositories/commission_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockCommissionRemoteDataSource extends Mock
    implements CommissionRemoteDataSource {}

void main() {
  late MockCommissionRemoteDataSource mockDataSource;
  late CommissionRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockCommissionRemoteDataSource();
    repository = CommissionRepositoryImpl(mockDataSource);
  });

  group('getCommissionPercentage', () {
    test('returns commission percentage on success', () async {
      when(() => mockDataSource.getCommissionPercentage())
          .thenAnswer((_) async => 10.0);

      final result = await repository.getCommissionPercentage();

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected Right'),
        (data) => expect(data, 10.0),
      );
      verify(() => mockDataSource.getCommissionPercentage()).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(() => mockDataSource.getCommissionPercentage())
          .thenThrow(const AuthException('Not authenticated'));

      final result = await repository.getCommissionPercentage();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.getCommissionPercentage())
          .thenThrow(PostgrestException(message: 'DB error'));

      final result = await repository.getCommissionPercentage();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected exception', () async {
      when(() => mockDataSource.getCommissionPercentage())
          .thenThrow(Exception('Unexpected'));

      final result = await repository.getCommissionPercentage();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('setCommissionPercentage', () {
    test('returns Right(null) on success', () async {
      when(() => mockDataSource.setCommissionPercentage(15.0))
          .thenAnswer((_) async {});

      final result = await repository.setCommissionPercentage(15.0);

      expect(result, isA<Right>());
      verify(() => mockDataSource.setCommissionPercentage(15.0)).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(() => mockDataSource.setCommissionPercentage(15.0))
          .thenThrow(const AuthException('Forbidden'));

      final result = await repository.setCommissionPercentage(15.0);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.setCommissionPercentage(15.0))
          .thenThrow(PostgrestException(message: 'Update failed'));

      final result = await repository.setCommissionPercentage(15.0);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected exception', () async {
      when(() => mockDataSource.setCommissionPercentage(15.0))
          .thenThrow(Exception('Oops'));

      final result = await repository.setCommissionPercentage(15.0);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
