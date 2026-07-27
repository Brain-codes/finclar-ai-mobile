import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/app_bar_chart.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';
import '../../../home/presentation/widgets/clara_card.dart';
import '../../../home/presentation/widgets/income_expense_chart_section.dart';
import '../../../home/providers/home_dashboard_provider.dart';
import '../widgets/expense_category_utils.dart';
import '../widgets/month_selection_sheet.dart';

class SpendingScreen extends ConsumerWidget {
  const SpendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(spendingSummaryProvider);
    final monthLabel = summary.valueOrNull?.monthLabel;
    final title = monthLabel != null && monthLabel.isNotEmpty
        ? '${monthLabel.split(' ').first} expenses'
        : 'Spending';

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: title,
              
              onBack: () => context.pop(),
              actions: [
                GestureDetector(
                  onTap: () async {
                    final picked = await showMonthSelectionSheet(
                      context,
                      selected: ref.read(spendingMonthProvider),
                    );
                    if (picked != null) {
                      ref.read(spendingMonthProvider.notifier).state = picked;
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.filter,
                      size: 18,
                      color: context.textQuaternary,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(spendingSummaryProvider),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Column(
                    children: const [
                      SizedBox(height: AppSpacing.base),
                      _CategoryDonutSection(),
                      SizedBox(height: AppSpacing.base),
                      _SpendingInsightSection(),
                      SizedBox(height: AppSpacing.base),
                      IncomeExpenseChartSection(),
                      SizedBox(height: AppSpacing.base),
                      ClaraCard(),
                      SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendCategory {
  final String name;
  final Color color;
  final double amount;

  const _SpendCategory({
    required this.name,
    required this.color,
    required this.amount,
  });
}

// ─── Category donut section ───────────────────────────────────────────────────

class _CategoryDonutSection extends ConsumerWidget {
  const _CategoryDonutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(spendingSummaryProvider);
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
            'Category',
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          Text(
            'See the categories you spent on',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          summary.when(
            loading: () => const _DonutSkeleton(),
            error: (_, _) => _empty(context),
            data: (s) {
              final cats = s.categories
                  .where((c) => c.amount > 0)
                  .map((c) => _SpendCategory(
                        name: c.name,
                        color: expenseCategoryColor(c.name),
                        amount: c.amount,
                      ))
                  .toList();
              if (cats.isEmpty) return _empty(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SpendingDonutChart(categories: cats, symbol: symbol),
                  const SizedBox(height: AppSpacing.base),
                  for (int i = 0; i < cats.length; i++) ...[
                    _CategoryRow(category: cats[i], symbol: symbol),
                    if (i < cats.length - 1) ...[
                      const SizedBox(height: AppSpacing.base),
                      Divider(height: 1, color: context.borderColor),
                      const SizedBox(height: AppSpacing.base),
                    ],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: Text(
            'No spending this month yet',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
      );
}

class _DonutSkeleton extends StatelessWidget {
  const _DonutSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppSkeleton.circle(size: 140),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                AppSkeleton.circle(size: 10),
                SizedBox(width: AppSpacing.xs),
                AppSkeleton.text(width: 100),
                Spacer(),
                AppSkeleton.text(width: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpendingDonutChart extends StatelessWidget {
  final List<_SpendCategory> categories;
  final String symbol;

  const _SpendingDonutChart({required this.categories, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final totalSpent = categories.fold<double>(0, (s, c) => s + c.amount);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final ringRadius = size * 0.18;
        final centerRadius = size * 0.28;

        final sections = categories
            .where((c) => c.amount > 0)
            .map(
              (c) => PieChartSectionData(
                color: c.color,
                value: c.amount,
                title: '',
                radius: ringRadius,
                showTitle: false,
              ),
            )
            .toList();

        if (sections.isEmpty) {
          sections.add(PieChartSectionData(
            color: context.borderColor,
            value: 1,
            title: '',
            radius: ringRadius,
            showTitle: false,
          ));
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
                    'Total expense',
                    style: AppTypography.labelXSmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  Text(
                    formatCurrency(totalSpent, symbol, abbreviate: true),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textPrimary,
                      fontVariations: const [FontVariation('wght', 600)],
                      fontSize: size * 0.045,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final _SpendCategory category;
  final String symbol;

  const _CategoryRow({required this.category, required this.symbol});

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
          formatCurrency(category.amount, symbol,
              abbreviate: false, withCommas: true),
          style: AppTypography.bodySmall.copyWith(
            color: context.textPrimary,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
      ],
    );
  }
}

// ─── Spending insight chart ───────────────────────────────────────────────────

class _SpendingInsightSection extends ConsumerWidget {
  const _SpendingInsightSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(spendingSummaryProvider);
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
            'Spending Insight',
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          summary.when(
            loading: () => const _InsightSkeleton(),
            error: (_, _) => _empty(context),
            data: (s) {
              var trend = s.monthlyTrend;
              if (trend.isEmpty) return _empty(context);
              if (trend.length > 5) {
                trend = trend.sublist(trend.length - 5);
              }

              // Span the reference line between the previous and current month,
              // positioned at the current month's spending.
              const monthAbbr = [
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
              ];
              final selectedAbbr = monthAbbr[ref.watch(spendingMonthProvider) - 1];
              var currentIndex = trend.indexWhere((p) => p.month == selectedAbbr);
              if (currentIndex < 0) currentIndex = trend.length - 1;
              final startIndex = currentIndex > 0 ? currentIndex - 1 : currentIndex;
              final currentSpend = trend[currentIndex].total;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InsightLine(
                    momChangePct: s.momChangePct,
                    momDirection: s.momDirection,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  AppBarChart(
                    height: 160,
                    barWidth: 40,
                    showGrid: false,
                    showYAxis: false,
                    barBorderRadius: BorderRadius.circular(AppRadius.sm),
                    groups: [
                      for (int i = 0; i < trend.length; i++)
                        AppBarChartGroup(
                          label: trend[i].month,
                          bars: [
                            AppBarChartBar(
                              value: trend[i].total,
                              color: AppColors.transparent,
                              striped: true,
                              stripeColor: i == currentIndex
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              stripeOpacity: 1,
                            ),
                          ],
                        ),
                    ],
                    referenceLine: AppBarChartReferenceLine(
                      value: currentSpend,
                      color: AppColors.primary,
                      label: formatCurrency(currentSpend, symbol,
                          abbreviate: true),
                      startGroupIndex: startIndex,
                      endGroupIndex: currentIndex,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: Text(
            'Not enough data to show a trend yet',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
      );
}

class _InsightLine extends StatelessWidget {
  final double? momChangePct;
  final String? momDirection;

  const _InsightLine({this.momChangePct, this.momDirection});

  @override
  Widget build(BuildContext context) {
    final String text;
    if (momChangePct == null || momDirection == null) {
      text = 'Tracking your monthly spending';
    } else {
      final pct = momChangePct!.abs().toStringAsFixed(0);
      final dir = momDirection == 'up' ? 'higher' : 'lower';
      text = 'Your expenses are $dir by $pct% from last month';
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: CustomPaint(
            size: const Size(8, 16),
            painter: AppStripePainter(
              stripeColor: AppColors.primary,
              spacing: 3.0,
              strokeWidth: 1.5,
              angleDegrees: 45.0,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightSkeleton extends StatelessWidget {
  const _InsightSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.text(width: 240),
          SizedBox(height: AppSpacing.base),
          AppSkeleton(width: double.infinity, height: 160),
        ],
      ),
    );
  }
}
