import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../budget/providers/budget_providers.dart';
import '../../../expenses/providers/expense_providers.dart';
import '../../../home/providers/income_setup_provider.dart';

/// First-run checklist. Each row ticks itself off from the provider that owns
/// that piece of state, and the whole card disappears once all three are done —
/// so it never needs manual dismissal or a "seen" flag.
class QuickStartCard extends ConsumerWidget {
  const QuickStartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(incomeProvider);
    final expenses = ref.watch(expenseListProvider);
    final budgets = ref.watch(budgetProvider);

    // Wait for all three before deciding anything — showing a half-resolved
    // checklist would tick rows on as they load, which reads as broken.
    if (income.isLoading || expenses.isLoading || budgets.isLoading) {
      return const _QuickStartSkeleton();
    }

    final hasIncome = income.valueOrNull != null;
    final hasExpense = (expenses.valueOrNull?.items ?? []).isNotEmpty;
    // Any budget ever created counts — the checklist step must not un-tick
    // just because the user has rolled into a new month.
    final hasBudget = budgets.valueOrNull?.hasAnyBudget ?? false;
    if (hasIncome && hasExpense && hasBudget) return const SizedBox.shrink();

    final done = [hasIncome, hasExpense, hasBudget].where((d) => d).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Get set up',
                  style: AppTypography.labelMedium.copyWith(
                    color: context.textPrimary,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
              ),
              Text(
                '$done of 3',
                style: AppTypography.labelSmall
                    .copyWith(color: context.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          _QuickStartRow(
            label: 'Set your income',
            done: hasIncome,
            onTap: () => context.push(RouteNames.incomeSetup),
          ),
          _QuickStartRow(
            label: 'Log your first expense',
            done: hasExpense,
            onTap: () => context.push(RouteNames.addExpenseOcr),
          ),
          _QuickStartRow(
            label: 'Create a budget',
            done: hasBudget,
            onTap: () => context.go(RouteNames.budget),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _QuickStartRow extends StatelessWidget {
  final String label;
  final bool done;
  final VoidCallback onTap;
  final bool isLast;

  const _QuickStartRow({
    required this.label,
    required this.done,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: done ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
        child: Row(
          children: [
            Icon(
              done ? AppIcons.success : AppIcons.radioUnchecked,
              size: 20,
              color: done ? AppColors.success : context.textTertiary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: done ? context.textSecondary : context.textPrimary,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: context.textSecondary,
                ),
              ),
            ),
            if (!done)
              Icon(AppIcons.chevronRight,
                  size: 16, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _QuickStartSkeleton extends StatelessWidget {
  const _QuickStartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton.text(width: 90),
          const SizedBox(height: AppSpacing.base),
          for (int i = 0; i < 3; i++) ...[
            const Row(
              children: [
                AppSkeleton.circle(size: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: AppSkeleton.text(width: double.infinity)),
              ],
            ),
            if (i < 2) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}
