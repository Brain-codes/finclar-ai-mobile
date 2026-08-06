import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../data/models/expense_model.dart';
import 'expense_category_utils.dart';
import 'expense_verification_badge.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final bool showDivider;
  final VoidCallback? onTap;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.showDivider = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = expenseCategoryColor(expense.category);
    final formatted = NumberFormat('#,##0.00').format(expense.amount);

    return GestureDetector(
      onTap: onTap,
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
                ExpenseCategoryIcon(category: expense.category),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textQuaternary,
                          fontSize: 14,
                          fontVariations: const [FontVariation('wght', 500)],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              expense.category,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: color,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '·',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          ExpenseVerificationLabel(
                            level: expense.verificationLevel,
                          ),
                        ],
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

// ─── Category icon ────────────────────────────────────────────────────────────

class ExpenseCategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const ExpenseCategoryIcon({
    super.key,
    required this.category,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      size: size,
      icon: expenseCategoryIcon(category),
      backgroundColor: expenseCategoryBgColor(category),
      foregroundColor: expenseCategoryColor(category),
    );
  }
}
