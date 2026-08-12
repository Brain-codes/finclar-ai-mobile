import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide1Intro extends StatelessWidget {
  final WrappedCover cover;

  const WrappedSlide1Intro({super.key, required this.cover});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return WrappedSlide(
      backgroundImage: WrappedAssets.introVectorLine,
      child: Stack(
        children: [
          const Positioned.fill(
            child: WrappedParticles(
              count: 14,
              colors: [Colors.white, WrappedColors.neonGreen],
              minSize: 1.5,
              maxSize: 3.5,
              period: Duration(milliseconds: 8000),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                WrappedEntrance(
                  delay: const Duration(milliseconds: 150),
                  child: WrappedShimmerSweep(
                    delay: const Duration(milliseconds: 750),
                    child: WrappedHeadline(
                      cover.headline.isNotEmpty
                          ? cover.headline
                          : 'Your ${DateFormat('MMMM').format(DateTime(cover.year, cover.month))} '
                                '${cover.year} money wrapped',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                WrappedEntrance(
                  delay: const Duration(milliseconds: 320),
                  child: const WrappedSubtitle(
                    'See how you earned, saved and spent',
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: Center(
                      child: WrappedEntrance(
                        delay: const Duration(milliseconds: 420),
                        duration: const Duration(milliseconds: 850),
                        curve: Curves.elasticOut,
                        slideFrom: const Offset(0, 60),
                        scaleFrom: 0.7,
                        child: WrappedFloat(
                          amplitude: 8,
                          child: Image.asset(
                            WrappedAssets.introHero,
                            height: h * 0.43,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => SizedBox(height: h * 0.48),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
