import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../home/presentation/widgets/clara_card.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/budget_category_tile.dart';
import '../../../home/presentation/widgets/income_expense_chart_section.dart';
import '../widgets/budget_allocation_sheet.dart';
import '../widgets/budget_no_allocation_sheet.dart';
import '../widgets/budget_category_sheet.dart';
import '../widgets/budget_details_sheet.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // In production this would come from a provider
  final bool _isEmpty = false;

  void _onAllocate() {
    const amountLeft = 250000.0;
    if (amountLeft <= 0) {
      showBudgetNoAllocationSheet(context);
    } else {
      showBudgetAllocationSheet(context, amountLeft: amountLeft);
    }
  }

  void _onCategoryTap(BudgetCategoryItem item) {
    showBudgetCategorySheet(context);
  }

  void _onCreateBudget() => context.push(RouteNames.createBudget);

  void _onBudgetCardTap() => showBudgetDetailsSheet(
        context,
        budgetAmount: '₦5,000,000.00',
        allocated: '₦4,750,000.00',
        unallocated: '₦250,000.00',
        allocatedSpent: '₦250,000.00',
        allocatedRemaining: '₦4,500,000.00',
        startDate: 'Apr 1, 2025',
        endDate: 'Apr 30, 2025',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _BudgetHeader(
                  onAllocate: _isEmpty ? null : _onAllocate,
                  onFilter: () {},
                ),
                Expanded(
                  child: _isEmpty
                      ? _EmptyBudget(onCreate: _onCreateBudget)
                      : _FilledBudget(
                          onCategoryTap: _onCategoryTap,
                          onBudgetCardTap: _onBudgetCardTap,
                        ),
                ),
              ],
            ),
            Positioned(
              right: AppSpacing.screenPadding,
              bottom: AppSpacing.screenPadding,
              child: _BudgetFab(onTap: _onCreateBudget),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _BudgetHeader extends StatelessWidget {
  final VoidCallback? onAllocate;
  final VoidCallback? onFilter;

  const _BudgetHeader({this.onAllocate, this.onFilter});

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
                          AppIcons.chart,
                          size: 16,
                          color: context.textQuaternary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Allocate',
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
                Container(
                  width: 1,
                  height: 20,
                  color: context.borderColor,
                ),
                GestureDetector(
                  onTap: onFilter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Icon(
                      AppIcons.filter,
                      size: 20,
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

// ─── FAB ─────────────────────────────────────────────────────────────────────

class _BudgetFab extends StatelessWidget {
  final VoidCallback? onTap;
  const _BudgetFab({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(AppIcons.add, color: AppColors.white, size: 24),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.base,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BudgetIllustration(),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
    );
  }
}

class _BudgetIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: 227,
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.radiusSheet,
      ),
      child: Icon(
        AppIcons.budget,
        size: 72,
        color: context.textSecondary,
      ),
    );
  }
}

// ─── Filled state ─────────────────────────────────────────────────────────────

class _FilledBudget extends StatelessWidget {
  final ValueChanged<BudgetCategoryItem> onCategoryTap;
  final VoidCallback? onBudgetCardTap;
  const _FilledBudget({required this.onCategoryTap, this.onBudgetCardTap});

  static const _budgetInsight =
      "You've used 75% of your budget of ₦1,000,000 with food making up 50% and shopping 35% of your spending";

  @override
  Widget build(BuildContext context) {
    final categories = defaultBudgetCategories;

    return SingleChildScrollView(
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
              availableBudget: 500000,
              spentAmount: 250000,
              totalBudget: 5000000,
              daysLeft: 13,
              month: 'April',
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          ClaraCard(insightText: _budgetInsight),
          const SizedBox(height: AppSpacing.xl),
          _AllocatedCategoryHeader(),
          const SizedBox(height: AppSpacing.base),
          ...categories.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.base),
              child: BudgetCategoryTile(
                item: item,
                onTap: () => onCategoryTap(item),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          IncomeExpenseChartSection(
            data: const [
              IncomeExpenseData(month: 'Food', income: 400000, expense: 250000),
              IncomeExpenseData(month: 'Trans', income: 300000, expense: 150000),
              IncomeExpenseData(month: 'Heal', income: 200000, expense: 100000),
              IncomeExpenseData(month: 'Shop', income: 200000, expense: 100000),
              IncomeExpenseData(month: 'Rent', income: 150000, expense: 80000),
            ],
            totalIncome: 1250000,
            totalExpense: 680000,
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
