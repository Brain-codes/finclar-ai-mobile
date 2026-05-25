import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';

Future<void> showBudgetNoAllocationSheet(
  BuildContext context, {
  VoidCallback? onIncrease,
}) {
  return showAppSheet(
    context,
    title: 'No allocation',
    children: [_NoAllocationContent(onIncrease: onIncrease)],
  );
}

class _NoAllocationContent extends StatelessWidget {
  final VoidCallback? onIncrease;
  const _NoAllocationContent({this.onIncrease});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE9F7EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.income, color: AppColors.primary, size: 28),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'No allocation',
          style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'You do not have any money left for allocation. You can increase your budget to continue.',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              onIncrease?.call();
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.radiusFull,
              ),
              alignment: Alignment.center,
              child: Text(
                'Increase budget',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 16,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
