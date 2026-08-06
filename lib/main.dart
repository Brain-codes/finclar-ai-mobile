import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/analytics_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/notification_routing.dart';
import 'core/services/notification_service.dart';
import 'core/services/server_warmup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Log.i('Finclar AI starting...');

  ServerWarmupService.ping();

  try {
    await Firebase.initializeApp();
    await Analytics.init();
    await NotificationService.init();
    registerNotificationRouting();
  } catch (e, st) {
    Log.e('Firebase init failed', error: e, stackTrace: st);
  }

  // Outside the Firebase try — a Firebase failure must not disable invites.
  await DeepLinkService.init();

  runApp(
    const ProviderScope(
      child: FinclarApp(),
    ),
  );
}
