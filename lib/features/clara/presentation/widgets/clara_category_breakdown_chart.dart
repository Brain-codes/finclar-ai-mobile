import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../expenses/presentation/widgets/expense_category_utils.dart';
import '../../data/models/clara_message_model.dart';

/// Per-category spend breakdown card for Clara chat — a horizontal bar per
/// category with amount + % of total, sorted by spend (the backend already
/// returns it sorted, but this guards against future changes).
class ClaraCategoryBreakdownChart extends ConsumerWidget {
  final ClaraInsightModel insight;

  /// Bar-fill reveal factor (0..1), matches [IncomeExpenseChartSection]'s
  /// progress so both chart kinds animate the same way.
  final double chartProgress;

  const ClaraCategoryBreakdownChart({
    super.key,
    required this.insight,
    this.chartProgress = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final categories = [...insight.categories]
      ..sort((a, b) => b.amount.compareTo(a.amount));

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
            insight.title,
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Total spent: ${formatCurrency(insight.expense, symbol, abbreviate: false, withCommas: true)}',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          for (final c in categories) ...[
            _CategoryRow(
              slice: c,
              symbol: symbol,
              progress: chartProgress,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final ClaraCategorySlice slice;
  final String symbol;
  final double progress;

  const _CategoryRow({
    required this.slice,
    required this.symbol,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final color = expenseCategoryColor(slice.name);
    final bgColor = expenseCategoryBgColor(slice.name);
    final fraction = (slice.pctOfTotal / 100).clamp(0.0, 1.0) * progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                slice.name,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textQuaternary,
                  fontSize: 13,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${formatCurrency(slice.amount, symbol, abbreviate: false, withCommas: true)} · ${slice.pctOfTotal.toStringAsFixed(0)}%',
              style: AppTypography.bodySmall.copyWith(
                color: context.textPrimary,
                fontSize: 12,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (_, constraints) {
            return ClipRRect(
              borderRadius: AppRadius.radiusXs,
              child: Container(
                height: 8,
                width: double.infinity,
                color: bgColor,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(color: color),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
