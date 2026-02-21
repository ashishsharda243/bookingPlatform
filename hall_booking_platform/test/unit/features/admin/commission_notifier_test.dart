import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/admin/commission/data/repositories/commission_repository_impl.dart';
import 'package:hall_booking_platform/features/admin/commission/presentation/providers/commission_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockCommissionRepositoryImpl extends Mock
    implements CommissionRepositoryImpl {}

void main() {
  late MockCommissionRepositoryImpl mockRepository;
  late CommissionNotifier notifier;

  setUp(() {
    mockRepository = MockCommissionRepositoryImpl();
    notifier = CommissionNotifier(mockRepository);
  });

  group('loadCommission', () {
    test('sets currentPercentage on success', () async {
      when(() => mockRepository.getCommissionPercentage())
          .thenAnswer((_) async => const Right(10.0));

      await notifier.loadCommission();

      expect(notifier.state.currentPercentage, 10.0);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('sets error on failure', () async {
      when(() => mockRepository.getCommissionPercentage())
          .thenAnswer((_) async =>
              const Left(Failure.server(message: 'Server error')));

      await notifier.loadCommission();

      expect(notifier.state.currentPercentage, isNull);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, 'Server error');
    });
  });

  group('updateCommission', () {
    test('updates currentPercentage and sets success message', () async {
      when(() => mockRepository.setCommissionPercentage(15.0))
          .thenAnswer((_) async => const Right(null));

      await notifier.updateCommission(15.0);

      expect(notifier.state.currentPercentage, 15.0);
      expect(notifier.state.isUpdating, false);
      expect(notifier.state.successMessage, contains('15.0%'));
      expect(notifier.state.error, isNull);
    });

    test('sets error on failure', () async {
      when(() => mockRepository.setCommissionPercentage(15.0))
          .thenAnswer((_) async =>
              const Left(Failure.auth(message: 'Unauthorized')));

      await notifier.updateCommission(15.0);

      expect(notifier.state.isUpdating, false);
      expect(notifier.state.error, 'Unauthorized');
    });
  });

  group('clearError', () {
    test('clears error state', () async {
      when(() => mockRepository.getCommissionPercentage())
          .thenAnswer((_) async =>
              const Left(Failure.server(message: 'Error')));

      await notifier.loadCommission();
      expect(notifier.state.error, 'Error');

      notifier.clearError();
      expect(notifier.state.error, isNull);
    });
  });

  group('clearSuccess', () {
    test('clears success message', () async {
      when(() => mockRepository.setCommissionPercentage(10.0))
          .thenAnswer((_) async => const Right(null));

      await notifier.updateCommission(10.0);
      expect(notifier.state.successMessage, isNotNull);

      notifier.clearSuccess();
      expect(notifier.state.successMessage, isNull);
    });
  });
}
