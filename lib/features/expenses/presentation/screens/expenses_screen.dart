import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/expense_model.dart';
import '../widgets/expense_empty_state.dart';
import '../widgets/expense_header.dart';
import '../widgets/expense_list.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/month_selection_sheet.dart';

// Sample data — replace with provider
final _sampleExpenses = [
  ExpenseModel(id: '1', name: 'Blackbell', amount: 5000, category: 'Food', date: DateTime(2026, 4, 3)),
  ExpenseModel(id: '2', name: 'Amoke Oge', amount: 6600, category: 'Health', date: DateTime(2026, 4, 3)),
  ExpenseModel(id: '3', name: 'Bolt', amount: 3200, category: 'Transport', date: DateTime(2026, 4, 2)),
  ExpenseModel(id: '4', name: 'Zara', amount: 18000, category: 'Shopping', date: DateTime(2026, 4, 1)),
];

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<ExpenseModel> _expenses = _sampleExpenses;
  int _selectedMonth = DateTime.now().month;

  bool get _isEmpty => _expenses.isEmpty;
  double get _total => _expenses.fold(0, (sum, e) => sum + e.amount);

  Future<void> _pickMonth() async {
    final result = await showMonthSelectionSheet(context, selected: _selectedMonth);
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
                SliverToBoxAdapter(child: ExpenseHeader(onFilter: () {})),
                SliverToBoxAdapter(
                  child: _isEmpty
                      ? const ExpenseEmptyState()
                      : ExpenseSummaryCard(
                          total: _total,
                          expenses: _expenses,
                          selectedMonth: _selectedMonth,
                          onMonthTap: _pickMonth,
                        ),
                ),
                if (!_isEmpty)
                  SliverToBoxAdapter(child: ExpenseList(expenses: _expenses)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            Positioned(
              bottom: AppSpacing.xxl,
              right: AppSpacing.screenPadding,
              child: _ExpenseFab(onTap: () => context.push(RouteNames.addExpense)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseFab extends StatelessWidget {
  final VoidCallback onTap;
  const _ExpenseFab({required this.onTap});

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
