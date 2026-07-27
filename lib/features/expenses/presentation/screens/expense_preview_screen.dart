import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_loading_overlay.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_providers.dart';
import '../widgets/delete_expense_sheet.dart';
import '../widgets/edit_expense_sheet.dart';
import '../widgets/expense_detail_card.dart';
import '../widgets/expense_preview_top_bar.dart';

class ExpensePreviewScreen extends ConsumerStatefulWidget {
  final ExpenseModel expense;
  const ExpensePreviewScreen({super.key, required this.expense});

  @override
  ConsumerState<ExpensePreviewScreen> createState() =>
      _ExpensePreviewScreenState();
}

class _ExpensePreviewScreenState extends ConsumerState<ExpensePreviewScreen> {
  late ExpenseModel _expense;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  Future<void> _onEdit() async {
    final result = await showEditExpenseSheet(context, expense: _expense);
    if (result != null && mounted) setState(() => _expense = result);
  }

  Future<void> _onDelete() async {
    final confirmed = await showDeleteExpenseSheet(context);
    if (confirmed != true || !mounted) return;
    setState(() => _isDeleting = true);
    try {
      await ref.read(expenseListProvider.notifier).delete(_expense.id);
      if (mounted) {
        AppSnackbar.success(context, 'Expense deleted');
        context.pop();
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        AppSnackbar.error(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: Stack(
        children: [
          SafeArea(
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
          if (_isDeleting) const AppLoadingOverlay(),
        ],
      ),
    );
  }
}
