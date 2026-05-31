import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import 'wrapped_shared.dart';

class WrappedSlide7ClaraAI extends StatelessWidget {
  const WrappedSlide7ClaraAI({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return WrappedSlide(
      child: Stack(
        children: [
          // ── Glow blobs ───────────────────────────────────────────────────
          // Ellipse 3: large, bleeds top and left
          Positioned(
            top: h * (-367 / 852),
            left: -41,
            child: _GlowEllipse(
              color: const Color(0xFFFA5874),
              size: h * (734 / 852),
            ),
          ),
          // Ellipse 2: mid-left, 124px from top
          Positioned(
            top: h * (124 / 852),
            left: -163,
            child: _GlowEllipse(
              color: const Color(0xFFFF607B),
              size: h * (416 / 852),
            ),
          ),
          // Ellipse 1: large orange, 353px from top
          Positioned(
            top: h * (353 / 852),
            left: -82,
            child: _GlowEllipse(
              color: const Color(0xFFF8853D),
              size: h * (670 / 852),
            ),
          ),
          // ── White fade overlay (approximation of Figma radial gradient) ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.46, 0.66, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white,
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: WrappedHeadline(
                    "Here's an idea for you",
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 24),
                // Robot image — left-aligned, 40px from left (Figma x offset)
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Image.asset(
                    WrappedAssets.aiRobot,
                    width: 232,
                    height: 273,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        const SizedBox(width: 232, height: 273),
                  ),
                ),
                const SizedBox(height: 12),
                // Insight text — sits on the white bg area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your food spending is ₦28,000/month. That is ₦347,000 a year and you\'ve been consistent for 4 months straight which amounts ₦247,000/month.',
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF101010),
                          fontFamily: 'Geist',
                          fontVariations: const [FontVariation('wght', 500)],
                          fontSize: 16,
                          height: 24 / 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Trimming by a third could unlock an extra ₦180k annually',
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF101010),
                          fontFamily: 'Geist',
                          fontVariations: const [FontVariation('wght', 500)],
                          fontSize: 16,
                          height: 24 / 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Recommendation card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: WrappedColors.claraRedCard,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(WrappedAssets.wrapped7card1),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommendation',
                          style: AppTypography.labelSmall.copyWith(
                            color: WrappedColors.claraRed,
                            fontFamily: 'Geist',
                            fontVariations: const [FontVariation('wght', 500)],
                            fontSize: 14,
                            height: 20 / 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Set a food budget of ₦75,000 next month. You were 19% over in March, a small nudge here has the highest impact',
                          style: AppTypography.bodySmall.copyWith(
                            color: WrappedColors.tagConsistent,
                            fontFamily: 'Geist',
                            fontVariations: const [FontVariation('wght', 500)],
                            fontSize: 14,
                            height: 20 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowEllipse extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowEllipse({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
