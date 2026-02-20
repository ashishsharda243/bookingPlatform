import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/services/razorpay_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class MockRazorpay extends Mock implements Razorpay {}

void main() {
  late MockRazorpay mockRazorpay;
  late RazorpayService service;

  // Captured callbacks from Razorpay.on() calls.
  late Function(PaymentSuccessResponse) onSuccess;
  late Function(PaymentFailureResponse) onError;
  late Function(ExternalWalletResponse) onWallet;

  setUp(() {
    mockRazorpay = MockRazorpay();

    // Capture the callbacks registered via Razorpay.on()
    when(() => mockRazorpay.on(any(), any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments[0] as String;
      final handler = invocation.positionalArguments[1] as Function;
      switch (event) {
        case Razorpay.EVENT_PAYMENT_SUCCESS:
          onSuccess = handler as Function(PaymentSuccessResponse);
        case Razorpay.EVENT_PAYMENT_ERROR:
          onError = handler as Function(PaymentFailureResponse);
        case Razorpay.EVENT_EXTERNAL_WALLET:
          onWallet = handler as Function(ExternalWalletResponse);
      }
    });

    service = RazorpayService(razorpay: mockRazorpay);
  });

  tearDown(() {
    when(() => mockRazorpay.clear()).thenReturn(null);
    service.dispose();
  });

  group('RazorpayService', () {
    test('registers all three event handlers on construction', () {
      verify(
        () => mockRazorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, any()),
      ).called(1);
      verify(
        () => mockRazorpay.on(Razorpay.EVENT_PAYMENT_ERROR, any()),
      ).called(1);
      verify(
        () => mockRazorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, any()),
      ).called(1);
    });

    test('openCheckout calls razorpay.open with correct options', () {
      when(() => mockRazorpay.open(any())).thenReturn(null);

      service.openCheckout(
        orderId: 'order_abc123',
        amount: 50000,
        bookingId: 'booking_xyz',
        description: 'Test Payment',
        prefillContact: '9876543210',
        prefillEmail: 'test@example.com',
      );

      final captured =
          verify(() => mockRazorpay.open(captureAny())).captured.single
              as Map<String, dynamic>;

      expect(captured['order_id'], 'order_abc123');
      expect(captured['amount'], 50000);
      expect(captured['name'], 'Hall Booking Platform');
      expect(captured['description'], 'Test Payment');
      expect(captured['notes'], {'booking_id': 'booking_xyz'});
      expect(captured['prefill'], {
        'contact': '9876543210',
        'email': 'test@example.com',
      });
    });

    test('openCheckout uses default description when not provided', () {
      when(() => mockRazorpay.open(any())).thenReturn(null);

      service.openCheckout(
        orderId: 'order_1',
        amount: 10000,
        bookingId: 'b1',
      );

      final captured =
          verify(() => mockRazorpay.open(captureAny())).captured.single
              as Map<String, dynamic>;

      expect(captured['description'], 'Hall Booking Payment');
      // prefill should be empty map when no contact/email provided
      expect(captured['prefill'], <String, dynamic>{});
    });

    test('emits PaymentSuccess on success callback', () async {
      final future = service.paymentResults.first;

      onSuccess(PaymentSuccessResponse(
        'pay_123',
        'order_abc',
        'sig_xyz',
        {'razorpay_payment_id': 'pay_123'},
      ));

      final result = await future;
      expect(result, isA<PaymentSuccess>());
      final success = result as PaymentSuccess;
      expect(success.paymentId, 'pay_123');
      expect(success.orderId, 'order_abc');
      expect(success.signature, 'sig_xyz');
    });

    test('emits PaymentFailure on error callback', () async {
      final future = service.paymentResults.first;

      onError(PaymentFailureResponse(2, 'Payment cancelled by user', null));

      final result = await future;
      expect(result, isA<PaymentFailure>());
      final failure = result as PaymentFailure;
      expect(failure.code, 2);
      expect(failure.message, 'Payment cancelled by user');
    });

    test('emits PaymentExternalWallet on wallet callback', () async {
      final future = service.paymentResults.first;

      onWallet(ExternalWalletResponse('paytm'));

      final result = await future;
      expect(result, isA<PaymentExternalWallet>());
      final wallet = result as PaymentExternalWallet;
      expect(wallet.walletName, 'paytm');
    });

    test('dispose clears razorpay and closes stream', () {
      when(() => mockRazorpay.clear()).thenReturn(null);

      service.dispose();

      verify(() => mockRazorpay.clear()).called(1);
    });

    test('paymentResults is a broadcast stream', () {
      // Should allow multiple listeners without error.
      service.paymentResults.listen((_) {});
      service.paymentResults.listen((_) {});
    });
  });
}
