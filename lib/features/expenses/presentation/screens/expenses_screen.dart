import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../data/models/expense_filter.dart';
import '../../providers/expense_providers.dart';
import '../widgets/expense_active_filters.dart';
import '../widgets/expense_empty_state.dart';
import '../widgets/expense_filter_sheet.dart';
import '../widgets/expense_header.dart';
import '../widgets/expense_list.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/month_selection_sheet.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(expenseListProvider.notifier).loadMore();
    }
  }

  Future<void> _pickMonth(int current) async {
    final result = await showMonthSelectionSheet(context, selected: current);
    if (result != null) {
      ref.read(expenseListProvider.notifier).setMonth(result);
    }
  }

  Future<void> _openFilters(ExpenseFilter current) async {
    final result = await showExpenseFilterSheet(context, current: current);
    if (result != null) _applyFilter(result);
  }

  void _applyFilter(ExpenseFilter filter) {
    ref.read(expenseListProvider.notifier).setFilter(filter);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseListProvider);
    final filter = ref.watch(expenseFilterProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(expenseListProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ExpenseHeader(
                  onFilter: () => _openFilters(filter),
                  activeFilterCount: filter.activeCount,
                ),
              ),
              SliverToBoxAdapter(
                child: ExpenseActiveFilters(
                  filter: filter,
                  onChanged: _applyFilter,
                  onClearAll: () =>
                      ref.read(expenseListProvider.notifier).clearFilter(),
                ),
              ),
              ...state.when(
                loading: () => [
                  const SliverToBoxAdapter(child: _ExpensesSkeleton()),
                ],
                error: (_, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ExpensesError(
                      onRetry: () =>
                          ref.read(expenseListProvider.notifier).refresh(),
                    ),
                  ),
                ],
                data: (data) => _buildContent(data, filter),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(ExpenseListState data, ExpenseFilter filter) {
    if (data.isEmpty) {
      return [
        // The month picker lives on the summary card, so it has to stay
        // reachable when a filter empties the list — otherwise the only way
        // out is clearing the filter.
        if (filter.isActive)
          SliverToBoxAdapter(
            child: ExpenseSummaryCard(
              total: 0,
              categoryTotals: const {},
              selectedMonth: data.month,
              periodLabel: filter.hasDateRange ? filter.dateLabel : null,
              onMonthTap: () => _pickMonth(data.month),
            ),
          ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: ExpenseEmptyState(
            onClearFilters: filter.isActive
                ? () => ref.read(expenseListProvider.notifier).clearFilter()
                : null,
          ),
        ),
      ];
    }
    return [
      SliverToBoxAdapter(
        child: ExpenseSummaryCard(
          total: data.total,
          categoryTotals: {
            for (final c in data.categoryBreakdown) c.name: c.amount,
          },
          selectedMonth: data.month,
          periodLabel: filter.hasDateRange ? filter.dateLabel : null,
          onMonthTap: () => _pickMonth(data.month),
        ),
      ),
      SliverToBoxAdapter(child: ExpenseList(expenses: data.items)),
      if (data.isLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.base),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
    ];
  }
}

class _ExpensesSkeleton extends StatelessWidget {
  const _ExpensesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.radiusSheet,
            ),
            padding: const EdgeInsets.all(AppSpacing.base),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.text(width: 100, height: 12),
                SizedBox(height: AppSpacing.sm),
                AppSkeleton.text(width: 160, height: 28),
                SizedBox(height: AppSpacing.base),
                AppSkeleton(width: double.infinity, height: 14),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.radiusSheet,
            ),
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: List.generate(
                5,
                (_) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      AppSkeleton.circle(size: 40),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSkeleton.text(width: 120),
                            SizedBox(height: 6),
                            AppSkeleton.text(width: 70, height: 12),
                          ],
                        ),
                      ),
                      AppSkeleton.text(width: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpensesError extends StatelessWidget {
  final VoidCallback onRetry;
  const _ExpensesError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.file, size: 40, color: context.textSecondary),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Could not load expenses',
            style: TextStyle(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.base),
          GestureDetector(
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
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
