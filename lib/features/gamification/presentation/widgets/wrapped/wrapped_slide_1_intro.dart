import 'package:flutter/material.dart';
import 'wrapped_shared.dart';

class WrappedSlide1Intro extends StatelessWidget {
  const WrappedSlide1Intro({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return WrappedSlide(
      backgroundImage: WrappedAssets.introVectorLine,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const WrappedHeadline('Your Money wrapped'),
            const SizedBox(height: 8),
            const WrappedSubtitle('See how you earned, saved and spent'),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child: Center(
                  child: Image.asset(
                    WrappedAssets.introHero,
                    height: h * 0.43,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => SizedBox(height: h * 0.48),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
