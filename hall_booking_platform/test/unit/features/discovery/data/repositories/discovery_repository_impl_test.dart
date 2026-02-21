import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'package:hall_booking_platform/features/discovery/data/repositories/discovery_repository_impl.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockDiscoveryRemoteDataSource extends Mock
    implements DiscoveryRemoteDataSource {}

void main() {
  late MockDiscoveryRemoteDataSource mockDataSource;
  late DiscoveryRepositoryImpl repository;

  final tHall = Hall(
    id: 'hall-1',
    ownerId: 'owner-1',
    name: 'Test Hall',
    description: 'A great hall',
    lat: 12.97,
    lng: 77.59,
    address: '123 Main St',
    amenities: const ['wifi', 'parking'],
    slotDurationMinutes: 60,
    basePrice: 500.0,
    approvalStatus: 'approved',
    createdAt: DateTime(2024, 1, 1),
    distance: 1.2,
  );

  setUp(() {
    mockDataSource = MockDiscoveryRemoteDataSource();
    repository = DiscoveryRepositoryImpl(mockDataSource);
  });

  group('getNearbyHalls', () {
    test('returns Right with list of halls on success', () async {
      when(() => mockDataSource.getNearbyHalls(
            lat: 12.97,
            lng: 77.59,
            radiusKm: 2.0,
            page: 1,
            pageSize: 20,
          )).thenAnswer((_) async => [tHall]);

      final result = await repository.getNearbyHalls(
        lat: 12.97,
        lng: 77.59,
        radiusKm: 2.0,
        page: 1,
        pageSize: 20,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (halls) {
          expect(halls.length, 1);
          expect(halls[0], tHall);
        },
      );
    });

    test('returns Left ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.getNearbyHalls(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenThrow(PostgrestException(
        message: 'RPC error',
        code: '42883',
      ));

      final result = await repository.getNearbyHalls(
        lat: 12.97,
        lng: 77.59,
        radiusKm: 2.0,
        page: 1,
        pageSize: 20,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message, 'RPC error');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left UnknownFailure on unexpected error', () async {
      when(() => mockDataSource.getNearbyHalls(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            radiusKm: any(named: 'radiusKm'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenThrow(Exception('Network error'));

      final result = await repository.getNearbyHalls(
        lat: 12.97,
        lng: 77.59,
        radiusKm: 2.0,
        page: 1,
        pageSize: 20,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('searchHalls', () {
    test('returns Right with list of halls on success', () async {
      when(() => mockDataSource.searchHalls(
            query: 'Grand',
            page: 1,
            pageSize: 20,
          )).thenAnswer((_) async => [tHall]);

      final result = await repository.searchHalls(
        query: 'Grand',
        page: 1,
        pageSize: 20,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (halls) {
          expect(halls.length, 1);
          expect(halls[0], tHall);
        },
      );
    });

    test('returns Left ServerFailure on PostgrestException', () async {
      when(() => mockDataSource.searchHalls(
            query: any(named: 'query'),
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenThrow(PostgrestException(message: 'Query failed'));

      final result = await repository.searchHalls(
        query: 'test',
        page: 1,
        pageSize: 20,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left UnknownFailure on unexpected error', () async {
      when(() => mockDataSource.searchHalls(
            query: any(named: 'query'),
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenThrow(Exception('Unexpected'));

      final result = await repository.searchHalls(
        query: 'test',
        page: 1,
        pageSize: 20,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getHallDetails', () {
    test('returns Right with hall on success', () async {
      when(() => mockDataSource.getHallDetails('hall-1'))
          .thenAnswer((_) async => tHall);

      final result = await repository.getHallDetails('hall-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (hall) => expect(hall, tHall),
      );
    });

    test('returns Left NotFoundFailure on PGRST116', () async {
      when(() => mockDataSource.getHallDetails(any()))
          .thenThrow(PostgrestException(
        message: 'Row not found',
        code: 'PGRST116',
      ));

      final result = await repository.getHallDetails('nonexistent');

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect((failure as NotFoundFailure).message, 'Hall not found.');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left ServerFailure on other PostgrestException', () async {
      when(() => mockDataSource.getHallDetails(any()))
          .thenThrow(PostgrestException(
        message: 'Internal error',
        code: '500',
      ));

      final result = await repository.getHallDetails('hall-1');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left UnknownFailure on unexpected error', () async {
      when(() => mockDataSource.getHallDetails(any()))
          .thenThrow(Exception('Timeout'));

      final result = await repository.getHallDetails('hall-1');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
