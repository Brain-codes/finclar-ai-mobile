import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

Future<bool?> showDeleteGroupSheet(
  BuildContext context, {
  required String groupName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _DeleteGroupSheet(groupName: groupName),
  );
}

class _DeleteGroupSheet extends StatelessWidget {
  final String groupName;
  const _DeleteGroupSheet({required this.groupName});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xl,
        AppSpacing.screenPadding,
        AppSpacing.lg + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.borderStrong),
                ),
                child:
                    Icon(AppIcons.close, size: 16, color: context.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF9EAEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.delete, size: 28, color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Delete group?',
            style: AppTypography.headingSmall.copyWith(
              color: context.textPrimary,
              fontFamily: AppFonts.display,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "$groupName and all its savings records will be permanently deleted "
            "for everyone. This can't be undone.",
            textAlign: TextAlign.center,
            style:
                AppTypography.bodyMedium.copyWith(color: context.textSecondary),
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
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondary,
                          fontVariations: const [FontVariation('wght', 500)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        'Delete',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontVariations: const [FontVariation('wght', 500)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
