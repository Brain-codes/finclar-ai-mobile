import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class BudgetExpenseChartSection extends StatelessWidget {
  const BudgetExpenseChartSection({super.key});

  static const _categories = [
    _BarData('Food', 0.48, AppColors.categoryFood, AppColors.categoryFoodBg),
    _BarData('Trans', 0.3, AppColors.categoryTransport, AppColors.categoryTransportBg),
    _BarData('Heal', 0.24, AppColors.categoryHealth, AppColors.categoryHealthBg),
    _BarData('Shop', 1.0, AppColors.categoryShopping, AppColors.categoryShoppingBg),
    _BarData('Rent', 0.48, AppColors.primary, AppColors.primaryMuted),
  ];

  static const _yLabels = ['₦2m', '₦1.5m', '₦500k', '₦0'];

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Expense and budget',
            style: AppTypography.labelMedium.copyWith(
              color: context.textQuaternary,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _yLabels
                      .map(
                        (l) => Text(
                          l,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Bars
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _categories
                        .map((d) => _Bar(data: d))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Divider(color: context.borderColor, height: 1, thickness: 1),
          const SizedBox(height: AppSpacing.md),
          _LegendRow(
            color: AppColors.categoryFood,
            label: 'Expense',
            amount: '₦250,000',
          ),
          const SizedBox(height: AppSpacing.sm),
          _LegendRow(
            color: AppColors.categoryShopping,
            label: 'Shopping',
            amount: '₦120,000',
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final String label;
  final double fraction;
  final Color color;
  final Color bgColor;

  const _BarData(this.label, this.fraction, this.color, this.bgColor);
}

class _Bar extends StatelessWidget {
  final _BarData data;
  const _Bar({required this.data});

  static const _maxBarHeight = 78.0;

  @override
  Widget build(BuildContext context) {
    final spentH = _maxBarHeight * data.fraction;
    final budgetH = _maxBarHeight * 0.3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _SingleBar(height: spentH, color: data.color),
            const SizedBox(width: 2),
            _SingleBar(height: budgetH, color: data.bgColor),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          data.label,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _SingleBar extends StatelessWidget {
  final double height;
  final Color color;
  const _SingleBar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: height.clamp(4.0, 78.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          amount,
          style: AppTypography.bodySmall.copyWith(
            color: context.textQuaternary,
            fontSize: 12,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
      ],
    );
  }
}
