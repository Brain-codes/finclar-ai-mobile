import 'package:finclar_ai/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide6Personality extends StatelessWidget {
  final WrappedPersonality data;

  const WrappedSlide6Personality({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return WrappedSlide(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const WrappedHeadline(
                'Your money personality',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              Expanded(child: _PersonalityCard(data: data)),
            ],
          ),
        ),
      ),
    );
  }
}

// Image bleeds 32px above card top (Figma: image y=24141, card y=24173)
class _PersonalityCard extends StatelessWidget {
  static const double _imageBleed = 32;
  static const double _imageSize = 293;

  final WrappedPersonality data;

  const _PersonalityCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Card body — fills to bottom, offset down for image bleed
        Container(
          decoration: const BoxDecoration(color: WrappedColors.cardOverlay),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                WrappedAssets.wrapped6BGInner,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              // Content pinned to bottom
              // Character illustration — bleeds above card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        WrappedAssets.wrapped6Image,
                        width: _imageSize,
                        height: _imageSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: _imageSize,
                          height: _imageSize,
                        ),
                      ),
                    ),
                    _CardContent(data: data),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardContent extends StatelessWidget {
  final WrappedPersonality data;
  const _CardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        WrappedAutoText(
          data.name,
          maxLines: 2,
          maxFontSize: 24,
          minFontSize: 16,
          style: AppTypography.displayLarge.copyWith(
            color: WrappedColors.white,
            fontFamily: 'BricolageGrotesque',
            fontVariations: const [FontVariation('wght', 600)],
            fontSize: 24,
            letterSpacing: -0.72,
            height: 32 / 24,
          ),
        ),
        const SizedBox(height: 8),
        WrappedAutoText(
          data.description,
          maxLines: 6,
          maxFontSize: 14,
          minFontSize: 11,
          style: AppTypography.bodySmall.copyWith(
            color: WrappedColors.white,
            fontFamily: 'Geist',
            fontVariations: const [FontVariation('wght', 500)],
            fontSize: 14,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Row(
          children: const [
            _Tag(
              label: 'Goal-oriented',
              bg: WrappedColors.tagGoal,
              textColor: WrappedColors.tagConsistent,
            ),

            _Tag(
              label: 'Consistent',
              bg: WrappedColors.tagConsistent,
              textColor: WrappedColors.tagGoal,
            ),

            _Tag(
              label: 'Treat-friendly',
              bg: WrappedColors.tagTreat,
              textColor: Color(0xFFCED672),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const _Tag({required this.label, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg),
      child: Text(
        label,
        style: AppTypography.labelXSmall.copyWith(
          color: textColor,
          fontFamily: 'Geist',
          fontVariations: const [FontVariation('wght', 600)],
          fontSize: 14,
          height: 20 / 14,
        ),
      ),
    );
  }
}
