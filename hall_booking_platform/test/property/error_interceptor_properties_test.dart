import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' as glados;
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/services/dio_client.dart';

/// Capture interceptor for property tests.
class _CaptureInterceptor extends Interceptor {
  DioException? captured;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    captured = err;
    handler.next(err);
  }
}

/// Fake adapter returning a specific status code.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode);
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"error": "test"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<Failure> captureFailureForStatus(int statusCode) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
  final capture = _CaptureInterceptor();
  dio.interceptors.addAll([ErrorInterceptor(), capture]);
  dio.httpClientAdapter = _FakeAdapter(statusCode);

  try {
    await dio.get('/test');
  } on DioException {
    // expected
  }

  return capture.captured!.error as Failure;
}

void main() {
  /// **Validates: Requirements 20.4, 20.6, 16.4, 16.5**
  group('ErrorInterceptor properties', () {
    glados.Glados(glados.any.intInRange(400, 599)).test(
      'any HTTP error status code produces a non-null Failure',
      (statusCode) async {
        final failure = await captureFailureForStatus(statusCode);
        expect(failure, isNotNull);
      },
    );

    glados.Glados(glados.any.intInRange(400, 599)).test(
      'known status codes always map to their specific Failure type',
      (statusCode) async {
        final failure = await captureFailureForStatus(statusCode);

        switch (statusCode) {
          case 401:
            expect(failure, isA<AuthFailure>());
          case 403:
            expect(failure, isA<ForbiddenFailure>());
          case 404:
            expect(failure, isA<NotFoundFailure>());
          case 409:
            expect(failure, isA<ConflictFailure>());
          default:
            expect(failure, isA<ServerFailure>());
            expect((failure as ServerFailure).statusCode, statusCode);
        }
      },
    );

    glados.Glados(glados.any.intInRange(400, 599)).test(
      'every Failure has a non-empty message',
      (statusCode) async {
        final failure = await captureFailureForStatus(statusCode);

        final message = failure.when(
          server: (msg, _) => msg,
          network: (msg) => msg,
          auth: (msg) => msg,
          validation: (msg, _) => msg,
          notFound: (msg) => msg,
          conflict: (msg) => msg,
          forbidden: (msg) => msg,
          unknown: (msg) => msg,
        );

        expect(message, isNotEmpty);
      },
    );
  });
}
