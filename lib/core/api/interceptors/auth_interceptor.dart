import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/app_constants.dart';
import '../../services/auth_state_service.dart';
import '../../services/logger_service.dart';
import '../api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  // A single in-flight refresh shared by every request that 401s at the same
  // time. The refresh token rotates server-side (each refresh returns a new
  // one), so firing concurrent refreshes would invalidate each other and force
  // a logout — everyone must await the same call.
  Future<String?>? _refreshCall;

  static const String _retriedKey = '__retried_after_refresh';

  AuthInterceptor(this._storage, this._dio);

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

    // Already retried once with a fresh token and still 401 — the new token is
    // genuinely rejected, so stop looping and log out.
    if (err.requestOptions.extra[_retriedKey] == true) {
      Log.e(
        'Request ${err.requestOptions.path} still 401 after refresh — '
        'logging out.',
      );
      await authStateService.logOut();
      handler.next(err);
      return;
    }

    // NOTE: no await before this line — the `??=` runs synchronously for every
    // concurrent 401, so they all share one refresh instead of racing.
    final newToken = await _refresh();
    if (newToken == null) {
      handler.next(err);
      return;
    }

    try {
      handler.resolve(await _retry(err.requestOptions, newToken));
    } catch (_) {
      handler.next(err);
    }
  }

  Future<String?> _refresh() {
    return _refreshCall ??=
        _performRefresh().whenComplete(() => _refreshCall = null);
  }

  Future<String?> _performRefresh() async {
    final storedRefresh =
        await _storage.read(key: AppConstants.refreshTokenKey);
    if (storedRefresh == null) {
      Log.e('401 but no refresh token is stored — logging out.');
      await authStateService.logOut();
      return null;
    }

    Log.d('Access token rejected (401) — attempting refresh.');
    try {
      final refreshDio = Dio(
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

      Log.d('Token refresh succeeded.');
      return newAccess;
    } catch (e) {
      Log.e('Token refresh failed — logging out', error: e);
      await authStateService.logOut();
      return null;
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String accessToken,
  ) async {
    options.headers['Authorization'] = 'Bearer $accessToken';
    options.extra[_retriedKey] = true;
    // Reuse the main Dio so the retry still logs; the retried request carries
    // the _retriedKey flag so a second 401 logs out instead of looping.
    return _dio.fetch(options);
  }
}
