import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import '../services/logger_service.dart';
import 'api_endpoints.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

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
      AuthInterceptor(secureStorage, _dio),
      RetryInterceptor(_dio),
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
      Log.apiResponse('GET', path, response.statusCode ?? 0, response.data);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromData,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PaginatedResponse<T>> getPaginated<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromItem,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      Log.apiResponse('GET', path, response.statusCode ?? 0, response.data);
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromItem,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Walks every page of a paginated endpoint and returns the flattened list.
  /// Use for list endpoints the app treats as "give me everything" (categories,
  /// banks, friends, groups, etc.) now that the backend paginates them.
  Future<List<T>> getAllPaginated<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromItem,
    int pageSize = 100,
  }) async {
    final items = <T>[];
    var page = 1;
    while (true) {
      final query = <String, dynamic>{
        ...?queryParams,
        'page': page,
        'page_size': pageSize,
      };
      final response = await getPaginated<T>(
        path,
        queryParams: query,
        fromItem: fromItem,
      );
      items.addAll(response.items);
      if (!response.hasNext || response.items.isEmpty) break;
      page++;
    }
    return items;
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await _dio.post(path, data: body);
      Log.apiResponse('POST', path, response.statusCode ?? 0, response.data);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromData,
      );
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
      Log.apiResponse('PUT', path, response.statusCode ?? 0, response.data);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromData,
      );
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
      Log.apiResponse('PATCH', path, response.statusCode ?? 0, response.data);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromData,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParams);
      Log.apiResponse('DELETE', path, response.statusCode ?? 0, response.data);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromData,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// [method] covers endpoints that take multipart on a verb other than POST —
  /// e.g. `PATCH /expenses/{id}`, which accepts a receipt alongside the DTO.
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    T Function(dynamic)? fromData,
    void Function(int, int)? onProgress,
    String method = 'POST',
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: formData,
        options: Options(method: method),
        onSendProgress: onProgress,
      );
      Log.apiResponse(method, path, response.statusCode ?? 0, response.data);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromData,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    Log.e('API Error', error: e.message, stackTrace: e.stackTrace);
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException(
          'Connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final backendMessage = _extractMessage(e.response?.data);
        final message = backendMessage ?? 'Something went wrong';
        if (statusCode == 401) return UnauthorizedException(message);
        if (statusCode == 403) return ForbiddenException(message);
        if (statusCode == 404) return NotFoundException(message);
        if (statusCode == 409) return ConflictException(message);
        if (statusCode == 413) {
          // Prefer the server's wording when it sends one — it may name the
          // actual limit. The friendly line is only a fallback.
          return ValidationException(
            backendMessage ??
                'That file is too large. Please attach a smaller image.',
          );
        }
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
