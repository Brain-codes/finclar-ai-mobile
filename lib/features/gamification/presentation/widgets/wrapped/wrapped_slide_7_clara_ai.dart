import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide7ClaraAI extends StatelessWidget {
  final WrappedTip data;

  const WrappedSlide7ClaraAI({super.key, required this.data});

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WrappedHeadline(data.title, padding: EdgeInsets.zero),
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
                      WrappedAutoText(
                        data.body,
                        maxLines: 6,
                        maxFontSize: 16,
                        minFontSize: 12,
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
