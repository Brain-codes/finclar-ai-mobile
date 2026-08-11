import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';

Future<bool?> showDeleteReceiptSheet(BuildContext context) {
  return showAppSheet<bool>(
    context,
    title: '',
    children: const [_DeleteReceiptContent()],
  );
}

class _DeleteReceiptContent extends StatelessWidget {
  const _DeleteReceiptContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFF9EAEA),
            shape: BoxShape.circle,
          ),
          child: const Icon(AppIcons.delete, size: 28, color: AppColors.error),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Delete receipt?',
          textAlign: TextAlign.center,
          style: AppTypography.headingMedium.copyWith(
            color: context.textPrimary,
            fontSize: 24,
            fontVariations: const [FontVariation('wght', 600)],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'This expense and all its items will be cleared. The data can not be recovered',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textTertiary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cancel',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textTertiary,
                      fontSize: 16,
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
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Delete',
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
        ),
      ],
    );
  }
}
