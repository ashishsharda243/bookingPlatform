import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/owner/data/repositories/owner_hall_repository_impl.dart';
import 'package:hall_booking_platform/features/owner/earnings/domain/entities/earnings_report.dart';
import 'package:hall_booking_platform/features/owner/presentation/providers/owner_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockOwnerHallRepositoryImpl extends Mock
    implements OwnerHallRepositoryImpl {}

void main() {
  late MockOwnerHallRepositoryImpl mockRepository;

  setUp(() {
    mockRepository = MockOwnerHallRepositoryImpl();
  });

  Booking _makeBooking(String id, DateTime createdAt) {
    return Booking(
      id: id,
      userId: 'u1',
      hallId: 'h1',
      slotId: 's1',
      totalPrice: 500,
      paymentStatus: 'completed',
      bookingStatus: 'confirmed',
      createdAt: createdAt,
    );
  }

  group('OwnerBookingsNotifier', () {
    test('loadBookings sets bookings on success', () async {
      final bookings = [
        _makeBooking('b1', DateTime(2025, 1, 20)),
        _makeBooking('b2', DateTime(2025, 1, 19)),
      ];

      when(() => mockRepository.getOwnerBookings(page: 1))
          .thenAnswer((_) async => Right(bookings));

      final notifier = OwnerBookingsNotifier(mockRepository);

      await notifier.loadBookings();

      expect(notifier.state.bookings.length, 2);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
      expect(notifier.state.currentPage, 1);
    });

    test('loadBookings sets error on failure', () async {
      when(() => mockRepository.getOwnerBookings(page: 1)).thenAnswer(
        (_) async =>
            const Left(Failure.server(message: 'Server error')),
      );

      final notifier = OwnerBookingsNotifier(mockRepository);

      await notifier.loadBookings();

      expect(notifier.state.bookings, isEmpty);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, 'Server error');
    });

    test('loadMore appends bookings to existing list', () async {
      final page1 = List.generate(
        20,
        (i) => _makeBooking('b$i', DateTime(2025, 1, 20 - i)),
      );
      final page2 = [
        _makeBooking('b20', DateTime(2025, 1, 1)),
      ];

      when(() => mockRepository.getOwnerBookings(page: 1))
          .thenAnswer((_) async => Right(page1));
      when(() => mockRepository.getOwnerBookings(page: 2))
          .thenAnswer((_) async => Right(page2));

      final notifier = OwnerBookingsNotifier(mockRepository);

      await notifier.loadBookings();
      expect(notifier.state.bookings.length, 20);
      expect(notifier.state.hasMore, true);

      await notifier.loadMore();
      expect(notifier.state.bookings.length, 21);
      expect(notifier.state.currentPage, 2);
      expect(notifier.state.hasMore, false);
    });

    test('loadMore does nothing when hasMore is false', () async {
      when(() => mockRepository.getOwnerBookings(page: 1))
          .thenAnswer((_) async => Right([
                _makeBooking('b1', DateTime(2025, 1, 20)),
              ]));

      final notifier = OwnerBookingsNotifier(mockRepository);

      await notifier.loadBookings();
      expect(notifier.state.hasMore, false);

      await notifier.loadMore();
      // Should not have called page 2
      verifyNever(() => mockRepository.getOwnerBookings(page: 2));
    });
  });

  group('EarningsReportNotifier', () {
    test('loadEarnings sets report on success', () async {
      final report = EarningsReport(
        grossRevenue: 5000,
        commissionAmount: 500,
        netEarnings: 4500,
        commissionPercentage: 10,
        entries: [],
      );

      when(() => mockRepository.getOwnerEarnings(period: 'monthly'))
          .thenAnswer((_) async => Right(report));

      final notifier = EarningsReportNotifier(mockRepository);

      await notifier.loadEarnings();

      expect(notifier.state.report, isNotNull);
      expect(notifier.state.report!.grossRevenue, 5000);
      expect(notifier.state.report!.netEarnings, 4500);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('loadEarnings sets error on failure', () async {
      when(() => mockRepository.getOwnerEarnings(period: 'monthly'))
          .thenAnswer(
        (_) async =>
            const Left(Failure.auth(message: 'Not authenticated')),
      );

      final notifier = EarningsReportNotifier(mockRepository);

      await notifier.loadEarnings();

      expect(notifier.state.report, isNull);
      expect(notifier.state.error, 'Not authenticated');
    });

    test('changePeriod updates period and reloads', () async {
      final monthlyReport = EarningsReport(
        grossRevenue: 5000,
        commissionAmount: 500,
        netEarnings: 4500,
        commissionPercentage: 10,
        entries: [],
      );
      final dailyReport = EarningsReport(
        grossRevenue: 200,
        commissionAmount: 20,
        netEarnings: 180,
        commissionPercentage: 10,
        entries: [],
      );

      when(() => mockRepository.getOwnerEarnings(period: 'monthly'))
          .thenAnswer((_) async => Right(monthlyReport));
      when(() => mockRepository.getOwnerEarnings(period: 'daily'))
          .thenAnswer((_) async => Right(dailyReport));

      final notifier = EarningsReportNotifier(mockRepository);

      await notifier.loadEarnings();
      expect(notifier.state.selectedPeriod, 'monthly');
      expect(notifier.state.report!.grossRevenue, 5000);

      await notifier.changePeriod('daily');
      expect(notifier.state.selectedPeriod, 'daily');
      expect(notifier.state.report!.grossRevenue, 200);
    });

    test('default period is monthly', () {
      final notifier = EarningsReportNotifier(mockRepository);
      expect(notifier.state.selectedPeriod, 'monthly');
    });
  });
}
