import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/owner/data/repositories/owner_hall_repository_impl.dart';
import 'package:hall_booking_platform/features/owner/presentation/providers/owner_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockOwnerHallRepositoryImpl extends Mock
    implements OwnerHallRepositoryImpl {}

void main() {
  late MockOwnerHallRepositoryImpl mockRepository;
  late AvailabilityCalendarNotifier notifier;

  setUp(() {
    mockRepository = MockOwnerHallRepositoryImpl();
    notifier = AvailabilityCalendarNotifier(mockRepository, 'hall-1');
  });

  group('loadMonthSummary', () {
    test('sets isLoading then populates slotSummary on success', () async {
      final summary = {
        '2025-01-10': {'available': 2, 'booked': 1, 'blocked': 0},
      };

      when(() => mockRepository.getSlotSummary(
            'hall-1',
            any(),
            any(),
          )).thenAnswer((_) async => Right(summary));

      await notifier.loadMonthSummary(DateTime(2025, 1));

      expect(notifier.state.isLoading, false);
      expect(notifier.state.slotSummary, summary);
      expect(notifier.state.error, isNull);
    });

    test('sets error on failure', () async {
      when(() => mockRepository.getSlotSummary(
            'hall-1',
            any(),
            any(),
          )).thenAnswer(
        (_) async => const Left(Failure.server(message: 'Server error')),
      );

      await notifier.loadMonthSummary(DateTime(2025, 1));

      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, 'Server error');
    });
  });

  group('selectDate', () {
    test('loads slots for the selected date', () async {
      final slots = [
        {
          'id': 's1',
          'start_time': '09:00',
          'end_time': '10:00',
          'status': 'available',
        },
      ];

      when(() => mockRepository.getSlotsByDate('hall-1', any()))
          .thenAnswer((_) async => Right(slots));

      final date = DateTime(2025, 1, 15);
      await notifier.selectDate(date);

      expect(notifier.state.selectedDate, date);
      expect(notifier.state.slotsForDate, slots);
      expect(notifier.state.isLoadingSlots, false);
    });
  });

  group('blockDates', () {
    test('calls repository with date list and sets success message', () async {
      when(() => mockRepository.blockSlots(
            hallId: 'hall-1',
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ))
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.getSlotSummary('hall-1', any(), any()))
          .thenAnswer((_) async => const Right({}));

      final start = DateTime(2025, 1, 15);
      final end = DateTime(2025, 1, 17);
      await notifier.blockDates(start, end);

      // Verify blockSlots was called with 3 dates (15, 16, 17)
      verify(() => mockRepository.blockSlots(
            hallId: 'hall-1',
            startDate: start,
            endDate: end,
          )).called(1);

      expect(notifier.state.isBlocking, false);
      expect(notifier.state.successMessage, 'Dates blocked successfully.');
    });

    test('sets error when blocking fails due to booked slots', () async {
      when(() => mockRepository.blockSlots(
            hallId: 'hall-1',
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer(
        (_) async => const Left(
          Failure.conflict(message: 'Cannot block: slots already booked.'),
        ),
      );

      await notifier.blockDates(DateTime(2025, 1, 15), DateTime(2025, 1, 15));

      expect(notifier.state.isBlocking, false);
      expect(notifier.state.error, contains('already booked'));
    });
  });

  group('unblockDates', () {
    test('calls repository and sets success message', () async {
      when(() => mockRepository.unblockSlots(
            hallId: 'hall-1',
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ))
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.getSlotSummary('hall-1', any(), any()))
          .thenAnswer((_) async => const Right({}));

      await notifier.unblockDates(
          DateTime(2025, 1, 15), DateTime(2025, 1, 16));

      verify(() => mockRepository.unblockSlots(
            hallId: 'hall-1',
            startDate: DateTime(2025, 1, 15),
            endDate: DateTime(2025, 1, 16),
          )).called(1);

      expect(notifier.state.isBlocking, false);
      expect(notifier.state.successMessage, 'Dates unblocked successfully.');
    });
  });
}
