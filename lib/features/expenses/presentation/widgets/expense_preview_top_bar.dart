import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

class ExpensePreviewTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpensePreviewTopBar({
    super.key,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.back, size: 20, color: context.textQuaternary),
            ),
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              border: Border.all(color: context.borderColor),
              borderRadius: AppRadius.radiusFull,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: context.borderColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.edit,
                          size: 16,
                          color: context.textQuaternary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Edit',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textQuaternary,
                            fontSize: 14,
                            fontVariations: const [FontVariation('wght', 500)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Icon(
                      AppIcons.delete,
                      size: 20,
                      color: context.textQuaternary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
