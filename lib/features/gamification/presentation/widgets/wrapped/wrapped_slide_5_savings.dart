import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../../data/models/wrapped_model.dart';
import 'wrapped_shared.dart';

class WrappedSlide5Savings extends StatelessWidget {
  final WrappedSavings data;
  final String symbol;

  const WrappedSlide5Savings({
    super.key,
    required this.data,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return WrappedSlide(
      backgroundImage: WrappedAssets.wrapped2BG,
      bg: WrappedColors.bgGreen,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              WrappedEntrance(
                delay: const Duration(milliseconds: 100),
                child: WrappedHeadline(data.headline, padding: EdgeInsets.zero),
              ),
              const SizedBox(height: 16),
              WrappedEntrance(
                delay: const Duration(milliseconds: 220),
                child: const WrappedSubtitle(
                  "You're building something real!",
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 28),
              // Savings rate card
              WrappedEntrance(
                delay: const Duration(milliseconds: 360),
                duration: const Duration(milliseconds: 700),
                slideFrom: const Offset(0, 40),
                child: _SavingsCard(
                  height: 196,
                  backgroundImage: WrappedAssets.wrapped5card1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Savings rate',
                        style: AppTypography.bodySmall.copyWith(
                          color: WrappedColors.white.withValues(alpha: 0.4),
                          fontFamily: 'Geist',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      WrappedCountUp(
                        value: data.savingsRate,
                        formatter: (v) => '${v.round()}%',
                        delay: const Duration(milliseconds: 550),
                        style: AppTypography.amountLarge.copyWith(
                          color: WrappedColors.neonGreen,
                          fontFamily: 'BricolageGrotesque',
                          fontVariations: const [FontVariation('wght', 700)],
                          fontSize: 36,
                          height: 40 / 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Amount saved card
              WrappedEntrance(
                delay: const Duration(milliseconds: 520),
                duration: const Duration(milliseconds: 700),
                slideFrom: const Offset(0, 40),
                child: _SavingsCard(
                  height: 207,
                  backgroundImage: WrappedAssets.wrapped5card2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Amount saved',
                        style: AppTypography.bodySmall.copyWith(
                          color: WrappedColors.white.withValues(alpha: 0.4),
                          fontFamily: 'Geist',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      WrappedCountUp(
                        value: data.totalSaved,
                        formatter: (v) => formatCurrency(
                          v,
                          symbol,
                          abbreviate: false,
                          withCommas: true,
                        ),
                        delay: const Duration(milliseconds: 700),
                        style: AppTypography.amountLarge.copyWith(
                          color: WrappedColors.neonGreen,
                          fontFamily: 'BricolageGrotesque',
                          fontVariations: const [FontVariation('wght', 700)],
                          fontSize: 36,
                          height: 40 / 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _SavingsProgressBar(
                              progress: (data.savingsRate / 100).clamp(
                                0.0,
                                1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0%', style: _labelStyle),
                                Text('50%', style: _labelStyle),
                                Text('100%', style: _labelStyle),
                              ],
                            ),
                          ],
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
      ),
    );
  }

  static final _labelStyle = AppTypography.labelXSmall.copyWith(
    color: WrappedColors.white.withValues(alpha: 0.5),
    fontFamily: 'Geist',
    fontSize: 14,
  );
}

class _SavingsCard extends StatelessWidget {
  final double height;
  final String? backgroundImage;
  final Widget child;
  const _SavingsCard({
    required this.height,
    this.backgroundImage,
    required this.child,
  });

  static const _fillGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0x1E1AFF09), Color(0x1E185A14)],
  );

  static const _borderGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    stops: [0.012, 1.0],
    colors: [Color(0x4018BF30), Color(0xCC33FF4A)],
  );

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBorderPainter(
        gradient: _borderGradient,
        radius: 0,
        strokeWidth: 1,
      ),
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(0),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (backgroundImage != null)
                Image.asset(
                  backgroundImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: Color(0xFF0F1C0E)),
                )
              else
                const ColoredBox(color: Color(0xFF0F1C0E)),
              const DecoratedBox(
                decoration: BoxDecoration(gradient: _fillGradient),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final LinearGradient gradient;
  final double radius;
  final double strokeWidth;
  const _GradientBorderPainter({
    required this.gradient,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) =>
      old.gradient != gradient ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}

class _SavingsProgressBar extends StatelessWidget {
  final double progress;
  const _SavingsProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final total = constraints.maxWidth;
        return WrappedGrowWidth(
          targetFraction: progress,
          delay: const Duration(milliseconds: 750),
          duration: const Duration(milliseconds: 900),
          builder: (context, fraction) {
            final filled = total * fraction;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Track
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF016350),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                // Fill
                Container(
                  height: 10,
                  width: filled,
                  decoration: BoxDecoration(
                    color: WrappedColors.neonGreen,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                // Needle marker at progress position
                Positioned(
                  left: filled - 2.5,
                  top: -3,
                  child: Container(
                    width: 5,
                    height: 16,
                    decoration: BoxDecoration(
                      color: WrappedColors.neonGreen,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: WrappedColors.white, width: 1),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
