import 'package:flutter/material.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class SplashPage2Illustration extends StatelessWidget {
  const SplashPage2Illustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/splash-2.png',
          fit: BoxFit.contain,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.scaffoldColor.withValues(alpha: 0),
                  context.scaffoldColor,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
