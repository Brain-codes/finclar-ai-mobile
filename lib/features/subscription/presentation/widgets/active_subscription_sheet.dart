import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import 'cancellation_sheet.dart';

Future<void> showActiveSubscriptionSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ActiveSubscriptionSheet(),
  );
}

class _ActiveSubscriptionSheet extends StatelessWidget {
  const _ActiveSubscriptionSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subscription',
                style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.scaffoldColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Icon(AppIcons.close, size: 16, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6F0),
              borderRadius: AppRadius.radiusSheet,
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clara + yearly',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textTertiary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '₦28,000',
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textPrimary,
                    fontVariations: const [FontVariation('wght', 600)],
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Yearly',
                  style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Your Clara + subscription is active through',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'March 7, 2026 – March 8, 2027',
            style: AppTypography.headingLarge.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Cancel subscription',
            onTap: () async {
              Navigator.of(context).pop();
              await showCancellationSheet(context);
            },
            height: 48,
          ),
        ],
      ),
    );
  }
}
