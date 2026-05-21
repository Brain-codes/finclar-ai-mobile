import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';

class SpendingCard extends StatelessWidget {
  final bool isEmpty;
  final String amount;
  final double percentage;
  final String insightText;
  final VoidCallback? onTap;

  const SpendingCard({
    super.key,
    this.isEmpty = false,
    this.amount = '₦250,000.00',
    this.percentage = 0.15,
    this.insightText = AppStrings.aiInsight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.thisMonthSpending,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.textQuaternary,
                    fontSize: 14,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                Icon(
                  AppIcons.chevronRight,
                  color: context.textSecondary,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (isEmpty)
              Text(
                'You\'ve not made any expense yet.',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              )
            else ...[
              Text(
                amount,
                style: AppTypography.amountSmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SpendingBar(percentage: percentage),
              const SizedBox(height: AppSpacing.sm),
              Text(
                insightText,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpendingBar extends StatelessWidget {
  final double percentage;

  const _SpendingBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    const height = 14.0;
    const gap = 4.0;
    const radius = Radius.circular(AppRadius.xs);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final clampedPct = percentage.clamp(0.0, 1.0);
          final totalWidth = constraints.maxWidth;
          final spentWidth = clampedPct == 0
              ? 0.0
              : (totalWidth * clampedPct - gap / 2).clamp(0.0, totalWidth);
          final remainWidth = clampedPct == 1
              ? 0.0
              : (totalWidth * (1 - clampedPct) - gap / 2).clamp(
                  0.0,
                  totalWidth,
                );

          return Row(
            children: [
              if (spentWidth > 0)
                ClipRRect(
                  borderRadius: BorderRadius.all(radius),
                  child: SizedBox(
                    width: spentWidth,
                    height: height,
                    child: ColoredBox(color: AppColors.primary),
                  ),
                ),
              if (spentWidth > 0 && remainWidth > 0) const SizedBox(width: gap),
              if (remainWidth > 0)
                ClipRRect(
                  borderRadius: BorderRadius.all(radius),
                  child: CustomPaint(
                    size: Size(remainWidth, height),
                    painter: AppStripePainter(
                      stripeColor: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
