import 'package:finclar_ai/shared/icons/app_icons.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_bar_chart.dart';

class IncomeExpenseData {
  final String month;
  final double income;
  final double expense;

  const IncomeExpenseData({
    required this.month,
    required this.income,
    required this.expense,
  });
}

class IncomeExpenseChartSection extends StatefulWidget {
  final bool isEmpty;
  final List<IncomeExpenseData> data;
  final double totalIncome;
  final double totalExpense;

  const IncomeExpenseChartSection({
    super.key,
    this.isEmpty = false,
    this.data = const [
      IncomeExpenseData(month: 'Jan', income: 1800000, expense: 90000),
      IncomeExpenseData(month: 'Feb', income: 2000000, expense: 120000),
      IncomeExpenseData(month: 'Mar', income: 1600000, expense: 200000),
      IncomeExpenseData(month: 'Apr', income: 2200000, expense: 80000),
      IncomeExpenseData(month: 'May', income: 2000000, expense: 150000),
    ],
    this.totalIncome = 2000000,
    this.totalExpense = 150000,
  });

  @override
  State<IncomeExpenseChartSection> createState() =>
      _IncomeExpenseChartSectionState();
}

class _IncomeExpenseChartSectionState extends State<IncomeExpenseChartSection> {
  int _selectedPeriodIndex = 4;

  static const _periods = ['1y', 'Jan', 'Feb', 'Mar', 'Apr', 'May'];

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
            AppStrings.incomeAndExpense,
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          if (widget.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.walletLine,
                      size: 20,
                      color: context.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your income and expense details will be listed here',
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
            // _PeriodFilter(
            //   periods: _periods,
            //   selectedIndex: _selectedPeriodIndex,
            //   onSelect: (i) => setState(() => _selectedPeriodIndex = i),
            // ),
            const SizedBox(height: AppSpacing.base),
            AppBarChart(
              height: 160,
              groups: widget.data
                  .map(
                    (d) => AppBarChartGroup(
                      label: d.month,
                      bars: [
                        AppBarChartBar(
                          value: d.income,
                          color: AppColors.transparent,
                          striped: true,
                          stripeColor: AppColors.primary,
                          stripeOpacity: 1,
                        ),
                        AppBarChartBar(
                          value: d.expense,
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
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                _LegendItem(
                  color: AppColors.primary,
                  label: AppStrings.incomeLabel,
                  amount: '₦${_formatAmount(widget.totalIncome)}',
                ),
                const SizedBox(width: AppSpacing.xl),
                _LegendItem(
                  color: AppColors.categoryTransport,
                  label: AppStrings.expenseLabel,
                  amount: '₦${_formatAmount(widget.totalExpense)}',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatAmount(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}m';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }
}

class _PeriodFilter extends StatelessWidget {
  final List<String> periods;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _PeriodFilter({
    required this.periods,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(periods.length, (i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: AppRadius.radiusFull,
                border: Border.all(
                  color: isSelected ? AppColors.primary : context.borderColor,
                ),
              ),
              child: Text(
                periods[i],
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected ? AppColors.white : context.textSecondary,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelXSmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            Text(
              amount,
              style: AppTypography.bodySmall.copyWith(
                color: context.textPrimary,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
