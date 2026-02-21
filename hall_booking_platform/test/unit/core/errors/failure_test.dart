import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';

void main() {
  group('Failure', () {
    test('ServerFailure stores message and statusCode', () {
      const failure = ServerFailure(message: 'Server error', statusCode: 500);
      expect(failure.message, 'Server error');
      expect(failure.statusCode, 500);
    });

    test('ServerFailure statusCode is optional', () {
      const failure = ServerFailure(message: 'Server error');
      expect(failure.statusCode, isNull);
    });

    test('NetworkFailure stores message', () {
      const failure = NetworkFailure(message: 'No internet');
      expect(failure.message, 'No internet');
    });

    test('AuthFailure stores message', () {
      const failure = AuthFailure(message: 'Session expired');
      expect(failure.message, 'Session expired');
    });

    test('ValidationFailure stores message and fieldErrors', () {
      const failure = ValidationFailure(
        message: 'Invalid input',
        fieldErrors: {'email': 'Invalid email format'},
      );
      expect(failure.message, 'Invalid input');
      expect(failure.fieldErrors, {'email': 'Invalid email format'});
    });

    test('ValidationFailure fieldErrors is optional', () {
      const failure = ValidationFailure(message: 'Invalid');
      expect(failure.fieldErrors, isNull);
    });

    test('NotFoundFailure stores message', () {
      const failure = NotFoundFailure(message: 'Not found');
      expect(failure.message, 'Not found');
    });

    test('ConflictFailure stores message', () {
      const failure = ConflictFailure(message: 'Conflict');
      expect(failure.message, 'Conflict');
    });

    test('ForbiddenFailure stores message', () {
      const failure = ForbiddenFailure(message: 'Forbidden');
      expect(failure.message, 'Forbidden');
    });

    test('UnknownFailure stores message', () {
      const failure = UnknownFailure(message: 'Unknown error');
      expect(failure.message, 'Unknown error');
    });

    test('when dispatches to correct variant', () {
      const Failure failure = Failure.server(message: 'err', statusCode: 404);
      final result = failure.when(
        server: (msg, code) => 'server:$msg:$code',
        network: (msg) => 'network',
        auth: (msg) => 'auth',
        validation: (msg, errors) => 'validation',
        notFound: (msg) => 'notFound',
        conflict: (msg) => 'conflict',
        forbidden: (msg) => 'forbidden',
        unknown: (msg) => 'unknown',
      );
      expect(result, 'server:err:404');
    });

    test('equality works for same values', () {
      const a = ServerFailure(message: 'err', statusCode: 500);
      const b = ServerFailure(message: 'err', statusCode: 500);
      expect(a, equals(b));
    });

    test('inequality for different values', () {
      const a = ServerFailure(message: 'err', statusCode: 500);
      const b = ServerFailure(message: 'err', statusCode: 404);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      const original = ServerFailure(message: 'err', statusCode: 500);
      final modified = original.copyWith(message: 'new err');
      expect(modified.message, 'new err');
      expect((modified as ServerFailure).statusCode, 500);
    });
  });
}
