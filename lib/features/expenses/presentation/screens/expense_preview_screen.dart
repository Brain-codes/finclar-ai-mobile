import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/expense_model.dart';
import '../widgets/delete_expense_sheet.dart';
import '../widgets/edit_expense_sheet.dart';

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
            _TopBar(onBack: () => context.pop(), onEdit: _onEdit, onDelete: _onDelete),
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: _DetailsCard(expense: _expense),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TopBar({
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.back, size: 20, color: context.textQuaternary),
            ),
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border.all(color: context.borderColor),
              borderRadius: AppRadius.radiusFull,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: context.borderColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(AppIcons.edit, size: 16, color: context.textQuaternary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Edit',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textQuaternary,
                            fontSize: 14,
                            fontVariations: const [FontVariation('wght', 500)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Icon(
                      AppIcons.delete,
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

// ─── Details card ─────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final ExpenseModel expense;
  const _DetailsCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0.00').format(expense.amount);
    final categoryColor = _categoryColor(expense.category);

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Item name', value: expense.name),
          _Divider(),
          _DetailRow(label: 'Amount', value: '₦$formatted'),
          _Divider(),
          _DetailRow(
            label: 'Category',
            valueWidget: Text(
              expense.category,
              style: AppTypography.bodyMedium.copyWith(
                color: categoryColor,
                fontSize: 14,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ),
          _Divider(),
          _DetailRow(
            label: 'Merchant',
            value: expense.merchant ?? '--',
          ),
          _Divider(),
          _DetailRow(label: 'Note', value: expense.note ?? '--'),
          _Divider(),
          _DetailRow(
            label: 'Date',
            value: DateFormat('MMMM d, yyyy').format(expense.date),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  const _DetailRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          valueWidget ??
              Text(
                value ?? '--',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textQuaternary,
                  fontSize: 14,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.borderColor,
      indent: AppSpacing.base,
      endIndent: AppSpacing.base,
    );
  }
}

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
