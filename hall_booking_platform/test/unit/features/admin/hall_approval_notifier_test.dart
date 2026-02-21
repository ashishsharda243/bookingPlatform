import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/approval/data/repositories/admin_repository_impl.dart';
import 'package:hall_booking_platform/features/admin/approval/presentation/providers/admin_approval_providers.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepositoryImpl extends Mock implements AdminRepositoryImpl {}

void main() {
  late MockAdminRepositoryImpl mockRepository;

  setUp(() {
    mockRepository = MockAdminRepositoryImpl();
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

  group('HallApprovalNotifier', () {
    test('loadPendingHalls sets halls on success', () async {
      final halls = [_makeHall('h1'), _makeHall('h2')];
      when(() => mockRepository.getPendingHalls(page: 1))
          .thenAnswer((_) async => Right(halls));

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();

      expect(notifier.state.halls.length, 2);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
      expect(notifier.state.currentPage, 1);
    });

    test('loadPendingHalls sets error on failure', () async {
      when(() => mockRepository.getPendingHalls(page: 1)).thenAnswer(
        (_) async =>
            const Left(Failure.server(message: 'Server error')),
      );

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();

      expect(notifier.state.halls, isEmpty);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, 'Server error');
    });

    test('loadMore appends halls to existing list', () async {
      final page1 = List.generate(
        20,
        (i) => _makeHall('h$i'),
      );
      final page2 = [_makeHall('h20')];

      when(() => mockRepository.getPendingHalls(page: 1))
          .thenAnswer((_) async => Right(page1));
      when(() => mockRepository.getPendingHalls(page: 2))
          .thenAnswer((_) async => Right(page2));

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();
      expect(notifier.state.halls.length, 20);
      expect(notifier.state.hasMore, true);

      await notifier.loadMore();
      expect(notifier.state.halls.length, 21);
      expect(notifier.state.currentPage, 2);
      expect(notifier.state.hasMore, false);
    });

    test('loadMore does nothing when hasMore is false', () async {
      when(() => mockRepository.getPendingHalls(page: 1))
          .thenAnswer((_) async => Right([_makeHall('h1')]));

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();
      expect(notifier.state.hasMore, false);

      await notifier.loadMore();
      verifyNever(() => mockRepository.getPendingHalls(page: 2));
    });

    test('approveHall removes hall from list on success', () async {
      final halls = [_makeHall('h1'), _makeHall('h2'), _makeHall('h3')];
      when(() => mockRepository.getPendingHalls(page: 1))
          .thenAnswer((_) async => Right(halls));
      when(() => mockRepository.approveHall('h2'))
          .thenAnswer((_) async => const Right(null));

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();
      expect(notifier.state.halls.length, 3);

      await notifier.approveHall('h2');

      expect(notifier.state.halls.length, 2);
      expect(notifier.state.halls.any((h) => h.id == 'h2'), false);
      expect(notifier.state.isProcessing, false);
      expect(notifier.state.successMessage, 'Hall approved successfully.');
    });

    test('approveHall sets error on failure', () async {
      final halls = [_makeHall('h1')];
      when(() => mockRepository.getPendingHalls(page: 1))
          .thenAnswer((_) async => Right(halls));
      when(() => mockRepository.approveHall('h1')).thenAnswer(
        (_) async =>
            const Left(Failure.auth(message: 'Not authorized')),
      );

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();
      await notifier.approveHall('h1');

      expect(notifier.state.halls.length, 1);
      expect(notifier.state.error, 'Not authorized');
      expect(notifier.state.isProcessing, false);
    });

    test('rejectHall removes hall from list on success', () async {
      final halls = [_makeHall('h1'), _makeHall('h2')];
      when(() => mockRepository.getPendingHalls(page: 1))
          .thenAnswer((_) async => Right(halls));
      when(() => mockRepository.rejectHall('h1', 'Bad quality'))
          .thenAnswer((_) async => const Right(null));

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();
      await notifier.rejectHall('h1', 'Bad quality');

      expect(notifier.state.halls.length, 1);
      expect(notifier.state.halls.first.id, 'h2');
      expect(notifier.state.isProcessing, false);
      expect(notifier.state.successMessage, 'Hall rejected.');
    });

    test('rejectHall sets error on failure', () async {
      final halls = [_makeHall('h1')];
      when(() => mockRepository.getPendingHalls(page: 1))
          .thenAnswer((_) async => Right(halls));
      when(() => mockRepository.rejectHall('h1', 'reason')).thenAnswer(
        (_) async =>
            const Left(Failure.server(message: 'DB error')),
      );

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();
      await notifier.rejectHall('h1', 'reason');

      expect(notifier.state.halls.length, 1);
      expect(notifier.state.error, 'DB error');
    });

    test('clearError clears error state', () async {
      when(() => mockRepository.getPendingHalls(page: 1)).thenAnswer(
        (_) async =>
            const Left(Failure.server(message: 'Error')),
      );

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();
      expect(notifier.state.error, 'Error');

      notifier.clearError();
      expect(notifier.state.error, isNull);
    });

    test('clearSuccess clears success message', () async {
      final halls = [_makeHall('h1')];
      when(() => mockRepository.getPendingHalls(page: 1))
          .thenAnswer((_) async => Right(halls));
      when(() => mockRepository.approveHall('h1'))
          .thenAnswer((_) async => const Right(null));

      final notifier = HallApprovalNotifier(mockRepository);

      await notifier.loadPendingHalls();
      await notifier.approveHall('h1');
      expect(notifier.state.successMessage, isNotNull);

      notifier.clearSuccess();
      expect(notifier.state.successMessage, isNull);
    });
  });
}
