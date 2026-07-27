import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/plan_model.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final PlanModel plan;
  final String symbol;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.symbol,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price = formatCurrency(
      plan.majorAmount,
      symbol,
      abbreviate: false,
      withCommas: true,
    );
    final period = plan.isYearly ? 'Yearly' : 'Monthly';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF6F0) : context.scaffoldColor,
          borderRadius: AppRadius.radiusSheet,
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Icon(
                  isSelected ? AppIcons.radioChecked : AppIcons.radioUnchecked,
                  size: 20,
                  color: isSelected ? AppColors.primary : context.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              plan.name,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textTertiary,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              price,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textPrimary,
                fontVariations: const [FontVariation('wght', 600)],
                fontSize: 20,
              ),
            ),
            Text(
              period,
              style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
