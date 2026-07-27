import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_stripe_painter.dart';

class BudgetCategoryItem {
  final String name;
  final int? entries;
  final double spent;
  final double allocated;
  final String? allocationLabel;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const BudgetCategoryItem({
    required this.name,
    this.entries,
    required this.spent,
    required this.allocated,
    this.allocationLabel,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

/// Each budget category is its own standalone white card (r=24), matching Figma.
class BudgetCategoryTile extends ConsumerWidget {
  final BudgetCategoryItem item;
  final VoidCallback? onTap;

  const BudgetCategoryTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
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
                AppAvatar(
                  size: 40,
                  icon: item.icon,
                  backgroundColor: item.bgColor,
                  foregroundColor: item.color,
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
                    if (item.entries != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${item.entries} entries',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                  '${formatCurrency(item.spent, symbol)} / ${formatCurrency(item.allocated, symbol)} spent',
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
