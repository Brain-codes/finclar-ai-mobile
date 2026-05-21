import 'package:finclar_ai/shared/icons/app_icons.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class HomeExpenseItem {
  final String merchant;
  final String? detail;
  final String amount;
  final String date;
  final Color categoryColor;
  final IconData? icon;

  const HomeExpenseItem({
    required this.merchant,
    this.detail,
    required this.amount,
    required this.date,
    required this.categoryColor,
    this.icon,
  });
}

class RecentExpensesSection extends StatelessWidget {
  final bool isEmpty;
  final List<HomeExpenseItem> expenses;
  final VoidCallback? onViewAll;

  const RecentExpensesSection({
    super.key,
    this.isEmpty = false,
    this.expenses = const [
      HomeExpenseItem(
        merchant: 'Blackbell',
        detail: null,
        amount: '-₦5,000.00',
        date: 'Apr 3, 2026',
        categoryColor: AppColors.categoryFood,
      ),
      HomeExpenseItem(
        merchant: 'Gacoan',
        detail: null,
        amount: '-₦126,600.00',
        date: 'Apr 3, 2026',
        categoryColor: AppColors.categoryFood,
      ),
      HomeExpenseItem(
        merchant: 'Amoke Oge',
        detail: 'Lekki Phase 1',
        amount: '-₦6,600.00',
        date: 'Apr 2, 2026',
        categoryColor: AppColors.categoryHealth,
      ),
      HomeExpenseItem(
        merchant: 'Daravit',
        detail: '18 items',
        amount: '-₦10,600.00',
        date: 'Apr 1, 2026',
        categoryColor: AppColors.categoryShopping,
      ),
    ],
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Text(
                AppStrings.recentExpenses,
                style: AppTypography.labelMedium.copyWith(
                  color: context.textPrimary,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
              if (!isEmpty)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    AppStrings.viewAll,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(AppIcons.file, size: 20, color: context.textSecondary),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your expenses will be listed here',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: expenses
                  .map(
                    (e) =>
                        _ExpenseTile(item: e, showDivider: e != expenses.last),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final HomeExpenseItem item;
  final bool showDivider;

  const _ExpenseTile({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _bgColor(item.categoryColor),
                  borderRadius: AppRadius.radiusCard,
                ),
                child: Center(
                  child: Text(
                    _emoji(item.categoryColor),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.merchant,
                      style: AppTypography.labelSmall.copyWith(
                        color: context.textPrimary,
                        fontVariations: const [FontVariation('wght', 500)],
                        fontSize: 14,
                      ),
                    ),
                    if (item.detail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.detail!,
                        style: AppTypography.labelXSmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.amount,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.date,
                    style: AppTypography.labelXSmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(color: context.borderColor, height: 1, thickness: 1),
      ],
    );
  }

  Color _bgColor(Color c) {
    if (c == AppColors.categoryFood) return AppColors.categoryFoodBg;
    if (c == AppColors.categoryTransport) return AppColors.categoryTransportBg;
    if (c == AppColors.categoryHealth) return AppColors.categoryHealthBg;
    if (c == AppColors.categoryShopping) return AppColors.categoryShoppingBg;
    return AppColors.primaryMuted;
  }

  String _emoji(Color c) {
    if (c == AppColors.categoryFood) return '🍔';
    if (c == AppColors.categoryTransport) return '🚗';
    if (c == AppColors.categoryHealth) return '💊';
    if (c == AppColors.categoryShopping) return '🛍️';
    return '💰';
  }
}
