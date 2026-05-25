import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';
import 'budget_add_category_sheet.dart';

Future<String?> showBudgetCategorySheet(BuildContext context) {
  return showAppSheet<String>(
    context,
    title: 'Category',
    children: [const _CategoryContent()],
  );
}

class _CategoryContent extends StatelessWidget {
  const _CategoryContent();

  static const _categories = [
    _CategoryRow(name: 'Food', icon: AppIcons.categoryFood, color: AppColors.categoryFood, bg: AppColors.categoryFoodBg),
    _CategoryRow(name: 'Transportation', icon: AppIcons.categoryTransport, color: AppColors.categoryTransport, bg: AppColors.categoryTransportBg),
    _CategoryRow(name: 'Health', icon: AppIcons.categoryHealth, color: AppColors.categoryHealth, bg: AppColors.categoryHealthBg),
    _CategoryRow(name: 'Shopping', icon: AppIcons.categoryShopping, color: AppColors.categoryShopping, bg: AppColors.categoryShoppingBg),
    _CategoryRow(name: 'Rent', icon: AppIcons.wallet, color: AppColors.primary, bg: AppColors.primaryMuted),
    _CategoryRow(name: 'Entertainment', icon: AppIcons.categoryEntertainment, color: AppColors.categoryTransport, bg: AppColors.categoryTransportBg),
    _CategoryRow(name: 'Investment', icon: AppIcons.briefcase, color: AppColors.categoryHealth, bg: AppColors.categoryHealthBg),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.radiusSheet,
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: _categories.asMap().entries.map((e) {
              final isLast = e.key == _categories.length - 1;
              return Column(
                children: [
                  _CategoryRowTile(
                    row: e.value,
                    onTap: () => Navigator.of(context).pop(e.value.name),
                  ),
                  if (!isLast)
                    Divider(
                      color: context.borderColor,
                      height: 1,
                      thickness: 1,
                      indent: AppSpacing.base,
                      endIndent: AppSpacing.base,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        GestureDetector(
          onTap: () async {
            Navigator.of(context).pop();
            await showBudgetAddCategorySheet(context);
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: context.surfaceVariant,
              borderRadius: AppRadius.radiusFull,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.addCircle, size: 18, color: context.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Add category',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                    fontSize: 14,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow {
  final String name;
  final IconData icon;
  final Color color;
  final Color bg;

  const _CategoryRow({
    required this.name,
    required this.icon,
    required this.color,
    required this.bg,
  });
}

class _CategoryRowTile extends StatelessWidget {
  final _CategoryRow row;
  final VoidCallback onTap;

  const _CategoryRowTile({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: row.bg, shape: BoxShape.circle),
              child: Icon(row.icon, size: 18, color: row.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              row.name,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textQuaternary,
                fontSize: 14,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
