import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

enum SubscriptionPlan { monthly, yearly }

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isYearly = plan == SubscriptionPlan.yearly;
    final label = isYearly ? 'Clara + yearly' : 'Clara + monthly';
    final price = isYearly ? '₦28,000' : '₦3,000';
    final period = isYearly ? 'Yearly' : 'Monthly';

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
              label,
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
