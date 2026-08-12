import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_bar_chart.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';
import '../../data/models/budget_model.dart';

class BudgetExpenseChartSection extends ConsumerWidget {
  final List<AllocationModel> allocations;
  final double totalBudget;
  final double totalExpense;

  const BudgetExpenseChartSection({
    super.key,
    required this.allocations,
    required this.totalBudget,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);

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
            'Budget vs expense',
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'What you budgeted for each category against what you spent',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
          if (allocations.isEmpty)
            _empty(context)
          else ...[
            const SizedBox(height: AppSpacing.xl),
            AppBarChart(
              height: 160,
              maxGroupSpacing: 40,
              minGroupSpacing: 24,
              formatY: (v) => formatCurrency(v, symbol, abbreviate: true),
              groups: allocations
                  .map(
                    (a) => AppBarChartGroup(
                      label: a.categoryName,
                      bars: [
                        AppBarChartBar(
                          value: a.amountAllocated,
                          color: AppColors.transparent,
                          striped: true,
                          stripeColor: AppColors.primary,
                          stripeOpacity: 1,
                        ),
                        AppBarChartBar(
                          value: a.spent,
                          color: AppColors.transparent,
                          striped: true,
                          stripeColor: AppColors.categoryTransport,
                          stripeOpacity: 1,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            if (allocations.length > 5) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.chevronRight,
                    size: 12,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Swipe the chart to see all ${allocations.length} categories',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _LegendItem(
              stripeColor: AppColors.primary,
              label: 'Budget',
              amount: formatCurrency(totalBudget, symbol,
                  abbreviate: false, withCommas: true),
            ),
            const SizedBox(height: AppSpacing.base),
            _LegendItem(
              stripeColor: AppColors.categoryTransport,
              label: 'Expense',
              amount: formatCurrency(totalExpense, symbol,
                  abbreviate: false, withCommas: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Column(
            children: [
              Icon(AppIcons.chart, size: 20, color: context.textSecondary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Allocate your budget to see this breakdown',
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

class _LegendItem extends StatelessWidget {
  final Color stripeColor;
  final String label;
  final String amount;

  const _LegendItem({
    required this.stripeColor,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: CustomPaint(
            size: const Size(8, 16),
            painter: AppStripePainter(
              stripeColor: stripeColor,
              spacing: 3.0,
              strokeWidth: 1.5,
              angleDegrees: 45.0,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: context.textPrimary),
        ),
        const Spacer(),
        Text(
          amount,
          style: AppTypography.bodySmall.copyWith(
            color: context.textPrimary,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
      ],
    );
  }
}
