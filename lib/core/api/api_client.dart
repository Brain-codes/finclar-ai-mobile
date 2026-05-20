import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import '../services/logger_service.dart';
import 'api_endpoints.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({FlutterSecureStorage? storage}) {
    final secureStorage = storage ?? const FlutterSecureStorage();

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      LoggingInterceptor(),
    ]);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await _dio.post(path, data: body);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await _dio.put(path, data: body);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await _dio.patch(path, data: body);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await _dio.delete(path);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    T Function(dynamic)? fromData,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onProgress,
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    Log.e('API Error', error: e);
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = _extractMessage(e.response?.data) ?? 'Something went wrong';
        if (statusCode == 401) return UnauthorizedException(message);
        if (statusCode == 403) return ForbiddenException(message);
        if (statusCode == 404) return NotFoundException(message);
        if (statusCode == 422) return ValidationException(message);
        if (statusCode >= 500) return ServerException(message);
        return ApiException(message, statusCode: statusCode);
      default:
        return AppException(e.message ?? 'An unexpected error occurred');
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}
