import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/owner/data/datasources/owner_hall_remote_data_source.dart';
import 'package:hall_booking_platform/features/owner/data/repositories/owner_hall_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock the data source for repository tests
class MockOwnerHallRemoteDataSource extends Mock
    implements OwnerHallRemoteDataSource {}

void main() {
  late MockOwnerHallRemoteDataSource mockDataSource;
  late OwnerHallRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockOwnerHallRemoteDataSource();
    repository = OwnerHallRepositoryImpl(mockDataSource);
  });

  group('blockSlots', () {
    final dates = [DateTime(2025, 1, 15), DateTime(2025, 1, 16)];

    test('returns Right(null) on success', () async {
      when(() => mockDataSource.blockSlots('hall-1', dates))
          .thenAnswer((_) async {});

      final result = await repository.blockSlots('hall-1', dates);

      expect(result, const Right(null));
      verify(() => mockDataSource.blockSlots('hall-1', dates)).called(1);
    });

    test('returns ConflictFailure when blocking booked slots', () async {
      when(() => mockDataSource.blockSlots('hall-1', dates))
          .thenThrow(Exception(
        'Cannot block 2025-01-15: 2 slot(s) already booked.',
      ));

      final result = await repository.blockSlots('hall-1', dates);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ConflictFailure>());
          expect(failure.message, contains('already booked'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('returns AuthFailure when not authenticated', () async {
      when(() => mockDataSource.blockSlots('hall-1', dates))
          .thenThrow(const AuthException('Not authenticated.'));

      final result = await repository.blockSlots('hall-1', dates);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.blockSlots('hall-1', dates))
          .thenThrow(PostgrestException(message: 'DB error'));

      final result = await repository.blockSlots('hall-1', dates);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('unblockSlots', () {
    final dates = [DateTime(2025, 1, 15)];

    test('returns Right(null) on success', () async {
      when(() => mockDataSource.unblockSlots('hall-1', dates))
          .thenAnswer((_) async {});

      final result = await repository.unblockSlots('hall-1', dates);

      expect(result, const Right(null));
      verify(() => mockDataSource.unblockSlots('hall-1', dates)).called(1);
    });

    test('returns AuthFailure when not authenticated', () async {
      when(() => mockDataSource.unblockSlots('hall-1', dates))
          .thenThrow(const AuthException('Not authenticated.'));

      final result = await repository.unblockSlots('hall-1', dates);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected error', () async {
      when(() => mockDataSource.unblockSlots('hall-1', dates))
          .thenThrow(Exception('Unexpected'));

      final result = await repository.unblockSlots('hall-1', dates);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getSlotsByDate', () {
    final date = DateTime(2025, 1, 15);

    test('returns slot list on success', () async {
      final slots = [
        {
          'id': 'slot-1',
          'hall_id': 'hall-1',
          'date': '2025-01-15',
          'start_time': '09:00',
          'end_time': '10:00',
          'status': 'available',
        },
        {
          'id': 'slot-2',
          'hall_id': 'hall-1',
          'date': '2025-01-15',
          'start_time': '10:00',
          'end_time': '11:00',
          'status': 'blocked',
        },
      ];

      when(() => mockDataSource.getSlotsByDate('hall-1', date))
          .thenAnswer((_) async => slots);

      final result = await repository.getSlotsByDate('hall-1', date);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.length, 2);
          expect(data[0]['status'], 'available');
          expect(data[1]['status'], 'blocked');
        },
      );
    });

    test('returns empty list when no slots exist', () async {
      when(() => mockDataSource.getSlotsByDate('hall-1', date))
          .thenAnswer((_) async => []);

      final result = await repository.getSlotsByDate('hall-1', date);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) => expect(data, isEmpty),
      );
    });
  });

  group('getSlotSummary', () {
    final startDate = DateTime(2025, 1, 1);
    final endDate = DateTime(2025, 1, 31);

    test('returns summary map on success', () async {
      final summary = {
        '2025-01-15': {'available': 3, 'booked': 1, 'blocked': 0},
        '2025-01-16': {'available': 0, 'booked': 0, 'blocked': 4},
      };

      when(() =>
              mockDataSource.getSlotSummary('hall-1', startDate, endDate))
          .thenAnswer((_) async => summary);

      final result =
          await repository.getSlotSummary('hall-1', startDate, endDate);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.keys.length, 2);
          expect(data['2025-01-15']!['available'], 3);
          expect(data['2025-01-16']!['blocked'], 4);
        },
      );
    });
  });
}
