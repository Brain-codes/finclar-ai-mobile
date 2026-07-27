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
import '../../../home/presentation/widgets/clara_card.dart';
import '../../../home/presentation/widgets/income_expense_chart_section.dart';
import '../../data/models/budget_model.dart';
import '../../providers/budget_providers.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/budget_category_tile.dart';
import '../widgets/budget_allocation_sheet.dart';
import '../widgets/budget_delete_sheet.dart';
import '../widgets/budget_no_allocation_sheet.dart';
import '../widgets/budget_details_sheet.dart';
import '../../../expenses/presentation/widgets/month_selection_sheet.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  Future<void> _onAllocate(BuildContext context, WidgetRef ref) async {
    final budget = ref.read(budgetProvider).valueOrNull;
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
    final budget = ref.read(budgetProvider).valueOrNull;
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
      startDate: _formatDate(budget.startDate),
      endDate: _formatDate(budget.endDate),
      onDeleted: () => _deleteBudget(context, ref),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            _BudgetHeader(
              onAllocate: state.valueOrNull != null
                  ? () => _onAllocate(context, ref)
                  : null,
              onDelete: state.valueOrNull != null
                  ? () => _onDeleteBudget(context, ref)
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
                  data: (budget) => budget == null
                      ? _EmptyBudget(
                          onCreate: () => _onCreateBudget(context),
                        )
                      : _FilledBudget(
                          budget: budget,
                          onAllocTap: (a) =>
                              _onEditAllocation(context, ref, a),
                          onBudgetCardTap: () =>
                              _onBudgetCardTap(context, ref, budget),
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

String _formatDate(DateTime? d) {
  if (d == null) return '—';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _BudgetHeader extends StatelessWidget {
  final VoidCallback? onAllocate;
  final VoidCallback? onDelete;

  const _BudgetHeader({this.onAllocate, this.onDelete});

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
  final VoidCallback? onCreate;
  const _EmptyBudget({this.onCreate});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            0,
            AppSpacing.screenPadding,
            AppSpacing.base,
          ),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.base),
            child: Container(
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
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'No budget yet',
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
                        'Tap the button below or chat with Clara AI to set your budget and allocation',
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
            ),
          ),
        );
      },
    );
  }
}

// ─── Filled state ─────────────────────────────────────────────────────────────

class _FilledBudget extends ConsumerWidget {
  final BudgetModel budget;
  final void Function(AllocationModel) onAllocTap;
  final VoidCallback? onBudgetCardTap;

  const _FilledBudget({
    required this.budget,
    required this.onAllocTap,
    this.onBudgetCardTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final categories = budget.allocations.map(_toItem).toList();
    final insight =
        "You've used ${budget.pctUsed.toStringAsFixed(0)}% of your "
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
              month: _monthLabel(budget.startDate),
              onMonthTap: () async {
                final currentMonth = budget.startDate?.month ?? DateTime.now().month;
                final currentYear = budget.startDate?.year ?? DateTime.now().year;
                final picked = await showMonthSelectionSheet(
                  context,
                  selected: currentMonth,
                );
                if (picked != null) {
                  ref.read(budgetProvider.notifier).selectMonth(picked, currentYear);
                }
              },
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
            IncomeExpenseChartSection(
              data: budget.allocations
                  .map(
                    (a) => IncomeExpenseData(
                      month: a.categoryName,
                      income: a.amountAllocated,
                      expense: a.spent,
                    ),
                  )
                  .toList(),
              totalIncome: budget.totalAllocatedToCategories,
              totalExpense: budget.spent,
            ),
          ],
        ],
      ),
    );
  }

  BudgetCategoryItem _toItem(AllocationModel a) => BudgetCategoryItem(
    name: a.categoryName,
    spent: a.spent,
    allocated: a.amountAllocated,
    allocationLabel: '${a.pctUsed.toStringAsFixed(0)}% of allocation',
    icon: a.categoryIcon != null
        ? categoryIconFromString(a.categoryIcon)
        : expenseCategoryIcon(a.categoryName),
    color: expenseCategoryColor(a.categoryName),
    bgColor: expenseCategoryBgColor(a.categoryName),
  );

  String _monthLabel(DateTime? d) {
    if (d == null) return '';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[d.month - 1];
  }
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
