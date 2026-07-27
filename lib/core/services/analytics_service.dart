import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'logger_service.dart';

/// Single entry point for product analytics (Firebase Analytics) and crash
/// reporting (Crashlytics). Features never touch `FirebaseAnalytics` or
/// `FirebaseCrashlytics` directly — always go through `Analytics`, the same way
/// logging goes through `Log` and messaging through `NotificationService`.
abstract class Analytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Attach to `GoRouter(observers: [Analytics.observer])` to auto-log a
  /// `screen_view` for every navigation with no per-screen code.
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Routes uncaught Flutter and platform errors into Crashlytics. Analytics
  /// collection itself needs no wiring — it starts on Firebase init.
  static Future<void> init() async {
    FlutterError.onError = _crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
    Log.i('Analytics + Crashlytics initialized');
  }

  // ── Identity ───────────────────────────────────────────────────────────────

  /// Ties events to a user. Kept to primitives so `core` stays decoupled from
  /// feature models — callers pass fields off their own `UserModel`.
  static Future<void> identify({
    required String id,
    String? currency,
    bool? isEmailVerified,
  }) async {
    await _analytics.setUserId(id: id);
    await _crashlytics.setUserIdentifier(id);
    if (currency != null) {
      await _analytics.setUserProperty(name: 'currency', value: currency);
    }
    if (isEmailVerified != null) {
      await _analytics.setUserProperty(
        name: 'email_verified',
        value: isEmailVerified.toString(),
      );
    }
  }

  static Future<void> clearUser() async {
    await _analytics.setUserId(id: null);
  }

  // ── Generic event ────────────────────────────────────────────────────────

  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e, st) {
      Log.w('Analytics logEvent failed: $name', error: e, stackTrace: st);
    }
  }

  // ── Named business events ────────────────────────────────────────────────
  // Track meaningful moments, not button presses. These are the questions the
  // app owner actually asks: are people onboarding, linking banks, logging
  // spending, using Clara, budgeting, and creating groups?

  static Future<void> signUp({required String method}) =>
      logEvent('sign_up', parameters: {'method': method});

  static Future<void> login({required String method}) =>
      logEvent('login', parameters: {'method': method});

  static Future<void> bankLinked({String? bankName}) {
    final params = <String, Object>{};
    if (bankName != null) params['bank_name'] = bankName;
    return logEvent('bank_linked', parameters: params);
  }

  static Future<void> expenseAdded({
    required String method,
    double? amount,
    String? currency,
  }) {
    final params = <String, Object>{'method': method};
    if (amount != null) params['amount'] = amount;
    if (currency != null) params['currency'] = currency;
    return logEvent('expense_added', parameters: params);
  }

  static Future<void> receiptScanned() => logEvent('receipt_scanned');

  static Future<void> budgetCreated({double? amount}) {
    final params = <String, Object>{};
    if (amount != null) params['amount'] = amount;
    return logEvent('budget_created', parameters: params);
  }

  static Future<void> groupCreated() => logEvent('group_created');

  static Future<void> claraMessageSent() => logEvent('clara_message_sent');

  // ── Manual crash reporting ────────────────────────────────────────────────

  static Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) =>
      _crashlytics.recordError(error, stack, reason: reason, fatal: fatal);
}
