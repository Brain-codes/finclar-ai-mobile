import 'package:finclar_ai/shared/widgets/gradient_icon.dart';
import 'package:finclar_ai/shared/widgets/gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';
import '../../../expenses/data/models/expense_summary_model.dart';
import '../../providers/home_dashboard_provider.dart';

class SpendingCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const SpendingCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final summary = ref.watch(homeSummaryProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
                Text(
                  AppStrings.thisMonthSpending,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.textQuaternary,
                    fontSize: 14,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                Icon(
                  AppIcons.chevronRight,
                  color: context.textSecondary,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            summary.when(
              loading: () => const _SpendingSkeleton(),
              error: (_, _) => _empty(context),
              data: (s) => s.totalExpense <= 0
                  ? _empty(context)
                  : _SpendingContent(summary: s, symbol: symbol),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Text(
        'You\'ve not made any expense yet.',
        style: AppTypography.bodySmall.copyWith(
          color: context.textSecondary,
        ),
      );
}

class _SpendingContent extends StatelessWidget {
  final ExpenseSummaryModel summary;
  final String symbol;

  const _SpendingContent({required this.summary, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final percentage = summary.monthlyIncome > 0
        ? (summary.totalExpense / summary.monthlyIncome)
        : 0.0;
    final pctLabel = (percentage * 100).clamp(0, 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatCurrency(summary.totalExpense, symbol,
              abbreviate: false, withCommas: true),
          style: AppTypography.amountSmall.copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SpendingBar(percentage: percentage),
        const SizedBox(height: AppSpacing.sm),
        Row(
          spacing: 5,
          children: [
            GradientIcon(
              icon: AppIcons.aiFill,
              size: 16,
              gradient: AppColors.claraGradient,
            ),
            Expanded(
              child: GradientText(
                summary.monthlyIncome > 0
                    ? "You've spent $pctLabel% of your income this month."
                    : AppStrings.aiInsight,
                gradient: AppColors.claraGradient,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SpendingSkeleton extends StatelessWidget {
  const _SpendingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton.text(width: 160, height: 28),
        SizedBox(height: AppSpacing.md),
        AppSkeleton(width: double.infinity, height: 14),
        SizedBox(height: AppSpacing.sm),
        AppSkeleton.text(width: 200, height: 12),
      ],
    );
  }
}

class _SpendingBar extends StatelessWidget {
  final double percentage;

  const _SpendingBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    const height = 14.0;
    const gap = 4.0;
    const radius = Radius.circular(AppRadius.xs);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final clampedPct = percentage.clamp(0.0, 1.0);
          final totalWidth = constraints.maxWidth;
          final spentWidth = clampedPct == 0
              ? 0.0
              : (totalWidth * clampedPct - gap / 2).clamp(0.0, totalWidth);
          final remainWidth = clampedPct == 1
              ? 0.0
              : (totalWidth * (1 - clampedPct) - gap / 2).clamp(
                  0.0,
                  totalWidth,
                );

          return Row(
            children: [
              if (spentWidth > 0)
                ClipRRect(
                  borderRadius: BorderRadius.all(radius),
                  child: SizedBox(
                    width: spentWidth,
                    height: height,
                    child: ColoredBox(color: AppColors.primary),
                  ),
                ),
              if (spentWidth > 0 && remainWidth > 0) const SizedBox(width: gap),
              if (remainWidth > 0)
                ClipRRect(
                  borderRadius: BorderRadius.all(radius),
                  child: CustomPaint(
                    size: Size(remainWidth, height),
                    painter: AppStripePainter(
                      stripeColor: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
