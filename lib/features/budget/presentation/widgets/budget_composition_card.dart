import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../expenses/presentation/widgets/expense_category_utils.dart';
import '../../../expenses/providers/category_color_sync_provider.dart';
import '../../data/models/budget_model.dart';

class _Segment {
  final String label;
  final double amount;
  final Color color;

  const _Segment({
    required this.label,
    required this.amount,
    required this.color,
  });
}

class BudgetCompositionCard extends ConsumerStatefulWidget {
  final BudgetModel budget;

  const BudgetCompositionCard({super.key, required this.budget});

  @override
  ConsumerState<BudgetCompositionCard> createState() =>
      _BudgetCompositionCardState();
}

class _BudgetCompositionCardState extends ConsumerState<BudgetCompositionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final budget = widget.budget;
    final symbol = ref.watch(currencySymbolProvider);
    final syncedColors = ref.watch(categoryColorSyncProvider).valueOrNull;

    final segments = <_Segment>[
      for (final a in budget.allocations)
        if (a.amountAllocated > 0)
          _Segment(
            label: a.categoryName,
            amount: a.amountAllocated,
            color: categoryColorFor(
              name: a.categoryName,
              icon: a.categoryIcon,
              categoryId: a.categoryId,
              syncedColors: syncedColors,
            ),
          ),
      if (budget.unallocated > 0)
        _Segment(
          label: 'Unallocated',
          amount: budget.unallocated,
          color: context.surfaceVariant,
        ),
    ];

    final total = segments.fold(0.0, (sum, s) => sum + s.amount);

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
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Where your budget goes',
                        style: AppTypography.labelMedium.copyWith(
                          color: context.textPrimary,
                          fontVariations: const [FontVariation('wght', 600)],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'How your ${formatCurrency(budget.amountAllocated, symbol, abbreviate: false, withCommas: true)} budget is split',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    AppIcons.chevronDown,
                    size: 18,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (total <= 0)
            _empty(context)
          else ...[
            const SizedBox(height: AppSpacing.base),
            LayoutBuilder(
              builder: (context, constraints) => ClipRRect(
                borderRadius: AppRadius.radiusXs,
                child: Row(
                  children: segments
                      .map(
                        (s) => Container(
                          width: constraints.maxWidth * (s.amount / total),
                          height: 14,
                          color: s.color,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Column(
                  children: segments
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: _LegendRow(
                            segment: s,
                            share: s.amount / total,
                            symbol: symbol,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
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

class _LegendRow extends StatelessWidget {
  final _Segment segment;
  final double share;
  final String symbol;

  const _LegendRow({
    required this.segment,
    required this.share,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: segment.color,
            borderRadius: AppRadius.radiusXs,
            border: Border.all(color: context.borderColor),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            segment.label,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          formatCurrency(segment.amount, symbol,
              abbreviate: false, withCommas: true),
          style: AppTypography.bodySmall.copyWith(
            color: context.textPrimary,
            fontSize: 12,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 36,
          child: Text(
            '${(share * 100).toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
