import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/expense_model.dart';
import '../widgets/delete_expense_sheet.dart';
import '../widgets/edit_expense_sheet.dart';
import '../widgets/expense_detail_card.dart';
import '../widgets/expense_preview_top_bar.dart';

class ExpensePreviewScreen extends StatefulWidget {
  final ExpenseModel expense;
  const ExpensePreviewScreen({super.key, required this.expense});

  @override
  State<ExpensePreviewScreen> createState() => _ExpensePreviewScreenState();
}

class _ExpensePreviewScreenState extends State<ExpensePreviewScreen> {
  late ExpenseModel _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  Future<void> _onEdit() async {
    final result = await showEditExpenseSheet(context, expense: _expense);
    if (result != null) setState(() => _expense = result);
  }

  Future<void> _onDelete() async {
    final confirmed = await showDeleteExpenseSheet(context);
    if (confirmed == true && mounted) {
      AppSnackbar.success(context, 'Expense deleted');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            ExpensePreviewTopBar(
              onBack: () => context.pop(),
              onEdit: _onEdit,
              onDelete: _onDelete,
            ),
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: ExpenseDetailCard(expense: _expense),
            ),
          ],
        ),
      ),
    );
  }
}
