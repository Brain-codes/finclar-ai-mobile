import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Full-screen loading overlay with a blur + faint scrim and a
/// CupertinoActivityIndicator. Wrap your Scaffold body in a Stack and
/// conditionally include this widget:
///
/// ```dart
/// Stack(
///   children: [
///     _content(),
///     if (isLoading) const AppLoadingOverlay(),
///   ],
/// )
/// ```
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: Colors.black.withValues(alpha: 0.15),
            alignment: Alignment.center,
            child: const CupertinoActivityIndicator(radius: 14),
          ),
        ),
      ),
    );
  }
}
