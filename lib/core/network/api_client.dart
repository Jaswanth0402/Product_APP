import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/core/constants/app_constants.dart';
import 'package:product_app/core/utils/app_error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
ApiClient apiClient(Ref ref) => ApiClient();

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Response<T>> post<T>(String path, {Object? data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Response<T>> put<T>(String path, {Object? data}) async {
    try {
      return await _dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(path);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppError _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return AppError.timeout(e.message ?? 'Request timed out');
      case DioExceptionType.connectionError:
        return AppError.network(e.message ?? 'No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        // ignore: avoid_dynamic_calls
        final message = e.response?.data?['message'] as String? ??
            e.message ??
            'Server error';
        if (statusCode >= 500) return AppError.server(message, statusCode);
        if (statusCode == 404) return AppError.notFound(message);
        return AppError.server(message, statusCode);
      default:
        return AppError.unknown(e.message ?? 'An unexpected error occurred');
    }
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // In production, use a proper logger (e.g. logger package)
    assert(() {
      // ignore: avoid_print
      print('[API] ${options.method} ${options.uri}');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[API ERROR] ${err.type}: ${err.message}');
      return true;
    }());
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      handler.next(response);
    } else {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
    }
  }
}
