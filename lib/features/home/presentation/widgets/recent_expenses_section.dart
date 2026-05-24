import 'package:finclar_ai/shared/icons/app_icons.dart';
import 'package:finclar_ai/shared/widgets/app_svg_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

enum HomeExpenseIconType { imageUrl, svgAsset, svgNetwork, appIcon }

class HomeExpenseItem {
  final String merchant;
  final String? detail;
  final String amount;
  final String date;
  final Color categoryColor;
  final bool isDebit;
  final HomeExpenseIconType iconType;
  final String? imageUrl;
  final String? svgPath;
  final IconData? iconData;

  const HomeExpenseItem({
    required this.merchant,
    this.detail,
    required this.amount,
    required this.date,
    required this.categoryColor,
    this.isDebit = true,
    this.iconType = HomeExpenseIconType.appIcon,
    this.imageUrl,
    this.svgPath,
    this.iconData,
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
        detail: 'Food & Drinks',
        amount: '5,000.00',
        date: 'Apr 3, 2026',
        categoryColor: AppColors.categoryFood,
        isDebit: true,
        iconType: HomeExpenseIconType.appIcon,
        iconData: AppIcons.categoryFood,
      ),
      HomeExpenseItem(
        merchant: 'Gacoan',
        detail: 'Food & Drinks',
        amount: '126,600.00',
        date: 'Apr 3, 2026',
        categoryColor: AppColors.categoryFood,
        isDebit: true,
        iconType: HomeExpenseIconType.appIcon,
        iconData: AppIcons.categoryFood,
      ),
      HomeExpenseItem(
        merchant: 'Amoke Oge',
        detail: 'Health',
        amount: '6,600.00',
        date: 'Apr 2, 2026',
        categoryColor: AppColors.categoryHealth,
        isDebit: true,
        iconType: HomeExpenseIconType.appIcon,
        iconData: AppIcons.categoryHealth,
      ),
      HomeExpenseItem(
        merchant: 'Daravit',
        detail: 'Shopping',
        amount: '10,600.00',
        date: 'Apr 1, 2026',
        categoryColor: AppColors.categoryShopping,
        isDebit: true,
        iconType: HomeExpenseIconType.appIcon,
        iconData: AppIcons.categoryShopping,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.recentExpenses,
                    style: AppTypography.labelMedium.copyWith(
                      color: context.textPrimary,
                      fontVariations: const [FontVariation('wght', 600)],
                    ),
                  ),
                  Text(
                    '${expenses.length} total',
                    style: AppTypography.labelMedium.copyWith(
                      color: context.textSecondary,
                      fontVariations: const [FontVariation('wght', 400)],
                      fontSize: 12,
                    ),
                  ),
                ],
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
    final amountColor = item.isDebit
        ? AppColors.error
        : AppColors.categoryHealth;
    final amountPrefix = item.isDebit ? '-' : '+';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              _ExpenseIcon(item: item),
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
                          color: item.categoryColor,
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
                    '₦${item.amount}',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textQuaternary,
                      fontSize: 14,
                      fontVariations: const [FontVariation('wght', 400)],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.date,
                    style: AppTypography.labelXSmall.copyWith(
                      color: context.textSecondary,
                      fontSize: 12,
                      fontVariations: const [FontVariation('wght', 400)],
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
}

class _ExpenseIcon extends StatelessWidget {
  final HomeExpenseItem item;

  const _ExpenseIcon({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusCard,
      child: Container(
        width: 40,
        height: 40,
        color: _bgColor(item.categoryColor),
        child: _iconChild(),
      ),
    );
  }

  Widget _iconChild() {
    switch (item.iconType) {
      case HomeExpenseIconType.imageUrl:
        if (item.imageUrl != null) {
          return Image.network(
            item.imageUrl!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _fallbackIcon(),
          );
        }
        return _fallbackIcon();

      case HomeExpenseIconType.svgAsset:
        if (item.svgPath != null) {
          return Center(
            child: AppSvgImage(
              item.svgPath!,
              width: 22,
              height: 22,
              color: item.categoryColor,
            ),
          );
        }
        return _fallbackIcon();

      case HomeExpenseIconType.svgNetwork:
        if (item.svgPath != null) {
          return Center(
            child: AppSvgImage.network(
              item.svgPath!,
              width: 22,
              height: 22,
              color: item.categoryColor,
            ),
          );
        }
        return _fallbackIcon();

      case HomeExpenseIconType.appIcon:
        return Center(
          child: Icon(
            item.iconData ?? AppIcons.wallet,
            size: 20,
            color: item.categoryColor,
          ),
        );
    }
  }

  Widget _fallbackIcon() {
    return Center(
      child: Icon(AppIcons.wallet, size: 20, color: item.categoryColor),
    );
  }

  Color _bgColor(Color c) {
    if (c == AppColors.categoryFood) return AppColors.categoryFoodBg;
    if (c == AppColors.categoryTransport) return AppColors.categoryTransportBg;
    if (c == AppColors.categoryHealth) return AppColors.categoryHealthBg;
    if (c == AppColors.categoryShopping) return AppColors.categoryShoppingBg;
    return AppColors.primaryMuted;
  }
}
