import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_sheet.dart';

Future<bool?> showBudgetDeleteSheet(BuildContext context) {
  return showAppSheet<bool>(
    context,
    title: 'Delete budget?',
    children: [const _DeleteContent()],
  );
}

class _DeleteContent extends StatelessWidget {
  const _DeleteContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF9EAEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Delete budget?',
          style: AppTypography.headingSmall.copyWith(color: context.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Your budget will be cleared. You can always add a budget',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cancel',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                      fontSize: 14,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Delete',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 14,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
