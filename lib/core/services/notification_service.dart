import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'logger_service.dart';

enum NotificationCategory {
  transaction,
  budget,
  group,
  aiInsight,
  unknown;

  static NotificationCategory fromData(Map<String, dynamic> data) {
    return switch (data['category'] ?? data['type']) {
      'transaction' || 'transaction_alert' => transaction,
      'budget' || 'budget_limit' || 'budget_warning' => budget,
      'group' || 'group_activity' => group,
      'ai' || 'ai_insight' || 'insight' => aiInsight,
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

  static Future<void> _registerToken(String token) async {
    // No device-token registration endpoint exists in docs/API.md yet.
    // When the backend adds one, call it here via ApiClient.
    Log.d('FCM token ready for backend registration: ${token.substring(0, 12)}...');
  }

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
