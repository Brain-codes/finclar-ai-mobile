import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';
import '../../../expenses/presentation/widgets/expense_category_utils.dart';
import '../../data/models/budget_model.dart';
import 'budget_month_utils.dart';

/// Carry-over summary shown above the empty state when the selected month has
/// no budget but an earlier month does — so a missing budget reads as "not
/// created yet", not as stale data from the wrong month.
class BudgetPreviousMonthCard extends StatefulWidget {
  final BudgetModel budget;
  final String currencySymbol;

  const BudgetPreviousMonthCard({
    super.key,
    required this.budget,
    required this.currencySymbol,
  });

  @override
  State<BudgetPreviousMonthCard> createState() =>
      _BudgetPreviousMonthCardState();
}

class _BudgetPreviousMonthCardState extends State<BudgetPreviousMonthCard> {
  bool _expanded = false;

  String _fmt(double v) => formatCurrency(
        v,
        widget.currencySymbol,
        abbreviate: false,
        withCommas: true,
      );

  @override
  Widget build(BuildContext context) {
    final b = widget.budget;
    final monthName = b.startDate != null
        ? budgetMonthLabel(b.startDate!.month)
        : 'Previous month';
    final fraction = b.amountAllocated > 0
        ? (b.spent / b.amountAllocated).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                        '$monthName budget',
                        style: AppTypography.labelMedium.copyWith(
                          color: context.textPrimary,
                          fontVariations: const [FontVariation('wght', 600)],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _expanded
                            ? 'Tap to collapse'
                            : 'Your last budget — tap to see the breakdown',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _expanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                    size: 16,
                    color: context.textQuaternary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              _fmt(b.remaining),
              style: AppTypography.headingMedium.copyWith(
                color: context.textQuaternary,
                fontFamily: AppFonts.body,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Left at the end of $monthName',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            _ProgressBar(fraction: fraction),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_fmt(b.spent)} / ${_fmt(b.amountAllocated)} spent',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${b.pctUsed.toStringAsFixed(0)}% used',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textQuaternary,
                    fontSize: 12,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: AppSpacing.base),
              Divider(height: 1, color: context.borderColor),
              const SizedBox(height: AppSpacing.base),
              _Row(label: 'Budget amount', value: _fmt(b.amountAllocated)),
              _Row(
                label: 'Allocated',
                value: _fmt(b.totalAllocatedToCategories),
              ),
              _Row(label: 'Unallocated', value: _fmt(b.unallocated)),
              _Row(label: 'Spent', value: _fmt(b.spent)),
              _Row(label: 'Remaining', value: _fmt(b.remaining)),
              _Row(label: 'Start date', value: budgetDateLabel(b.startDate)),
              _Row(label: 'End date', value: budgetDateLabel(b.endDate)),
              if (b.allocations.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Categories',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textQuaternary,
                    fontSize: 12,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...b.allocations.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: expenseCategoryColor(a.categoryName),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            a.categoryName,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textQuaternary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          '${_fmt(a.spent)} / ${_fmt(a.amountAllocated)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: context.textQuaternary,
              fontSize: 12,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double fraction;
  const _ProgressBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final total = constraints.maxWidth;
        final spentW = total * fraction;
        final remW = total - spentW;
        return ClipRRect(
          borderRadius: AppRadius.radiusXs,
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                if (spentW > 0)
                  Container(width: spentW, color: AppColors.primary),
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
