import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../expenses/presentation/widgets/expense_category_utils.dart';
import '../../../expenses/providers/category_color_sync_provider.dart';
import '../../../home/presentation/widgets/clara_card.dart';
import '../../data/models/budget_model.dart';
import '../../providers/budget_providers.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/budget_composition_card.dart';
import '../widgets/budget_expense_chart_section.dart';
import '../widgets/budget_category_tile.dart';
import '../widgets/budget_allocation_sheet.dart';
import '../widgets/budget_delete_sheet.dart';
import '../widgets/budget_month_utils.dart';
import '../widgets/budget_no_allocation_sheet.dart';
import '../widgets/budget_details_sheet.dart';
import '../widgets/budget_previous_month_card.dart';
import '../../../expenses/presentation/widgets/month_selection_sheet.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  Future<void> _onAllocate(BuildContext context, WidgetRef ref) async {
    final budget = ref.read(budgetProvider).valueOrNull?.budget;
    if (budget == null) return;
    final amountLeft = budget.unallocated;
    if (amountLeft <= 0) {
      showBudgetNoAllocationSheet(
        context,
        onIncrease: () =>
            context.push(RouteNames.createBudget, extra: 'Increase budget'),
      );
      return;
    }
    final symbol = ref.read(currencySymbolProvider);
    await showBudgetAllocationSheet(
      context,
      amountLeft: amountLeft,
      budgetTotal: budget.amountAllocated,
      currencySymbol: symbol,
      onSubmit: (categoryId, amount) => ref
          .read(budgetProvider.notifier)
          .allocate(categoryId: categoryId, amount: amount),
    );
  }

  Future<void> _onDeleteBudget(BuildContext context, WidgetRef ref) async {
    await showBudgetDeleteSheet(
      context,
      onConfirm: () => _deleteBudget(context, ref),
    );
  }

  Future<bool> _deleteBudget(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(budgetProvider.notifier).delete();
      return true;
    } on AppException catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.message);
      return false;
    }
  }

  Future<void> _onEditAllocation(
    BuildContext context,
    WidgetRef ref,
    AllocationModel allocation,
  ) async {
    final budget = ref.read(budgetProvider).valueOrNull?.budget;
    if (budget == null) return;
    final symbol = ref.read(currencySymbolProvider);
    await showBudgetAllocationSheet(
      context,
      amountLeft: budget.unallocated,
      budgetTotal: budget.amountAllocated,
      existing: allocation,
      currencySymbol: symbol,
      onSubmit: (categoryId, amount) => ref
          .read(budgetProvider.notifier)
          .allocate(categoryId: categoryId, amount: amount),
      onRemove: () => ref
          .read(budgetProvider.notifier)
          .removeAllocation(allocation.categoryId),
    );
  }

  void _onCreateBudget(BuildContext context) =>
      context.push(RouteNames.createBudget);

  Future<void> _onPickMonth(BuildContext context, WidgetRef ref) async {
    final state = ref.read(budgetProvider).valueOrNull;
    if (state == null) return;
    final picked = await showMonthSelectionSheet(
      context,
      selected: state.month,
    );
    if (picked != null) {
      ref.read(budgetProvider.notifier).selectMonth(picked, state.year);
    }
  }

  void _onBudgetCardTap(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
  ) {
    final symbol = ref.read(currencySymbolProvider);
    String fmt(double v) =>
        formatCurrency(v, symbol, abbreviate: false, withCommas: true);
    showBudgetDetailsSheet(
      context,
      currentAmount: budget.amountAllocated,
      budgetAmount: fmt(budget.amountAllocated),
      allocated: fmt(budget.totalAllocatedToCategories),
      unallocated: fmt(budget.unallocated),
      allocatedSpent: fmt(budget.spent),
      allocatedRemaining: fmt(budget.remaining),
      startDate: budgetDateLabel(budget.startDate),
      endDate: budgetDateLabel(budget.endDate),
      onDeleted: () => _deleteBudget(context, ref),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);
    final value = state.valueOrNull;
    final hasBudget = value?.budget != null;
    final symbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            _BudgetHeader(
              monthLabel: value != null ? budgetMonthShort(value.month) : null,
              onPickMonth: value != null ? () => _onPickMonth(context, ref) : null,
              onAllocate: hasBudget ? () => _onAllocate(context, ref) : null,
              onDelete: hasBudget ? () => _onDeleteBudget(context, ref) : null,
              onCreate: value != null && !hasBudget
                  ? () => _onCreateBudget(context)
                  : null,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(budgetProvider.notifier).refresh(),
                child: state.when(
                  loading: () => const _BudgetSkeleton(),
                  error: (_, _) => _BudgetError(
                    onRetry: () =>
                        ref.read(budgetProvider.notifier).refresh(),
                  ),
                  data: (s) => s.budget == null
                      ? _EmptyBudget(
                          monthLabel: budgetMonthLabel(s.month),
                          previous: s.previous,
                          currencySymbol: symbol,
                          onCreate: () => _onCreateBudget(context),
                        )
                      : _FilledBudget(
                          budget: s.budget!,
                          monthLabel: budgetMonthLabel(s.month),
                          onAllocTap: (a) =>
                              _onEditAllocation(context, ref, a),
                          onMonthTap: () => _onPickMonth(context, ref),
                          onBudgetCardTap: () =>
                              _onBudgetCardTap(context, ref, s.budget!),
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

// ─── Header ──────────────────────────────────────────────────────────────────

class _BudgetHeader extends StatelessWidget {
  final String? monthLabel;
  final VoidCallback? onPickMonth;
  final VoidCallback? onAllocate;
  final VoidCallback? onDelete;
  final VoidCallback? onCreate;

  const _BudgetHeader({
    this.monthLabel,
    this.onPickMonth,
    this.onAllocate,
    this.onDelete,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Budget',
            style: AppTypography.headingMedium.copyWith(
              color: context.textPrimary,
            ),
          ),
          const Spacer(),
          // Month filter is always visible — otherwise browsing past months is
          // an invisible feature buried in the summary card.
          if (monthLabel != null) ...[
            GestureDetector(
              onTap: onPickMonth,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: AppRadius.radiusFull,
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.filter,
                      size: 12,
                      color: context.textQuaternary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      monthLabel!,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textQuaternary,
                        fontSize: 14,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (onCreate != null)
            GestureDetector(
              onTap: onCreate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.radiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.add, size: 12, color: AppColors.white),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Create budget',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white,
                        fontSize: 14,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Allocate/Delete only make sense once a budget exists.
          if (onAllocate != null || onDelete != null)
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: AppRadius.radiusFull,
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onAllocate,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.sm,
                        AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.add,
                            size: 12,
                            color: context.textQuaternary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Allocate',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textQuaternary,
                              fontSize: 14,
                              fontVariations: const [
                                FontVariation('wght', 500)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, height: 20, color: context.borderColor),
                  GestureDetector(
                    onTap: onDelete,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Icon(
                        AppIcons.delete,
                        size: 14,
                        color: context.textQuaternary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyBudget extends StatelessWidget {
  final String monthLabel;
  final BudgetModel? previous;
  final String currencySymbol;
  final VoidCallback? onCreate;

  const _EmptyBudget({
    required this.monthLabel,
    required this.currencySymbol,
    this.previous,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrevious = previous != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final card = Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.radiusSheet,
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/empty-budget.png',
                  width: hasPrevious ? 140 : 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  hasPrevious ? 'No budget for $monthLabel' : 'No budget yet',
                  style: AppTypography.headingMedium.copyWith(
                    color: context.textPrimary,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    hasPrevious
                        ? "You haven't set a budget for $monthLabel yet. Tap the button below or chat with Clara AI to set your budget and allocation"
                        : 'Tap the button below or chat with Clara AI to set your budget and allocation',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                GestureDetector(
                  onTap: onCreate,
                  child: Container(
                    width: 156,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.radiusFull,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Create budget',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontSize: 16,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            0,
            AppSpacing.screenPadding,
            AppSpacing.base,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - AppSpacing.base,
            ),
            child: hasPrevious
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BudgetPreviousMonthCard(
                        budget: previous!,
                        currencySymbol: currencySymbol,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      card,
                    ],
                  )
                : card,
          ),
        );
      },
    );
  }
}

// ─── Filled state ─────────────────────────────────────────────────────────────

class _FilledBudget extends ConsumerWidget {
  final BudgetModel budget;
  final String monthLabel;
  final void Function(AllocationModel) onAllocTap;
  final VoidCallback? onMonthTap;
  final VoidCallback? onBudgetCardTap;

  const _FilledBudget({
    required this.budget,
    required this.monthLabel,
    required this.onAllocTap,
    this.onMonthTap,
    this.onBudgetCardTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final syncedColors = ref.watch(categoryColorSyncProvider).valueOrNull;
    final categories =
        budget.allocations.map((a) => _toItem(a, syncedColors)).toList();
    // Prefer the backend's AI line; the locally composed sentence is only a
    // fallback for older responses where clara_insight is absent or empty.
    final backendInsight = budget.claraInsight?.trim() ?? '';
    final insight = backendInsight.isNotEmpty
        ? backendInsight
        : "You've used ${budget.pctUsed.toStringAsFixed(0)}% of your "
            "${formatCurrency(budget.amountAllocated, symbol)} budget.";

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xs,
        AppSpacing.screenPadding,
        80, // room for FAB
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBudgetCardTap,
            child: BudgetSummaryCard(
              availableBudget: budget.remaining,
              spentAmount: budget.spent,
              totalBudget: budget.amountAllocated,
              daysLeft: budget.daysLeft,
              month: monthLabel,
              currencySymbol: symbol,
              onMonthTap: onMonthTap,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          ClaraCard(insightText: insight),
          const SizedBox(height: AppSpacing.xl),
          _AllocatedCategoryHeader(),
          const SizedBox(height: AppSpacing.base),
          if (categories.isEmpty)
            _NoAllocations()
          else
            ...budget.allocations.asMap().entries.map((e) {
              final item = categories[e.key];
              final alloc = budget.allocations[e.key];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.base),
                child: BudgetCategoryTile(
                  item: item,
                  onTap: () => onAllocTap(alloc),
                ),
              );
            }),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            BudgetExpenseChartSection(
              allocations: budget.allocations,
              totalBudget: budget.totalAllocatedToCategories,
              totalExpense: budget.spent,
            ),
            const SizedBox(height: AppSpacing.base),
            BudgetCompositionCard(budget: budget),
          ],
        ],
      ),
    );
  }

  BudgetCategoryItem _toItem(AllocationModel a, Map<String, Color>? syncedColors) =>
      BudgetCategoryItem(
        name: a.categoryName,
        spent: a.spent,
        allocated: a.amountAllocated,
        allocationLabel: '${a.pctUsed.toStringAsFixed(0)}% of allocation',
        icon: categoryIconFor(name: a.categoryName, icon: a.categoryIcon),
        color: categoryColorFor(
          name: a.categoryName,
          icon: a.categoryIcon,
          categoryId: a.categoryId,
          syncedColors: syncedColors,
        ),
        bgColor: categoryBgColorFor(
          name: a.categoryName,
          icon: a.categoryIcon,
          categoryId: a.categoryId,
          syncedColors: syncedColors,
        ),
      );
}

class _NoAllocations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(AppIcons.chart, size: 28, color: context.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No allocations yet',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textQuaternary,
              fontSize: 14,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tap Allocate to split your budget across categories',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AllocatedCategoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allocated category',
          style: AppTypography.labelMedium.copyWith(
            color: context.textQuaternary,
            fontVariations: const [FontVariation('wght', 600)],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'See the categories you spent on',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─── Loading / error ──────────────────────────────────────────────────────────

class _BudgetSkeleton extends StatelessWidget {
  const _BudgetSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xs,
        AppSpacing.screenPadding,
        80,
      ),
      children: [
        const AppSkeleton(
          width: double.infinity,
          height: 140,
          borderRadius: AppRadius.radiusSheet,
        ),
        const SizedBox(height: AppSpacing.base),
        const AppSkeleton(
          width: double.infinity,
          height: 96,
          borderRadius: AppRadius.radiusSheet,
        ),
        const SizedBox(height: AppSpacing.xl),
        const AppSkeleton.text(width: 160),
        const SizedBox(height: AppSpacing.base),
        for (int i = 0; i < 3; i++) ...[
          const AppSkeleton(
            width: double.infinity,
            height: 120,
            borderRadius: AppRadius.radiusSheet,
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ],
    );
  }
}

 class _BudgetError extends StatelessWidget {
  final VoidCallback onRetry;
  const _BudgetError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        const SizedBox(height: 120),
        Icon(AppIcons.budget, size: 40, color: context.textSecondary),
        const SizedBox(height: AppSpacing.base),
        Text(
          "Couldn't load your budget",
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textQuaternary,
            fontSize: 14,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Center(
          child: GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.radiusFull,
              ),
              child: Text(
                'Retry',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 14,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
