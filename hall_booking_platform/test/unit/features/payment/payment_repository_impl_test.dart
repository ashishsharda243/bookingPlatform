import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:hall_booking_platform/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockPaymentRemoteDataSource extends Mock
    implements PaymentRemoteDataSource {}

void main() {
  late MockPaymentRemoteDataSource mockDataSource;
  late PaymentRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockPaymentRemoteDataSource();
    repository = PaymentRepositoryImpl(mockDataSource);
  });

  group('PaymentRepositoryImpl.verifyPayment', () {
    const bookingId = 'booking-123';
    const paymentId = 'pay_abc';
    const orderId = 'order_xyz';
    const signature = 'sig_valid';

    test('returns Payment on successful verification', () async {
      when(() => mockDataSource.verifyPayment(
            bookingId: bookingId,
            razorpayPaymentId: paymentId,
            razorpayOrderId: orderId,
            razorpaySignature: signature,
          )).thenAnswer((_) async => {
            'message': 'Payment verified successfully',
            'booking_id': bookingId,
            'booking_status': 'confirmed',
            'payment_status': 'completed',
          });

      final result = await repository.verifyPayment(
        bookingId: bookingId,
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        razorpaySignature: signature,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (payment) {
          expect(payment.bookingId, bookingId);
          expect(payment.razorpayPaymentId, paymentId);
          expect(payment.status, 'completed');
        },
      );
    });

    test('returns AuthFailure on PaymentVerificationException', () async {
      when(() => mockDataSource.verifyPayment(
            bookingId: bookingId,
            razorpayPaymentId: paymentId,
            razorpayOrderId: orderId,
            razorpaySignature: signature,
          )).thenThrow(
              PaymentVerificationException('Invalid payment signature'));

      final result = await repository.verifyPayment(
        bookingId: bookingId,
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        razorpaySignature: signature,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Invalid payment signature');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnknownFailure on unexpected exception', () async {
      when(() => mockDataSource.verifyPayment(
            bookingId: bookingId,
            razorpayPaymentId: paymentId,
            razorpayOrderId: orderId,
            razorpaySignature: signature,
          )).thenThrow(Exception('Network error'));

      final result = await repository.verifyPayment(
        bookingId: bookingId,
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        razorpaySignature: signature,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('PaymentRepositoryImpl.createRazorpayOrder', () {
    test('returns ServerFailure since order creation is server-side', () async {
      final result = await repository.createRazorpayOrder(
        bookingId: 'b1',
        amount: 500.0,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
