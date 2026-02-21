import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/services/dio_client.dart';

/// A Dio interceptor that captures the rejected [DioException] for assertions.
class _CaptureInterceptor extends Interceptor {
  DioException? captured;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    captured = err;
    handler.next(err);
  }
}

void main() {
  group('ErrorInterceptor', () {
    late Dio dio;
    late _CaptureInterceptor capture;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      capture = _CaptureInterceptor();
      // ErrorInterceptor runs first, then capture grabs the result.
      dio.interceptors.addAll([
        ErrorInterceptor(),
        capture,
      ]);
      // Use a fake adapter that returns controlled responses.
    });

    Future<void> triggerError({required int statusCode}) async {
      dio.httpClientAdapter = _FakeAdapter(statusCode: statusCode);
      try {
        await dio.get('/test');
      } on DioException {
        // expected
      }
    }

    test('maps 401 to AuthFailure', () async {
      await triggerError(statusCode: 401);
      expect(capture.captured, isNotNull);
      final failure = capture.captured!.error as Failure;
      expect(failure, isA<AuthFailure>());
    });

    test('maps 403 to ForbiddenFailure', () async {
      await triggerError(statusCode: 403);
      expect(capture.captured, isNotNull);
      final failure = capture.captured!.error as Failure;
      expect(failure, isA<ForbiddenFailure>());
    });

    test('maps 404 to NotFoundFailure', () async {
      await triggerError(statusCode: 404);
      expect(capture.captured, isNotNull);
      final failure = capture.captured!.error as Failure;
      expect(failure, isA<NotFoundFailure>());
    });

    test('maps 409 to ConflictFailure', () async {
      await triggerError(statusCode: 409);
      expect(capture.captured, isNotNull);
      final failure = capture.captured!.error as Failure;
      expect(failure, isA<ConflictFailure>());
    });

    test('maps 500 to ServerFailure with statusCode', () async {
      await triggerError(statusCode: 500);
      expect(capture.captured, isNotNull);
      final failure = capture.captured!.error as Failure;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('maps connection error to NetworkFailure', () async {
      dio.httpClientAdapter = _SocketExceptionAdapter();
      try {
        await dio.get('/test');
      } on DioException {
        // expected
      }
      expect(capture.captured, isNotNull);
      final failure = capture.captured!.error as Failure;
      expect(failure, isA<NetworkFailure>());
    });

    test('maps connection timeout to NetworkFailure', () async {
      dio.httpClientAdapter = _TimeoutAdapter();
      try {
        await dio.get('/test');
      } on DioException {
        // expected
      }
      expect(capture.captured, isNotNull);
      final failure = capture.captured!.error as Failure;
      expect(failure, isA<NetworkFailure>());
    });
  });
}

/// Fake adapter that returns an HTTP error response with the given status code.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.statusCode});

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

/// Fake adapter that throws a SocketException to simulate no network.
class _SocketExceptionAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw const SocketException('No internet');
  }

  @override
  void close({bool force = false}) {}
}

/// Fake adapter that throws a DioException with connectionTimeout type.
class _TimeoutAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionTimeout,
    );
  }

  @override
  void close({bool force = false}) {}
}
