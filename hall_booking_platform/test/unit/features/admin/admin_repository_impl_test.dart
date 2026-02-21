import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/approval/data/datasources/admin_remote_data_source.dart';
import 'package:hall_booking_platform/features/admin/approval/data/repositories/admin_repository_impl.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAdminRemoteDataSource extends Mock
    implements AdminRemoteDataSource {}

void main() {
  late MockAdminRemoteDataSource mockDataSource;
  late AdminRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAdminRemoteDataSource();
    repository = AdminRepositoryImpl(mockDataSource);
  });

  Hall _makeHall(String id) {
    return Hall(
      id: id,
      ownerId: 'owner-1',
      name: 'Hall $id',
      description: 'Description',
      lat: 12.0,
      lng: 77.0,
      address: '123 Main St',
      amenities: ['WiFi'],
      slotDurationMinutes: 60,
      basePrice: 1000,
      approvalStatus: 'pending',
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('getPendingHalls', () {
    test('returns list of pending halls on success', () async {
      final halls = [_makeHall('h1'), _makeHall('h2')];
      when(() => mockDataSource.getPendingHalls(page: 1))
          .thenAnswer((_) async => halls);

      final result = await repository.getPendingHalls(page: 1);

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.length, 2);
          expect(data[0].id, 'h1');
          expect(data[1].id, 'h2');
        },
      );
    });

    test('returns AuthFailure on AuthException', () async {
      when(() => mockDataSource.getPendingHalls(page: 1))
          .thenThrow(const AuthException('Not authenticated'));

      final result = await repository.getPendingHalls(page: 1);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.getPendingHalls(page: 1))
          .thenThrow(PostgrestException(message: 'DB error'));

      final result = await repository.getPendingHalls(page: 1);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected exception', () async {
      when(() => mockDataSource.getPendingHalls(page: 1))
          .thenThrow(Exception('Unexpected'));

      final result = await repository.getPendingHalls(page: 1);

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('approveHall', () {
    test('returns Right(null) on success', () async {
      when(() => mockDataSource.approveHall('h1'))
          .thenAnswer((_) async {});

      final result = await repository.approveHall('h1');

      expect(result, isA<Right>());
      verify(() => mockDataSource.approveHall('h1')).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(() => mockDataSource.approveHall('h1'))
          .thenThrow(const AuthException('Forbidden'));

      final result = await repository.approveHall('h1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.approveHall('h1'))
          .thenThrow(PostgrestException(message: 'Not found'));

      final result = await repository.approveHall('h1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('rejectHall', () {
    test('returns Right(null) on success', () async {
      when(() => mockDataSource.rejectHall('h1', 'Bad quality'))
          .thenAnswer((_) async {});

      final result = await repository.rejectHall('h1', 'Bad quality');

      expect(result, isA<Right>());
      verify(() => mockDataSource.rejectHall('h1', 'Bad quality')).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(() => mockDataSource.rejectHall('h1', 'reason'))
          .thenThrow(const AuthException('Unauthorized'));

      final result = await repository.rejectHall('h1', 'reason');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected exception', () async {
      when(() => mockDataSource.rejectHall('h1', 'reason'))
          .thenThrow(Exception('Oops'));

      final result = await repository.rejectHall('h1', 'reason');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
