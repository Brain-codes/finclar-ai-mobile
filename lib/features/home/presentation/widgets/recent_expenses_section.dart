import 'package:finclar_ai/shared/icons/app_icons.dart';
import 'package:finclar_ai/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../expenses/presentation/widgets/expense_category_utils.dart';
import '../../../expenses/providers/expense_providers.dart';

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

class RecentExpensesSection extends ConsumerWidget {
  final bool isEmpty;
  final VoidCallback? onViewAll;

  const RecentExpensesSection({
    super.key,
    this.isEmpty = false,
    this.onViewAll,
  });

  static HomeExpenseItem _toItem(ExpenseModel e) => HomeExpenseItem(
        merchant: e.name,
        detail: e.category,
        amount: NumberFormat('#,##0.00').format(e.amount),
        date: DateFormat('MMM d, yyyy').format(e.date),
        categoryColor: expenseCategoryColor(e.category),
        iconType: HomeExpenseIconType.appIcon,
        iconData: expenseCategoryIcon(e.category),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final state = ref.watch(expenseListProvider);

    final items = state.valueOrNull?.items ?? const [];
    final recent = items.take(4).map(_toItem).toList();
    final isLoading = state.isLoading;
    final showEmpty = isEmpty || (!isLoading && recent.isEmpty);
    final count = state.valueOrNull?.items.length ?? 0;

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
                    '$count total',
                    style: AppTypography.labelMedium.copyWith(
                      color: context.textSecondary,
                      fontVariations: const [FontVariation('wght', 400)],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (!showEmpty && !isLoading)
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
          if (isLoading)
            const _RecentExpensesSkeleton()
          else if (showEmpty)
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
              children: recent
                  .map(
                    (e) => _ExpenseTile(
                      item: e,
                      showDivider: e != recent.last,
                      symbol: symbol,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _RecentExpensesSkeleton extends StatelessWidget {
  const _RecentExpensesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              AppSkeleton.circle(size: 40),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton.text(width: 120),
                    SizedBox(height: 6),
                    AppSkeleton.text(width: 70, height: 12),
                  ],
                ),
              ),
              AppSkeleton.text(width: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final HomeExpenseItem item;
  final bool showDivider;
  final String symbol;

  const _ExpenseTile({
    required this.item,
    required this.showDivider,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {

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
                    '$symbol${item.amount}',
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

  Color _bgColor(Color c) {
    if (c == AppColors.categoryFood) return AppColors.categoryFoodBg;
    if (c == AppColors.categoryTransport) return AppColors.categoryTransportBg;
    if (c == AppColors.categoryHealth) return AppColors.categoryHealthBg;
    if (c == AppColors.categoryShopping) return AppColors.categoryShoppingBg;
    return AppColors.primaryMuted;
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor(item.categoryColor);
    final fg = item.categoryColor;
    final radius = AppRadius.radiusCard.topLeft.x;

    return AppAvatar(
      size: 40,
      shape: BoxShape.rectangle,
      borderRadius: radius,
      imageUrl: item.iconType == HomeExpenseIconType.imageUrl ? item.imageUrl : null,
      svgAsset: item.iconType == HomeExpenseIconType.svgAsset ? item.svgPath : null,
      svgNetwork: item.iconType == HomeExpenseIconType.svgNetwork ? item.svgPath : null,
      icon: item.iconData ?? AppIcons.wallet,
      backgroundColor: bg,
      foregroundColor: fg,
    );
  }
}
