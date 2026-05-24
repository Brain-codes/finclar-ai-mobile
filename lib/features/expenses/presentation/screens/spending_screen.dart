import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/app_bar_chart.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';
import '../../../home/presentation/widgets/clara_card.dart';
import '../../../home/presentation/widgets/income_expense_chart_section.dart';
import '../../../home/presentation/widgets/budget_section.dart';

class SpendingScreen extends StatelessWidget {
  const SpendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: 'April expense',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.base),
                    const _CategoryDonutSection(),
                    const SizedBox(height: AppSpacing.base),
                    const _SpendingInsightSection(),
                    const SizedBox(height: AppSpacing.base),
                    const IncomeExpenseChartSection(),
                    const SizedBox(height: AppSpacing.base),
                    const ClaraCard(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category donut section ───────────────────────────────────────────────────

class _CategoryDonutSection extends StatelessWidget {
  const _CategoryDonutSection();

  static const _categories = [
    BudgetCategory(
      name: 'Food',
      color: AppColors.categoryFood,
      spent: 100000,
      total: 250000,
    ),
    BudgetCategory(
      name: 'Transportation',
      color: AppColors.categoryTransport,
      spent: 80000,
      total: 250000,
    ),
    BudgetCategory(
      name: 'Health',
      color: AppColors.categoryHealth,
      spent: 40000,
      total: 250000,
    ),
    BudgetCategory(
      name: 'Shopping',
      color: AppColors.categoryShopping,
      spent: 30000,
      total: 250000,
    ),
  ];

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
          _SpendingDonutChart(categories: _categories),
          const SizedBox(height: AppSpacing.base),
          for (int i = 0; i < _categories.length; i++) ...[
            _CategoryRow(category: _categories[i]),
            if (i < _categories.length - 1) ...[
              const SizedBox(height: AppSpacing.base),
              Divider(height: 1, color: context.borderColor),
              const SizedBox(height: AppSpacing.base),
            ],
          ],
        ],
      ),
    );
  }
}

class _SpendingDonutChart extends StatelessWidget {
  final List<BudgetCategory> categories;

  const _SpendingDonutChart({required this.categories});

  @override
  Widget build(BuildContext context) {
    final totalSpent = categories.fold<double>(0, (s, c) => s + c.spent);

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
                    _fmt(totalSpent),
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

  String _fmt(double v) {
    if (v >= 1000000) return '₦${(v / 1000000).toStringAsFixed(1)}m';
    if (v >= 1000) return '₦${(v / 1000).toStringAsFixed(0)}k';
    return '₦${v.toStringAsFixed(0)}';
  }
}

class _CategoryRow extends StatelessWidget {
  final BudgetCategory category;

  const _CategoryRow({required this.category});

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
          _fmt(category.spent),
          style: AppTypography.bodySmall.copyWith(
            color: context.textPrimary,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '₦${(v / 1000000).toStringAsFixed(1)}m';
    if (v >= 1000) return '₦${(v / 1000).toStringAsFixed(0)},000';
    return '₦${v.toStringAsFixed(0)}';
  }
}

// ─── Spending insight chart ───────────────────────────────────────────────────

class _SpendingInsightSection extends StatelessWidget {
  const _SpendingInsightSection();

  static const _data = [
    _MonthSpend(month: 'Jan', amount: 180000),
    _MonthSpend(month: 'Feb', amount: 320000),
    _MonthSpend(month: 'Mar', amount: 200000),
    _MonthSpend(month: 'Apr', amount: 280000),
    _MonthSpend(month: 'May', amount: 150000),
    _MonthSpend(month: 'Jun', amount: 250000),
  ];

  static const _avg = 250000.0;

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
            'Spending Insight',
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
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
                  'Your average expenses is lower by 8% from last month',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          AppBarChart(
            height: 160,
            barWidth: 14,
            groups: _data
                .map(
                  (d) => AppBarChartGroup(
                    label: d.month,
                    bars: [
                      AppBarChartBar(
                        value: d.amount,
                        color: AppColors.transparent,
                        striped: true,
                        stripeColor: AppColors.primary,
                        stripeOpacity: 1,
                      ),
                    ],
                  ),
                )
                .toList(),
            referenceLine: AppBarChartReferenceLine(
              value: _avg,
              color: AppColors.primary,
              label: '₦250k',
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSpend {
  final String month;
  final double amount;

  const _MonthSpend({required this.month, required this.amount});
}
