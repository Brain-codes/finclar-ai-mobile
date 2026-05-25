import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';

class BudgetCategoryItem {
  final String name;
  final int entries;
  final double spent;
  final double allocated;
  final String? allocationLabel;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const BudgetCategoryItem({
    required this.name,
    required this.entries,
    required this.spent,
    required this.allocated,
    this.allocationLabel,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

/// Each budget category is its own standalone white card (r=24), matching Figma.
class BudgetCategoryTile extends StatelessWidget {
  final BudgetCategoryItem item;
  final VoidCallback? onTap;

  const BudgetCategoryTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final fraction =
        item.allocated > 0 ? (item.spent / item.allocated).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
          border: Border.all(color: context.borderColor),
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + name / entries row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 16, color: item.color),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textQuaternary,
                        fontSize: 14,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.entries} entries',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Stacked bar
            _StackedBar(fraction: fraction, color: item.color),
            const SizedBox(height: AppSpacing.sm),
            // Spent text + allocation label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₦${_fmt(item.spent)} / ₦${_fmt(item.allocated)} spent',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (item.allocationLabel != null)
                  Text(
                    item.allocationLabel!,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textQuaternary,
                      fontSize: 12,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

class _StackedBar extends StatelessWidget {
  final double fraction;
  final Color color;

  const _StackedBar({required this.fraction, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final total = constraints.maxWidth;
        final spentW = total * fraction;
        final remW = total - spentW;
        return ClipRRect(
          borderRadius: AppRadius.radiusXs,
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                if (spentW > 0) Container(width: spentW, color: color),
                if (remW > 0)
                  SizedBox(
                    width: remW,
                    height: 14,
                    child: CustomPaint(
                      painter: AppStripePainter(
                        backgroundColor: context.surfaceVariant,
                        stripeColor: color.withValues(alpha: 0.25),
                        spacing: 5,
                        strokeWidth: 1.5,
                        angleDegrees: 45,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const List<BudgetCategoryItem> defaultBudgetCategories = [
  BudgetCategoryItem(
    name: 'Food',
    entries: 12,
    spent: 250000,
    allocated: 400000,
    allocationLabel: '50% of allocation',
    icon: AppIcons.categoryFood,
    color: AppColors.categoryFood,
    bgColor: AppColors.categoryFoodBg,
  ),
  BudgetCategoryItem(
    name: 'Transportation',
    entries: 8,
    spent: 150000,
    allocated: 300000,
    allocationLabel: '50% of allocation',
    icon: AppIcons.categoryTransport,
    color: AppColors.categoryTransport,
    bgColor: AppColors.categoryTransportBg,
  ),
  BudgetCategoryItem(
    name: 'Health',
    entries: 2,
    spent: 100000,
    allocated: 200000,
    allocationLabel: '20% of allocation',
    icon: AppIcons.categoryHealth,
    color: AppColors.categoryHealth,
    bgColor: AppColors.categoryHealthBg,
  ),
  BudgetCategoryItem(
    name: 'Shopping',
    entries: 4,
    spent: 100000,
    allocated: 200000,
    allocationLabel: '20% of allocation',
    icon: AppIcons.categoryShopping,
    color: AppColors.categoryShopping,
    bgColor: AppColors.categoryShoppingBg,
  ),
];
