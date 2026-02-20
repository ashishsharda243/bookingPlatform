import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/payment/domain/entities/payment.dart';
import 'package:hall_booking_platform/features/payment/domain/repositories/payment_repository.dart';
import 'package:hall_booking_platform/features/payment/presentation/providers/payment_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockPaymentRepository mockRepository;
  late PaymentNotifier notifier;

  setUp(() {
    mockRepository = MockPaymentRepository();
    notifier = PaymentNotifier(mockRepository);
  });

  group('PaymentNotifier', () {
    test('initial state is idle', () {
      expect(notifier.state.status, PaymentStatus.idle);
      expect(notifier.state.payment, isNull);
      expect(notifier.state.errorMessage, isNull);
    });

    test('startProcessing sets status to processing', () {
      notifier.startProcessing();
      expect(notifier.state.status, PaymentStatus.processing);
    });

    test('verifyPayment transitions to success on valid verification',
        () async {
      const payment = Payment(
        id: 'p1',
        bookingId: 'b1',
        razorpayPaymentId: 'pay_123',
        status: 'completed',
        amount: 500,
      );

      when(() => mockRepository.verifyPayment(
            bookingId: 'b1',
            razorpayPaymentId: 'pay_123',
            razorpayOrderId: 'order_1',
            razorpaySignature: 'sig_valid',
          )).thenAnswer((_) async => const Right(payment));

      await notifier.verifyPayment(
        bookingId: 'b1',
        razorpayPaymentId: 'pay_123',
        razorpayOrderId: 'order_1',
        razorpaySignature: 'sig_valid',
      );

      expect(notifier.state.status, PaymentStatus.success);
      expect(notifier.state.payment, payment);
      expect(notifier.state.errorMessage, isNull);
    });

    test('verifyPayment transitions to failed on verification failure',
        () async {
      when(() => mockRepository.verifyPayment(
            bookingId: 'b1',
            razorpayPaymentId: 'pay_123',
            razorpayOrderId: 'order_1',
            razorpaySignature: 'sig_bad',
          )).thenAnswer((_) async =>
              const Left(Failure.auth(message: 'Invalid signature')));

      await notifier.verifyPayment(
        bookingId: 'b1',
        razorpayPaymentId: 'pay_123',
        razorpayOrderId: 'order_1',
        razorpaySignature: 'sig_bad',
      );

      expect(notifier.state.status, PaymentStatus.failed);
      expect(notifier.state.errorMessage, 'Invalid signature');
      expect(notifier.state.payment, isNull);
    });

    test('onPaymentFailed sets status to failed with message', () {
      notifier.onPaymentFailed('Payment cancelled by user');

      expect(notifier.state.status, PaymentStatus.failed);
      expect(notifier.state.errorMessage, 'Payment cancelled by user');
    });

    test('reset returns to idle state', () {
      notifier.startProcessing();
      notifier.onPaymentFailed('error');
      notifier.reset();

      expect(notifier.state.status, PaymentStatus.idle);
      expect(notifier.state.payment, isNull);
      expect(notifier.state.errorMessage, isNull);
    });

    test('verifyPayment goes through verifying state', () async {
      final states = <PaymentStatus>[];
      notifier.addListener((state) => states.add(state.status));

      when(() => mockRepository.verifyPayment(
            bookingId: any(named: 'bookingId'),
            razorpayPaymentId: any(named: 'razorpayPaymentId'),
            razorpayOrderId: any(named: 'razorpayOrderId'),
            razorpaySignature: any(named: 'razorpaySignature'),
          )).thenAnswer((_) async => const Right(Payment(
            id: 'p1',
            bookingId: 'b1',
            razorpayPaymentId: 'pay_1',
            status: 'completed',
            amount: 100,
          )));

      await notifier.verifyPayment(
        bookingId: 'b1',
        razorpayPaymentId: 'pay_1',
        razorpayOrderId: 'order_1',
        razorpaySignature: 'sig_1',
      );

      // Should have gone through verifying → success
      expect(states, contains(PaymentStatus.verifying));
      expect(states.last, PaymentStatus.success);
    });
  });
}
