import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'expense_category_utils.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final double total;

  /// Amount per category, computed server-side over every expense matching
  /// the current filters — never derived from the paginated list, which only
  /// holds the pages loaded so far.
  final Map<String, double> categoryTotals;
  final int selectedMonth;
  final VoidCallback onMonthTap;

  /// Set when a custom date range is filtering the list — the pill would
  /// otherwise name a month the totals below it don't belong to.
  final String? periodLabel;

  const ExpenseSummaryCard({
    super.key,
    required this.total,
    required this.categoryTotals,
    required this.selectedMonth,
    required this.onMonthTap,
    this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final monthName =
        periodLabel ?? DateFormat('MMMM').format(DateTime(0, selectedMonth));
    final formatted = NumberFormat('#,##0.00').format(total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total expense',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦$formatted',
                      style: AppTypography.amountLarge.copyWith(
                        color: context.textQuaternary,
                        fontSize: 24,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onMonthTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: AppRadius.radiusFull,
                    ),
                    child: Text(
                      monthName,
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
            ExpenseCategoryBar(categoryTotals: categoryTotals),
            const SizedBox(height: AppSpacing.md),
            ExpenseCategoryLegend(categoryTotals: categoryTotals),
          ],
        ),
      ),
    );
  }
}

// ─── Stacked category bar ─────────────────────────────────────────────────────

class ExpenseCategoryBar extends StatelessWidget {
  final Map<String, double> categoryTotals;
  const ExpenseCategoryBar({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final segments =
        categoryTotals.entries.where((e) => e.value > 0).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        return ClipRRect(
          borderRadius: AppRadius.radiusXs,
          child: Row(
            children: segments.map((entry) {
              final width = totalWidth * (entry.value / total);
              return Container(
                width: width,
                height: 14,
                color: expenseCategoryColor(entry.key),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ─── Category legend ──────────────────────────────────────────────────────────

class ExpenseCategoryLegend extends StatelessWidget {
  final Map<String, double> categoryTotals;
  const ExpenseCategoryLegend({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    final categories = categoryTotals.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();
    return Wrap(
      spacing: AppSpacing.base,
      runSpacing: AppSpacing.xs,
      children: categories.map((cat) => _LegendItem(category: cat)).toList(),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String category;
  const _LegendItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: expenseCategoryColor(category),
            borderRadius: AppRadius.radiusXs,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          category,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
