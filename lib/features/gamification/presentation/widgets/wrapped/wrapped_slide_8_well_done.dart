import 'package:finclar_ai/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide8WellDone extends StatelessWidget {
  final WrappedBadge data;

  const WrappedSlide8WellDone({super.key, required this.data});

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
                "You're killing it!",
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              Expanded(child: _WellDoneCard(data: data)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WellDoneCard extends StatelessWidget {
  static const double _imageSize = 293;

  final WrappedBadge data;

  const _WellDoneCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(color: WrappedColors.cardOverlay),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                WrappedAssets.wrapped8BGInner,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        WrappedAssets.wrapped8Image,
                        // width: _imageSize,
                        height: _imageSize - 50,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: _imageSize,
                          height: _imageSize,
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
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
  final WrappedBadge data;
  const _CardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        WrappedAutoText(
          data.headline,
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
          maxFontSize: 16,
          minFontSize: 12,
          style: AppTypography.bodySmall.copyWith(
            color: WrappedColors.whiteMuted,
            fontFamily: 'Geist',
            fontVariations: const [FontVariation('wght', 400)],
            fontSize: 16,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
