import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../data/models/expense_model.dart';
import '../../providers/category_color_sync_provider.dart';
import 'expense_category_utils.dart';
import 'expense_verification_badge.dart';

class ExpenseTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final visual = categoryVisualFor(
      name: expense.category,
      categoryId: expense.categoryId,
      categoriesById: ref.watch(categoriesByIdProvider),
      syncedColors: ref.watch(categoryColorSyncProvider).valueOrNull,
    );
    final color = visual.color;
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
                ExpenseCategoryIcon(visual: visual),
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

class ExpenseCategoryIcon extends ConsumerWidget {
  /// Preferred: pass the already-resolved visual (e.g. from [ExpenseTile],
  /// which has the expense's `categoryId` to look up the real icon/color).
  final CategoryVisual? visual;

  /// Fallback for callers that only have a bare category name — resolves via
  /// the name-based defaults only, since there's no id to look up.
  final String? category;

  final double size;

  const ExpenseCategoryIcon({
    super.key,
    this.visual,
    this.category,
    this.size = 40,
  }) : assert(visual != null || category != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = visual ??
        categoryVisualFor(
          name: category!,
          categoriesById: ref.watch(categoriesByIdProvider),
          syncedColors: ref.watch(categoryColorSyncProvider).valueOrNull,
        );
    return AppAvatar(
      size: size,
      icon: v.icon,
      backgroundColor: v.bgColor,
      foregroundColor: v.color,
    );
  }
}
