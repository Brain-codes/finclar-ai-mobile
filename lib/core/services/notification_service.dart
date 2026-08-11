import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../errors/app_exceptions.dart';
import 'logger_service.dart';
import 'storage_service.dart';

enum NotificationCategory {
  transaction,
  budget,
  group,
  aiInsight,
  challenge,
  unknown;

  static NotificationCategory fromData(Map<String, dynamic> data) {
    // The first group in each arm is the canonical `NotificationType` the
    // backend now sends; the rest are legacy payload spellings kept alive so
    // pushes queued before the enum landed still classify.
    return switch (data['category'] ?? data['type']) {
      'bank_sync_completed' ||
      'transaction' ||
      'transaction_alert' => transaction,
      'budget_near_limit' ||
      'budget' ||
      'budget_limit' ||
      'budget_warning' => budget,
      'group_invite' ||
      'friend_invite' ||
      'group' ||
      'group_activity' => group,
      'ai' || 'ai_insight' || 'insight' => aiInsight,
      'challenge' ||
      'challenge_reminder' ||
      'friday_savings' ||
      'no_spend' ||
      'budget_category' => challenge,
      _ => unknown,
    };
  }
}

typedef NotificationTapHandler = void Function(
  NotificationCategory category,
  Map<String, dynamic> data,
);

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  Log.i('FCM background message: ${message.messageId}');
}

abstract class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static String? _token;
  static String? get token => _token;

  static NotificationTapHandler? _onTap;

  static void setTapHandler(NotificationTapHandler handler) {
    _onTap = handler;
  }

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    Log.i('FCM permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        Log.w('APNS token not yet available — FCM token may be delayed');
      }
    }

    _token = await _messaging.getToken();
    Log.i('FCM token: $_token');
    if (_token != null) await _registerToken(_token!);

    _messaging.onTokenRefresh.listen((t) {
      _token = t;
      Log.i('FCM token refreshed');
      _registerToken(t);
    });

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onMessageOpened(initial);
  }

  static ApiClient? _apiClient;
  static ApiClient get _api => _apiClient ??= ApiClient();

  static String get _platform => Platform.isIOS
      ? 'ios'
      : Platform.isAndroid
      ? 'android'
      : 'web';

  /// Registers the current FCM token for push. Safe to call repeatedly — the
  /// backend upserts by token.
  ///
  /// Call after a successful login: [init] runs before the user is
  /// authenticated, and this endpoint is 🔒, so registration at startup only
  /// lands for an already-logged-in session.
  static Future<void> registerToken() async {
    final token = _token;
    if (token == null) return;
    await _registerToken(token);
  }

  static Future<void> _registerToken(String token) async {
    // 🔒 endpoint — a pre-login call would just 401. The token is cached in
    // [_token], so [registerToken] can retry once the user authenticates.
    if (await StorageService.getAccessToken() == null) {
      Log.d('FCM token cached; registering after login');
      return;
    }
    try {
      await _api.post<void>(
        ApiEndpoints.deviceTokens,
        body: {'token': token, 'platform': _platform},
      );
      Log.i('FCM token registered ($_platform)');
    } on AppException catch (e) {
      // Never surface this — push registration failing must not block the app.
      Log.e('FCM token registration failed', error: e.message);
    }
  }

  /// Debug only — asks the backend to push to this account's registered
  /// devices, so token registration and FCM can be confirmed before testing
  /// anything feature-specific.
  static Future<void> sendTestPush() => _api.post<void>(ApiEndpoints.testPush);

  static void _onForegroundMessage(RemoteMessage message) {
    final category = NotificationCategory.fromData(message.data);
    Log.i('FCM foreground [$category]: ${message.notification?.title}');
  }

  static void _onMessageOpened(RemoteMessage message) {
    final category = NotificationCategory.fromData(message.data);
    Log.i('FCM opened app [$category]: ${message.data}');
    _onTap?.call(category, message.data);
  }
}
