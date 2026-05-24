import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/expense_model.dart';
import '../widgets/month_selection_sheet.dart';

// ─── Sample data (replace with provider later) ────────────────────────────────

final _sampleExpenses = [
  ExpenseModel(
    id: '1',
    name: 'Blackbell',
    amount: 5000,
    category: 'Food',
    date: DateTime(2026, 4, 3),
  ),
  ExpenseModel(
    id: '2',
    name: 'Amoke Oge',
    amount: 6600,
    category: 'Health',
    date: DateTime(2026, 4, 3),
  ),
  ExpenseModel(
    id: '3',
    name: 'Bolt',
    amount: 3200,
    category: 'Transport',
    date: DateTime(2026, 4, 2),
  ),
  ExpenseModel(
    id: '4',
    name: 'Zara',
    amount: 18000,
    category: 'Shopping',
    date: DateTime(2026, 4, 1),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  // Toggle to demo both states
  final List<ExpenseModel> _expenses = _sampleExpenses;
  int _selectedMonth = DateTime.now().month;

  bool get _isEmpty => _expenses.isEmpty;

  double get _totalAmount =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  Future<void> _pickMonth() async {
    final result = await showMonthSelectionSheet(
      context,
      selected: _selectedMonth,
    );
    if (result != null) setState(() => _selectedMonth = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Header(onFilter: () {})),
                SliverToBoxAdapter(
                  child: _isEmpty
                      ? _EmptyCard()
                      : _FilledCard(
                          total: _totalAmount,
                          expenses: _expenses,
                          selectedMonth: _selectedMonth,
                          onMonthTap: _pickMonth,
                        ),
                ),
                if (!_isEmpty) ...[
                  SliverToBoxAdapter(
                    child: _ExpenseList(expenses: _expenses),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            Positioned(
              bottom: AppSpacing.xxl,
              right: AppSpacing.screenPadding,
              child: _Fab(onTap: () => context.push(RouteNames.addExpense)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onFilter;
  const _Header({required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.base,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Expense',
            style: AppTypography.headingMedium.copyWith(
              color: context.textPrimary,
              fontSize: 24,
            ),
          ),
          GestureDetector(
            onTap: onFilter,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderColor),
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
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(AppIcons.file, size: 64, color: context.textSecondary),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No expenses yet',
              style: AppTypography.headingSmall.copyWith(
                color: context.textPrimary,
                fontSize: 20,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "You've not logged an expense yet. Tap on the plus button to log an expense",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filled summary card ──────────────────────────────────────────────────────

class _FilledCard extends StatelessWidget {
  final double total;
  final List<ExpenseModel> expenses;
  final int selectedMonth;
  final VoidCallback onMonthTap;

  const _FilledCard({
    required this.total,
    required this.expenses,
    required this.selectedMonth,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM').format(DateTime(0, selectedMonth));
    final formatted = NumberFormat('#,##0.00').format(total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total expense',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦$formatted',
                      style: AppTypography.amountLarge.copyWith(
                        color: context.textQuaternary,
                        fontSize: 24,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onMonthTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: AppRadius.radiusFull,
                    ),
                    child: Text(
                      monthName,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textQuaternary,
                        fontSize: 12,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            _CategoryBar(expenses: expenses),
            const SizedBox(height: AppSpacing.md),
            _CategoryLegend(expenses: expenses),
          ],
        ),
      ),
    );
  }
}

// ─── Stacked category bar ─────────────────────────────────────────────────────

class _CategoryBar extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const _CategoryBar({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final byCategory = <String, double>{};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    final total = byCategory.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final segments = byCategory.entries.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        return ClipRRect(
          borderRadius: AppRadius.radiusXs,
          child: Row(
            children: segments.map((entry) {
              final width = totalWidth * (entry.value / total);
              return Container(
                width: width,
                height: 14,
                color: _categoryColor(entry.key),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ─── Category legend ──────────────────────────────────────────────────────────

class _CategoryLegend extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const _CategoryLegend({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final categories = expenses.map((e) => e.category).toSet().toList();
    return Wrap(
      spacing: AppSpacing.base,
      runSpacing: AppSpacing.xs,
      children: categories
          .map((cat) => _LegendItem(category: cat))
          .toList(),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String category;
  const _LegendItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _categoryColor(category),
            borderRadius: AppRadius.radiusXs,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          category,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─── Expense list ─────────────────────────────────────────────────────────────

class _ExpenseList extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const _ExpenseList({required this.expenses});

  @override
  Widget build(BuildContext context) {
    // Group by date
    final groups = <String, List<ExpenseModel>>{};
    for (final e in expenses) {
      final key = DateFormat('MMM d, yyyy').format(e.date);
      groups.putIfAbsent(key, () => []).add(e);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.base,
      ),
      child: Column(
        children: groups.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.radiusSheet,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.base,
                    AppSpacing.base,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    entry.key,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                      fontSize: 12,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ),
                ...entry.value.map((e) => _ExpenseTile(
                      expense: e,
                      showDivider: e != entry.value.last,
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Expense tile ─────────────────────────────────────────────────────────────

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final bool showDivider;
  const _ExpenseTile({required this.expense, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(expense.category);
    final formatted = NumberFormat('#,##0.00').format(expense.amount);

    return GestureDetector(
      onTap: () => context.push(
        RouteNames.expenseDetail,
        extra: expense,
      ),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                _ExpenseIcon(category: expense.category, color: color),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.name,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textQuaternary,
                          fontSize: 14,
                          fontVariations: const [FontVariation('wght', 500)],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        expense.category,
                        style: AppTypography.bodySmall.copyWith(
                          color: color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₦$formatted',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textQuaternary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, yyyy').format(expense.date),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: context.borderColor,
              indent: AppSpacing.base,
              endIndent: AppSpacing.base,
            ),
        ],
      ),
    );
  }
}

class _ExpenseIcon extends StatelessWidget {
  final String category;
  final Color color;
  const _ExpenseIcon({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _categoryBgColor(category),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _categoryIcon(category),
        size: 16,
        color: color,
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────

class _Fab extends StatelessWidget {
  final VoidCallback onTap;
  const _Fab({required this.onTap});

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
        child: const Icon(AppIcons.add, size: 24, color: AppColors.white),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppColors.categoryFood;
    case 'transport':
    case 'transportation':
      return AppColors.categoryTransport;
    case 'health':
      return AppColors.categoryHealth;
    case 'shopping':
      return AppColors.categoryShopping;
    default:
      return AppColors.primary;
  }
}

Color _categoryBgColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppColors.categoryFoodBg;
    case 'transport':
    case 'transportation':
      return AppColors.categoryTransportBg;
    case 'health':
      return AppColors.categoryHealthBg;
    case 'shopping':
      return AppColors.categoryShoppingBg;
    default:
      return AppColors.primaryMuted;
  }
}

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return AppIcons.categoryFood;
    case 'transport':
    case 'transportation':
      return AppIcons.categoryTransport;
    case 'health':
      return AppIcons.categoryHealth;
    case 'shopping':
      return AppIcons.categoryShopping;
    default:
      return AppIcons.wallet;
  }
}
