import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:hall_booking_platform/features/admin/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:hall_booking_platform/features/admin/analytics/domain/entities/analytics_dashboard.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAnalyticsRemoteDataSource extends Mock
    implements AnalyticsRemoteDataSource {}

void main() {
  late MockAnalyticsRemoteDataSource mockDataSource;
  late AnalyticsRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAnalyticsRemoteDataSource();
    repository = AnalyticsRepositoryImpl(mockDataSource);
  });

  const tDashboard = AnalyticsDashboard(
    totalBookings: 42,
    totalRevenue: 150000.0,
    activeUsers: 25,
    activeHalls: 10,
    period: 'monthly',
  );

  group('getAnalytics', () {
    test('returns AnalyticsDashboard on success', () async {
      when(() => mockDataSource.getAnalytics('monthly'))
          .thenAnswer((_) async => tDashboard);

      final result = await repository.getAnalytics('monthly');

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.totalBookings, 42);
          expect(data.totalRevenue, 150000.0);
          expect(data.activeUsers, 25);
          expect(data.activeHalls, 10);
          expect(data.period, 'monthly');
        },
      );
      verify(() => mockDataSource.getAnalytics('monthly')).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(() => mockDataSource.getAnalytics('monthly'))
          .thenThrow(const AuthException('Not authenticated'));

      final result = await repository.getAnalytics('monthly');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.getAnalytics('monthly'))
          .thenThrow(PostgrestException(message: 'DB error'));

      final result = await repository.getAnalytics('monthly');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected exception', () async {
      when(() => mockDataSource.getAnalytics('monthly'))
          .thenThrow(Exception('Unexpected'));

      final result = await repository.getAnalytics('monthly');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('passes different period values correctly', () async {
      when(() => mockDataSource.getAnalytics('daily'))
          .thenAnswer((_) async => tDashboard.copyWith(period: 'daily'));

      final result = await repository.getAnalytics('daily');

      expect(result, isA<Right>());
      verify(() => mockDataSource.getAnalytics('daily')).called(1);
    });
  });
}
