import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/app_constants.dart';
import '../../services/auth_state_service.dart';
import '../../services/logger_service.dart';
import '../api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  // Guards against concurrent refresh attempts.
  bool _isRefreshing = false;
  final List<Completer<String?>> _queue = [];

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshEndpoint =
        err.requestOptions.path.contains(ApiEndpoints.refreshToken);

    if (!isUnauthorized || isRefreshEndpoint) {
      handler.next(err);
      return;
    }

    final storedRefresh =
        await _storage.read(key: AppConstants.refreshTokenKey);
    if (storedRefresh == null) {
      await authStateService.logOut();
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // Enqueue — wait for the in-progress refresh to resolve.
      final completer = Completer<String?>();
      _queue.add(completer);
      final newToken = await completer.future;
      if (newToken != null) {
        handler.resolve(await _retry(err.requestOptions, newToken));
      } else {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;
    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
        ),
      );
      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': storedRefresh},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final newAccess = data['access_token'] as String;
      final newRefresh = data['refresh_token'] as String;

      await Future.wait([
        _storage.write(key: AppConstants.tokenKey, value: newAccess),
        _storage.write(key: AppConstants.refreshTokenKey, value: newRefresh),
      ]);

      _resolveQueue(newAccess);
      handler.resolve(await _retry(err.requestOptions, newAccess));
    } catch (e) {
      Log.e('Token refresh failed — logging out', error: e);
      _resolveQueue(null);
      await authStateService.logOut();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _resolveQueue(String? token) {
    for (final c in _queue) {
      c.complete(token);
    }
    _queue.clear();
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String accessToken,
  ) async {
    final retryDio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
      ),
    );
    options.headers['Authorization'] = 'Bearer $accessToken';
    return retryDio.fetch(options);
  }
}
