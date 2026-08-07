import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/deep_link_service.dart';
import '../../core/services/logger_service.dart';

/// Routes taps on the iOS home screen widget. Mounted once inside the signed-in
/// shell so a tap can only navigate somewhere the user is allowed to be.
class WidgetLinkListener extends StatefulWidget {
  final Widget child;
  const WidgetLinkListener({super.key, required this.child});

  @override
  State<WidgetLinkListener> createState() => _WidgetLinkListenerState();
}

class _WidgetLinkListenerState extends State<WidgetLinkListener> {
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = DeepLinkService.widgetStream.listen(_go);

    final pending = DeepLinkService.pendingWidgetRoute;
    if (pending != null) {
      DeepLinkService.pendingWidgetRoute = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _go(pending));
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _go(String route) {
    if (!mounted) return;
    Log.d('[Widget] Navigating to $route');
    DeepLinkService.pendingWidgetRoute = null;
    context.push(route);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
