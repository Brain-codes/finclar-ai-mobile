import 'package:dio/dio.dart';
import '../../services/logger_service.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Log.api(options.method, options.uri.toString(), body: options.data);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Log.api(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      body: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.e(
      '[${err.requestOptions.method}] ${err.requestOptions.uri}',
      error: err.message,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
