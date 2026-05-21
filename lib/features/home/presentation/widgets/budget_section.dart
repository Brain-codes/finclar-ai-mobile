import 'package:finclar_ai/shared/icons/app_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class BudgetCategory {
  final String name;
  final Color color;
  final double spent;
  final double total;

  const BudgetCategory({
    required this.name,
    required this.color,
    required this.spent,
    required this.total,
  });

  double get percentage => total > 0 ? (spent / total).clamp(0.0, 1.0) : 0;
}

class BudgetSection extends StatelessWidget {
  final bool isEmpty;
  final List<BudgetCategory> categories;
  final VoidCallback? onBreakdownTap;

  const BudgetSection({
    super.key,
    this.isEmpty = false,
    this.categories = const [
      BudgetCategory(
        name: AppStrings.categoryFood,
        color: AppColors.categoryFood,
        spent: 250000,
        total: 300000,
      ),
      BudgetCategory(
        name: AppStrings.categoryTransportation,
        color: AppColors.categoryTransport,
        spent: 150000,
        total: 250000,
      ),
      BudgetCategory(
        name: AppStrings.categoryHealth,
        color: AppColors.categoryHealth,
        spent: 100000,
        total: 300000,
      ),
      BudgetCategory(
        name: AppStrings.categoryShopping,
        color: AppColors.categoryShopping,
        spent: 0,
        total: 150000,
      ),
    ],
    this.onBreakdownTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.budgetLabel,
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.budget,
                      size: 20,
                      color: context.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your budget will be listed here',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: _BudgetDonutChart(categories: categories),
                ),
                const SizedBox(width: AppSpacing.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories
                        .map((c) => _BudgetItemRow(category: c))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
          ],
          if (!isEmpty)
            AppButton(
              label: AppStrings.seeBreakdown,
              onTap: onBreakdownTap ?? () {},
              variant: AppButtonVariant.ghost,
              height: 44,
            ),
        ],
      ),
    );
  }
}

class _BudgetDonutChart extends StatelessWidget {
  final List<BudgetCategory> categories;

  const _BudgetDonutChart({required this.categories});

  @override
  Widget build(BuildContext context) {
    final totalSpent = categories.fold<double>(0, (sum, c) => sum + c.spent);
    final sections = categories
        .where((c) => c.spent > 0)
        .map(
          (c) => PieChartSectionData(
            color: c.color,
            value: c.spent,
            title: '',
            radius: 24,
            showTitle: false,
          ),
        )
        .toList();

    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          color: context.borderColor,
          value: 1,
          title: '',
          radius: 24,
          showTitle: false,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            centerSpaceRadius: 36,
            sections: sections,
            sectionsSpace: 2,
            pieTouchData: PieTouchData(enabled: false),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatAmount(totalSpent),
              style: AppTypography.bodySmall.copyWith(
                color: context.textPrimary,
                fontVariations: const [FontVariation('wght', 600)],
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'spent',
              style: AppTypography.labelXSmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '₦${(amount / 1000000).toStringAsFixed(1)}m';
    if (amount >= 1000) return '₦${(amount / 1000).toStringAsFixed(0)}k';
    return '₦${amount.toStringAsFixed(0)}';
  }
}

class _BudgetItemRow extends StatelessWidget {
  final BudgetCategory category;

  const _BudgetItemRow({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  category.name,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textPrimary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.radiusXs,
                  child: LinearProgressIndicator(
                    value: category.percentage,
                    backgroundColor: context.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(category.color),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const SizedBox(width: 12),
              Text(
                '₦${_format(category.spent)} / ₦${_format(category.total)}',
                style: AppTypography.labelXSmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}m';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)},000';
    return v.toStringAsFixed(0);
  }
}
