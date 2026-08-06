import 'package:finclar_ai/shared/icons/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_bar_chart.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../providers/home_dashboard_provider.dart';

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

class IncomeExpenseChartSection extends ConsumerWidget {
  final List<IncomeExpenseData>? data;
  final double? totalIncome;
  final double? totalExpense;

  /// Bar-rise reveal factor (0..1), forwarded to [AppBarChart.progress].
  /// Defaults to 1.0 (fully drawn) — used by Clara to animate the chart in.
  final double chartProgress;

  const IncomeExpenseChartSection({
    super.key,
    this.data,
    this.totalIncome,
    this.totalExpense,
    this.chartProgress = 1.0,
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
            AppStrings.incomeAndExpense,
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          if (data != null)
            _ChartContent(
              points: data!,
              totalIncome: totalIncome ?? 0,
              totalExpense: totalExpense ?? 0,
              symbol: symbol,
              progress: chartProgress,
            )
          else
            ref.watch(homeSummaryProvider).when(
                  loading: () => const _ChartSkeleton(),
                  error: (_, _) => _error(context, ref),
                  data: (s) => s.incomeExpenseTrend.isEmpty
                      ? _empty(context)
                      : _ChartContent(
                          points: s.incomeExpenseTrend
                              .map((p) => IncomeExpenseData(
                                    month: p.month,
                                    income: p.income,
                                    expense: p.expense,
                                  ))
                              .toList(),
                          totalIncome: s.monthlyIncome,
                          totalExpense: s.totalExpense,
                          symbol: symbol,
                          progress: chartProgress,
                        ),
                ),
        ],
      ),
    );
  }

  Widget _error(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: GestureDetector(
            onTap: () => ref.invalidate(homeSummaryProvider),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.refresh, size: 20, color: context.textSecondary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Couldn't load. Tap to retry",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _empty(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.walletLine, size: 20, color: context.textSecondary),
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
      );
}

class _ChartContent extends StatelessWidget {
  final List<IncomeExpenseData> points;
  final double totalIncome;
  final double totalExpense;
  final String symbol;
  final double progress;

  const _ChartContent({
    required this.points,
    required this.totalIncome,
    required this.totalExpense,
    required this.symbol,
    this.progress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.base),
        AppBarChart(
          height: 160,
          progress: progress,
          formatY: (v) => formatCurrency(v, symbol, abbreviate: true),
          groups: points
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
        const SizedBox(height: AppSpacing.xl),
        _LegendItem(
          stripeColor: AppColors.primary,
          label: AppStrings.incomeLabel,
          amount: formatCurrency(totalIncome, symbol,
              abbreviate: false, withCommas: true),
          onTap: () => context.push(RouteNames.incomeSetup),
        ),
        const SizedBox(height: AppSpacing.base),
        _LegendItem(
          stripeColor: AppColors.categoryTransport,
          label: AppStrings.expenseLabel,
          amount: formatCurrency(totalExpense, symbol,
              abbreviate: false, withCommas: true),
        ),
      ],
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (i) => AppSkeleton(
                  width: 24,
                  height: 60.0 + (i % 3) * 40,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppSkeleton.text(width: double.infinity, height: 16),
          const SizedBox(height: AppSpacing.base),
          const AppSkeleton.text(width: double.infinity, height: 16),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color stripeColor;
  final String label;
  final String amount;
  final VoidCallback? onTap;

  const _LegendItem({
    required this.stripeColor,
    required this.label,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
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
        if (onTap != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(AppIcons.chevronRight, size: 14, color: context.textSecondary),
        ],
      ],
    );

    if (onTap == null) return row;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}
