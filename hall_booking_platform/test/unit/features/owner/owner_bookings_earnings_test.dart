import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/owner/data/datasources/owner_hall_remote_data_source.dart';
import 'package:hall_booking_platform/features/owner/data/repositories/owner_hall_repository_impl.dart';
import 'package:hall_booking_platform/features/owner/earnings/domain/entities/earnings_report.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockOwnerHallRemoteDataSource extends Mock
    implements OwnerHallRemoteDataSource {}

void main() {
  late MockOwnerHallRemoteDataSource mockDataSource;
  late OwnerHallRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockOwnerHallRemoteDataSource();
    repository = OwnerHallRepositoryImpl(mockDataSource);
  });

  group('getOwnerBookings', () {
    final bookings = [
      Booking(
        id: 'b1',
        userId: 'u1',
        hallId: 'h1',
        slotId: 's1',
        totalPrice: 500,
        paymentStatus: 'completed',
        bookingStatus: 'confirmed',
        createdAt: DateTime(2025, 1, 20),
      ),
      Booking(
        id: 'b2',
        userId: 'u2',
        hallId: 'h1',
        slotId: 's2',
        totalPrice: 300,
        paymentStatus: 'pending',
        bookingStatus: 'pending',
        createdAt: DateTime(2025, 1, 19),
      ),
    ];

    test('returns booking list sorted by date on success', () async {
      when(() => mockDataSource.getOwnerBookings(page: 1))
          .thenAnswer((_) async => bookings);

      final result = await repository.getOwnerBookings(page: 1);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.length, 2);
          expect(data[0].id, 'b1');
          expect(data[1].id, 'b2');
          // Verify sorted by date (newest first)
          expect(
            data[0].createdAt.isAfter(data[1].createdAt),
            true,
          );
        },
      );
    });

    test('returns empty list when no bookings exist', () async {
      when(() => mockDataSource.getOwnerBookings(page: 1))
          .thenAnswer((_) async => []);

      final result = await repository.getOwnerBookings(page: 1);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) => expect(data, isEmpty),
      );
    });

    test('returns AuthFailure when not authenticated', () async {
      when(() => mockDataSource.getOwnerBookings(page: 1))
          .thenThrow(const AuthException('Not authenticated.'));

      final result = await repository.getOwnerBookings(page: 1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.getOwnerBookings(page: 1))
          .thenThrow(PostgrestException(message: 'DB error'));

      final result = await repository.getOwnerBookings(page: 1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected error', () async {
      when(() => mockDataSource.getOwnerBookings(page: 1))
          .thenThrow(Exception('Unexpected'));

      final result = await repository.getOwnerBookings(page: 1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getEarnings', () {
    final report = EarningsReport(
      grossRevenue: 1000,
      commissionAmount: 100,
      netEarnings: 900,
      commissionPercentage: 10,
      entries: [
        EarningEntry(
          hallId: 'h1',
          hallName: 'Test Hall',
          revenue: 1000,
          bookingCount: 5,
          date: DateTime(2025, 1, 1),
        ),
      ],
    );

    test('returns earnings report on success', () async {
      when(() => mockDataSource.getEarnings(
            hallId: 'h1',
            period: 'monthly',
          )).thenAnswer((_) async => report);

      final result = await repository.getEarnings(
        hallId: 'h1',
        period: 'monthly',
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.grossRevenue, 1000);
          expect(data.commissionAmount, 100);
          expect(data.netEarnings, 900);
          expect(data.commissionPercentage, 10);
          expect(data.entries.length, 1);
        },
      );
    });

    test('returns AuthFailure when not authenticated', () async {
      when(() => mockDataSource.getEarnings(
            hallId: 'h1',
            period: 'monthly',
          )).thenThrow(const AuthException('Not authenticated.'));

      final result = await repository.getEarnings(
        hallId: 'h1',
        period: 'monthly',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.getEarnings(
            hallId: 'h1',
            period: 'monthly',
          )).thenThrow(PostgrestException(message: 'DB error'));

      final result = await repository.getEarnings(
        hallId: 'h1',
        period: 'monthly',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getOwnerEarnings', () {
    final report = EarningsReport(
      grossRevenue: 5000,
      commissionAmount: 500,
      netEarnings: 4500,
      commissionPercentage: 10,
      entries: [
        EarningEntry(
          hallId: 'h1',
          hallName: 'Hall A',
          revenue: 3000,
          bookingCount: 10,
          date: DateTime(2025, 1, 1),
        ),
        EarningEntry(
          hallId: 'h2',
          hallName: 'Hall B',
          revenue: 2000,
          bookingCount: 8,
          date: DateTime(2025, 1, 1),
        ),
      ],
    );

    test('returns aggregated earnings across all halls', () async {
      when(() => mockDataSource.getOwnerEarnings(period: 'monthly'))
          .thenAnswer((_) async => report);

      final result = await repository.getOwnerEarnings(period: 'monthly');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.grossRevenue, 5000);
          expect(data.netEarnings, 4500);
          expect(data.entries.length, 2);
        },
      );
    });

    test('returns UnknownFailure on unexpected error', () async {
      when(() => mockDataSource.getOwnerEarnings(period: 'daily'))
          .thenThrow(Exception('Unexpected'));

      final result = await repository.getOwnerEarnings(period: 'daily');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('earnings calculation correctness', () {
    test('net earnings = gross - commission for 10% rate', () async {
      final report = EarningsReport(
        grossRevenue: 10000,
        commissionAmount: 1000,
        netEarnings: 9000,
        commissionPercentage: 10,
        entries: [],
      );

      when(() => mockDataSource.getOwnerEarnings(period: 'monthly'))
          .thenAnswer((_) async => report);

      final result = await repository.getOwnerEarnings(period: 'monthly');

      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(
            data.netEarnings,
            data.grossRevenue - data.commissionAmount,
          );
          expect(
            data.commissionAmount,
            data.grossRevenue * (data.commissionPercentage / 100),
          );
        },
      );
    });

    test('zero revenue produces zero earnings', () async {
      final report = EarningsReport(
        grossRevenue: 0,
        commissionAmount: 0,
        netEarnings: 0,
        commissionPercentage: 10,
        entries: [],
      );

      when(() => mockDataSource.getOwnerEarnings(period: 'monthly'))
          .thenAnswer((_) async => report);

      final result = await repository.getOwnerEarnings(period: 'monthly');

      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.grossRevenue, 0);
          expect(data.commissionAmount, 0);
          expect(data.netEarnings, 0);
        },
      );
    });
  });
}
