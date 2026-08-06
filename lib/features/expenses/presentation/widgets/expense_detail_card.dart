import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../data/models/expense_model.dart';
import 'expense_category_utils.dart';
import 'expense_verification_badge.dart';

class ExpenseDetailCard extends StatelessWidget {
  final ExpenseModel expense;
  const ExpenseDetailCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0.00').format(expense.amount);
    final categoryColor = expenseCategoryColor(expense.category);

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
          _DetailRow(label: 'Merchant', value: expense.merchant ?? '--'),
          _Divider(),
          _DetailRow(label: 'Note', value: expense.note ?? '--'),
          _Divider(),
          _DetailRow(
            label: 'Date',
            value: DateFormat('MMMM d, yyyy').format(expense.date),
          ),
          _Divider(),
          _DetailRow(
            label: 'Source',
            valueWidget:
                ExpenseVerificationBadge(level: expense.verificationLevel),
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
          const SizedBox(width: AppSpacing.base),
          // Expanded (not Spacer) so a long name or note ellipsizes instead of
          // overflowing the card.
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget ??
                  Text(
                    value ?? '--',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textQuaternary,
                      fontSize: 14,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
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
