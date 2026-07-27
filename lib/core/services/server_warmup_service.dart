import 'package:dio/dio.dart';
import '../api/api_endpoints.dart';
import 'logger_service.dart';

/// Fires a lightweight, unauthenticated GET at the backend health check to wake
/// a cold-started server as early as possible, before the home screen fires its
/// heavier authenticated queries. Fire-and-forget — the response is ignored and
/// failures never surface to the user.
abstract class ServerWarmupService {
  static void ping() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    dio
        .get<void>(ApiEndpoints.health)
        .then((_) => Log.d('Server warm-up ping ok'))
        .catchError((Object e) {
      Log.w('Server warm-up ping failed (ignored): $e');
      return null;
    }).whenComplete(dio.close);
  }
}
