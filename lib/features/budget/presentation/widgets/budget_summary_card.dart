import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double availableBudget;
  final double spentAmount;
  final double totalBudget;
  final int daysLeft;
  final String month;
  final String currencySymbol;
  final VoidCallback? onMonthTap;

  const BudgetSummaryCard({
    super.key,
    required this.availableBudget,
    required this.spentAmount,
    required this.totalBudget,
    required this.daysLeft,
    required this.month,
    required this.currencySymbol,
    this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final spentFraction =
        totalBudget > 0 ? (spentAmount / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available budget',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatCurrency(availableBudget),
                      style: AppTypography.headingMedium.copyWith(
                        color: context.textQuaternary,
                        fontFamily: AppFonts.body,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onMonthTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        month,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textQuaternary,
                          fontSize: 12,
                          fontVariations: const [FontVariation('wght', 500)],
                        ),
                      ),
                      if (onMonthTap != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          AppIcons.chevronDown,
                          size: 14,
                          color: context.textQuaternary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          _StackedProgressBar(spentFraction: spentFraction),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_fmtShort(spentAmount)} / ${_fmtShort(totalBudget)} spent',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '$daysLeft days left',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textQuaternary,
                  fontSize: 12,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double v) =>
      formatCurrency(v, currencySymbol, abbreviate: false, withCommas: true);

  String _fmtShort(double v) =>
      formatCurrency(v, currencySymbol, abbreviate: false, withCommas: true);
}

class _StackedProgressBar extends StatelessWidget {
  final double spentFraction;

  const _StackedProgressBar({required this.spentFraction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final total = constraints.maxWidth;
        final spentW = total * spentFraction;
        final remW = total - spentW;
        return ClipRRect(
          borderRadius: AppRadius.radiusXs,
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                if (spentW > 0) Container(width: spentW, color: AppColors.primary),
                if (remW > 0)
                  SizedBox(
                    width: remW,
                    height: 14,
                    child: CustomPaint(
                      painter: AppStripePainter(
                        backgroundColor: context.primaryMuted,
                        stripeColor: AppColors.primary.withValues(alpha: 0.25),
                        spacing: 5,
                        strokeWidth: 1.5,
                        angleDegrees: 45,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
