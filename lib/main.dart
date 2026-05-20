import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/logger_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Log.i('Finclar AI starting...');

  runApp(
    const ProviderScope(
      child: FinclarApp(),
    ),
  );
}
