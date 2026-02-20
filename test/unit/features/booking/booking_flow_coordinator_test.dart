import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/booking/domain/repositories/booking_repository.dart';
import 'package:hall_booking_platform/features/booking/presentation/providers/booking_flow_coordinator.dart';
import 'package:hall_booking_platform/features/booking/presentation/providers/booking_providers.dart';
import 'package:hall_booking_platform/features/payment/domain/repositories/payment_repository.dart';
import 'package:hall_booking_platform/features/payment/presentation/providers/payment_providers.dart';
import 'package:hall_booking_platform/services/fcm_service.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockFcmService extends Mock implements FcmService {}

void main() {
  late MockBookingRepository mockBookingRepo;
  late MockPaymentRepository mockPaymentRepo;
  late MockFcmService mockFcmService;
  late BookingCreationNotifier bookingNotifier;
  late PaymentNotifier paymentNotifier;
  late BookingFlowCoordinator coordinator;

  final testBooking = Booking(
    id: 'booking-1',
    userId: 'user-1',
    hallId: 'hall-1',
    slotId: 'slot-1',
    totalPrice: 500.0,
    paymentStatus: 'pending',
    bookingStatus: 'pending',
    createdAt: DateTime(2024, 1, 15),
  );

  setUp(() {
    mockBookingRepo = MockBookingRepository();
    mockPaymentRepo = MockPaymentRepository();
    mockFcmService = MockFcmService();
    bookingNotifier = BookingCreationNotifier(mockBookingRepo);
    paymentNotifier = PaymentNotifier(mockPaymentRepo);
    coordinator = BookingFlowCoordinator(
      bookingCreationNotifier: bookingNotifier,
      paymentRepository: mockPaymentRepo,
      paymentNotifier: paymentNotifier,
      fcmService: mockFcmService,
    );
  });

  group('BookingFlowCoordinator', () {
    test('initial state has slotSelection phase', () {
      expect(coordinator.state.phase, BookingFlowPhase.slotSelection);
      expect(coordinator.state.hallId, isNull);
      expect(coordinator.state.booking, isNull);
    });

    test('startFlow sets hallId and slotSelection phase', () {
      coordinator.startFlow(hallId: 'hall-1');

      expect(coordinator.state.phase, BookingFlowPhase.slotSelection);
      expect(coordinator.state.hallId, 'hall-1');
    });

    test('selectSlot moves to confirmation phase', () {
      coordinator.startFlow(hallId: 'hall-1');
      coordinator.selectSlot(slotId: 'slot-1');

      expect(coordinator.state.phase, BookingFlowPhase.confirmation);
      expect(coordinator.state.slotId, 'slot-1');
    });

    group('confirmBookingAndCreateOrder', () {
      test('successful booking + order creation returns orderId and moves to payment phase', () async {
        when(() => mockBookingRepo.createBooking(
              hallId: 'hall-1',
              slotId: 'slot-1',
            )).thenAnswer((_) async => Right(testBooking));

        when(() => mockPaymentRepo.createRazorpayOrder(
              bookingId: 'booking-1',
              amount: 500.0,
            )).thenAnswer((_) async => const Right('order_razorpay_123'));

        final orderId = await coordinator.confirmBookingAndCreateOrder(
          hallId: 'hall-1',
          slotId: 'slot-1',
        );

        expect(orderId, 'order_razorpay_123');
        expect(coordinator.state.phase, BookingFlowPhase.payment);
        expect(coordinator.state.booking, testBooking);
        expect(coordinator.state.razorpayOrderId, 'order_razorpay_123');
      });

      test('booking creation failure sets error phase', () async {
        when(() => mockBookingRepo.createBooking(
              hallId: 'hall-1',
              slotId: 'slot-1',
            )).thenAnswer((_) async =>
                const Left(Failure.conflict(message: 'Slot is no longer available')));

        final orderId = await coordinator.confirmBookingAndCreateOrder(
          hallId: 'hall-1',
          slotId: 'slot-1',
        );

        expect(orderId, isNull);
        expect(coordinator.state.phase, BookingFlowPhase.error);
        expect(coordinator.state.errorMessage, 'Slot is no longer available');
      });

      test('order creation failure after successful booking sets error phase', () async {
        when(() => mockBookingRepo.createBooking(
              hallId: 'hall-1',
              slotId: 'slot-1',
            )).thenAnswer((_) async => Right(testBooking));

        when(() => mockPaymentRepo.createRazorpayOrder(
              bookingId: 'booking-1',
              amount: 500.0,
            )).thenAnswer((_) async =>
                const Left(Failure.server(message: 'Razorpay order failed')));

        final orderId = await coordinator.confirmBookingAndCreateOrder(
          hallId: 'hall-1',
          slotId: 'slot-1',
        );

        expect(orderId, isNull);
        expect(coordinator.state.phase, BookingFlowPhase.error);
        expect(coordinator.state.errorMessage, 'Razorpay order failed');
        // Booking should still be stored even though order failed
        expect(coordinator.state.booking, testBooking);
      });

      test('transitions through creatingOrder phase during processing', () async {
        final phases = <BookingFlowPhase>[];
        coordinator.addListener((state) => phases.add(state.phase));

        when(() => mockBookingRepo.createBooking(
              hallId: 'hall-1',
              slotId: 'slot-1',
            )).thenAnswer((_) async => Right(testBooking));

        when(() => mockPaymentRepo.createRazorpayOrder(
              bookingId: 'booking-1',
              amount: 500.0,
            )).thenAnswer((_) async => const Right('order_123'));

        await coordinator.confirmBookingAndCreateOrder(
          hallId: 'hall-1',
          slotId: 'slot-1',
        );

        expect(phases, contains(BookingFlowPhase.creatingOrder));
        expect(phases.last, BookingFlowPhase.payment);
      });
    });

    group('payment callbacks', () {
      test('onPaymentVerified moves to completed phase and refreshes FCM token', () {
        when(() => mockFcmService.registerToken())
            .thenAnswer((_) async {});

        coordinator.onPaymentVerified();

        expect(coordinator.state.phase, BookingFlowPhase.completed);
        verify(() => mockFcmService.registerToken()).called(1);
      });

      test('onPaymentVerified handles FCM errors gracefully', () {
        when(() => mockFcmService.registerToken())
            .thenThrow(Exception('FCM unavailable'));

        // Should not throw
        coordinator.onPaymentVerified();

        expect(coordinator.state.phase, BookingFlowPhase.completed);
      });

      test('onPaymentFailed sets error phase with message', () {
        coordinator.onPaymentFailed('Payment cancelled by user');

        expect(coordinator.state.phase, BookingFlowPhase.error);
        expect(coordinator.state.errorMessage, 'Payment cancelled by user');
      });
    });

    group('reset', () {
      test('reset clears all state', () async {
        when(() => mockBookingRepo.createBooking(
              hallId: 'hall-1',
              slotId: 'slot-1',
            )).thenAnswer((_) async => Right(testBooking));

        when(() => mockPaymentRepo.createRazorpayOrder(
              bookingId: 'booking-1',
              amount: 500.0,
            )).thenAnswer((_) async => const Right('order_123'));

        await coordinator.confirmBookingAndCreateOrder(
          hallId: 'hall-1',
          slotId: 'slot-1',
        );

        coordinator.reset();

        expect(coordinator.state.phase, BookingFlowPhase.slotSelection);
        expect(coordinator.state.hallId, isNull);
        expect(coordinator.state.booking, isNull);
        expect(coordinator.state.razorpayOrderId, isNull);
        expect(coordinator.state.errorMessage, isNull);
      });

      test('reset also resets booking and payment notifiers', () async {
        when(() => mockBookingRepo.createBooking(
              hallId: 'hall-1',
              slotId: 'slot-1',
            )).thenAnswer((_) async => Right(testBooking));

        when(() => mockPaymentRepo.createRazorpayOrder(
              bookingId: 'booking-1',
              amount: 500.0,
            )).thenAnswer((_) async => const Right('order_123'));

        await coordinator.confirmBookingAndCreateOrder(
          hallId: 'hall-1',
          slotId: 'slot-1',
        );

        coordinator.reset();

        // BookingCreationNotifier should be reset
        expect(bookingNotifier.state.isLoading, false);
        expect(bookingNotifier.state.booking, isNull);
        expect(bookingNotifier.state.error, isNull);

        // PaymentNotifier should be reset
        expect(paymentNotifier.state.status, PaymentStatus.idle);
        expect(paymentNotifier.state.payment, isNull);
      });
    });

    group('end-to-end flow sequence', () {
      test('complete happy path: start → select → confirm → pay → verified', () async {
        when(() => mockBookingRepo.createBooking(
              hallId: 'hall-1',
              slotId: 'slot-1',
            )).thenAnswer((_) async => Right(testBooking));

        when(() => mockPaymentRepo.createRazorpayOrder(
              bookingId: 'booking-1',
              amount: 500.0,
            )).thenAnswer((_) async => const Right('order_razorpay_456'));

        when(() => mockFcmService.registerToken())
            .thenAnswer((_) async {});

        // Step 1: Start flow
        coordinator.startFlow(hallId: 'hall-1');
        expect(coordinator.state.phase, BookingFlowPhase.slotSelection);

        // Step 2: Select slot
        coordinator.selectSlot(slotId: 'slot-1');
        expect(coordinator.state.phase, BookingFlowPhase.confirmation);

        // Step 3: Confirm booking and create order
        final orderId = await coordinator.confirmBookingAndCreateOrder(
          hallId: 'hall-1',
          slotId: 'slot-1',
        );
        expect(orderId, 'order_razorpay_456');
        expect(coordinator.state.phase, BookingFlowPhase.payment);
        expect(coordinator.state.booking!.id, 'booking-1');

        // Step 4: Payment verified
        coordinator.onPaymentVerified();
        expect(coordinator.state.phase, BookingFlowPhase.completed);
      });
    });
  });

  group('BookingFlowState', () {
    test('copyWith preserves existing values when not overridden', () {
      const state = BookingFlowState(
        phase: BookingFlowPhase.payment,
        hallId: 'h1',
        slotId: 's1',
        razorpayOrderId: 'o1',
      );

      final updated = state.copyWith(phase: BookingFlowPhase.completed);

      expect(updated.phase, BookingFlowPhase.completed);
      expect(updated.hallId, 'h1');
      expect(updated.slotId, 's1');
      expect(updated.razorpayOrderId, 'o1');
    });

    test('copyWith clearError removes error message', () {
      const state = BookingFlowState(
        phase: BookingFlowPhase.error,
        errorMessage: 'something failed',
      );

      final updated = state.copyWith(
        phase: BookingFlowPhase.creatingOrder,
        clearError: true,
      );

      expect(updated.errorMessage, isNull);
    });

    test('copyWith clearBooking removes booking', () {
      final state = BookingFlowState(
        phase: BookingFlowPhase.completed,
        booking: Booking(
          id: 'b1',
          userId: 'u1',
          hallId: 'h1',
          slotId: 's1',
          totalPrice: 100,
          paymentStatus: 'completed',
          bookingStatus: 'confirmed',
          createdAt: DateTime(2024),
        ),
      );

      final updated = state.copyWith(clearBooking: true);
      expect(updated.booking, isNull);
    });
  });
}
