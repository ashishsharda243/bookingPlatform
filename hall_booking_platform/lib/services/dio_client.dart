import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/failure.dart';
import 'supabase_service.dart';

/// Provides the Supabase REST base URL from environment variables.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');

/// Interceptor that injects the Supabase JWT access token into every request.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = SupabaseService.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Interceptor that maps HTTP error status codes and network errors
/// to typed [Failure] instances.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Failure failure;

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.error is SocketException) {
      failure = const Failure.network(
        message: 'No internet connection. Please check your network.',
      );
    } else {
      failure = switch (err.response?.statusCode) {
        401 => const Failure.auth(
            message: 'Session expired. Please log in again.',
          ),
        403 => const Failure.forbidden(
            message: 'You do not have permission for this action.',
          ),
        404 => const Failure.notFound(
            message: 'Resource not found.',
          ),
        409 => const Failure.conflict(
            message: 'Resource conflict. Please refresh and try again.',
          ),
        _ => Failure.server(
            message: err.message ?? 'An unexpected error occurred.',
            statusCode: err.response?.statusCode,
          ),
      };
    }

    handler.reject(
      DioException(requestOptions: err.requestOptions, error: failure),
    );
  }
}

/// Pre-configured Dio client with auth and error interceptors.
class DioClient {
  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: '$_supabaseUrl/rest/v1',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  final Dio _dio;

  Dio get dio => _dio;
}

/// Riverpod provider for the [DioClient].
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});
