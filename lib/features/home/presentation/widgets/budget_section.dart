import 'package:finclar_ai/shared/icons/app_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../budget/data/models/budget_model.dart';
import '../../../budget/providers/budget_providers.dart';
import '../../../expenses/presentation/widgets/expense_category_utils.dart';

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

class BudgetSection extends ConsumerWidget {
  final VoidCallback? onBreakdownTap;

  const BudgetSection({super.key, this.onBreakdownTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final budget = ref.watch(budgetProvider);

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
          budget.when(
            loading: () => const _BudgetSkeleton(),
            error: (_, _) => _empty(context),
            data: (s) => (s.budget == null || s.budget!.allocations.isEmpty)
                ? _empty(context)
                : _BudgetContent(
                    categories: _toCategories(s.budget!),
                    symbol: symbol,
                    onBreakdownTap: onBreakdownTap,
                  ),
          ),
        ],
      ),
    );
  }

  static List<BudgetCategory> _toCategories(BudgetModel b) => b.allocations
      .map(
        (a) => BudgetCategory(
          name: a.categoryName,
          color: expenseCategoryColor(a.categoryName),
          spent: a.spent,
          total: a.amountAllocated,
        ),
      )
      .toList();

  Widget _empty(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.budget, size: 20, color: context.textSecondary),
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
      );
}

class _BudgetContent extends StatelessWidget {
  final List<BudgetCategory> categories;
  final String symbol;
  final VoidCallback? onBreakdownTap;

  const _BudgetContent({
    required this.categories,
    required this.symbol,
    this.onBreakdownTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BudgetDonutChart(categories: categories, symbol: symbol),
        const SizedBox(height: AppSpacing.base),
        for (int i = 0; i < categories.length; i++) ...[
          _BudgetItemRow(category: categories[i], symbol: symbol),
          if (i < categories.length - 1) ...[
            const SizedBox(height: AppSpacing.base),
            Divider(height: 1, color: context.borderColor),
            const SizedBox(height: AppSpacing.base),
          ],
        ],
        const SizedBox(height: AppSpacing.base),
        AppButton(
          label: AppStrings.seeBreakdown,
          onTap: onBreakdownTap ?? () {},
          variant: AppButtonVariant.ghost,
          height: 44,
        ),
      ],
    );
  }
}

class _BudgetSkeleton extends StatelessWidget {
  const _BudgetSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppSkeleton.circle(size: 120),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                AppSkeleton.circle(size: 10),
                SizedBox(width: AppSpacing.xs),
                AppSkeleton.text(width: 90),
                Spacer(),
                AppSkeleton.text(width: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetDonutChart extends StatelessWidget {
  final List<BudgetCategory> categories;
  final String symbol;

  const _BudgetDonutChart({required this.categories, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final totalSpent = categories.fold<double>(0, (sum, c) => sum + c.spent);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final ringRadius = size * 0.18;
        final centerRadius = size * 0.28;

        final sections = categories
            .where((c) => c.spent > 0)
            .map(
              (c) => PieChartSectionData(
                color: c.color,
                value: c.spent,
                title: '',
                radius: ringRadius,
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
              radius: ringRadius,
              showTitle: false,
            ),
          );
        }

        return AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: centerRadius,
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
                      fontSize: size * 0.045,
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
          ),
        );
      },
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '$symbol${(amount / 1000000).toStringAsFixed(1)}m';
    if (amount >= 1000) return '$symbol${(amount / 1000).toStringAsFixed(0)}k';
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}

class _BudgetItemRow extends StatelessWidget {
  final BudgetCategory category;
  final String symbol;

  const _BudgetItemRow({required this.category, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: category.color,
            borderRadius: AppRadius.radiusXs,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            category.name,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$symbol${_format(category.spent)} / $symbol${_format(category.total)}',
          style: AppTypography.bodySmall.copyWith(
            color: context.textPrimary,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
      ],
    );
  }

  String _format(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}m';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)},000';
    return v.toStringAsFixed(0);
  }
}
