import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../../services/logger_service.dart';

/// Retries idempotent GET requests that fail due to timeouts or connection
/// errors (e.g. a cold-starting backend). Non-GET requests and real HTTP
/// error responses (4xx/5xx) are never retried.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;

  static const String _attemptKey = 'retry_attempt';

  bool _isRetryable(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') return false;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        return false;
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;

    if (!_isRetryable(err) || attempt >= AppConstants.maxRetries) {
      handler.next(err);
      return;
    }

    final nextAttempt = attempt + 1;
    final delay = Duration(milliseconds: 400 * (1 << attempt));
    Log.w(
      'Retry $nextAttempt/${AppConstants.maxRetries} for '
      '[${options.method}] ${options.path} after ${delay.inMilliseconds}ms '
      '(${err.type.name})',
    );
    await Future.delayed(delay);

    options.extra[_attemptKey] = nextAttempt;
    try {
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
