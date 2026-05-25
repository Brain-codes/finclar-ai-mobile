import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double availableBudget;
  final double spentAmount;
  final double totalBudget;
  final int daysLeft;
  final String month;
  final VoidCallback? onMonthTap;

  const BudgetSummaryCard({
    super.key,
    required this.availableBudget,
    required this.spentAmount,
    required this.totalBudget,
    required this.daysLeft,
    required this.month,
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
                  child: Text(
                    month,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textQuaternary,
                      fontSize: 12,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
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

  /// e.g. 500000.0 → "₦500,000.00"
  String _formatCurrency(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₦$whole.${parts[1]}';
  }

  /// e.g. 250000 → "₦250,000", 5000000 → "₦5,000,000"
  String _fmtShort(double v) {
    final s = v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₦$s';
  }
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
