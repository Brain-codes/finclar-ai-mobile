import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';

Future<void> showFriendsLimitSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _FriendsLimitSheet(),
  );
}

class _FriendsLimitSheet extends StatelessWidget {
  const _FriendsLimitSheet();

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
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.borderStrong),
                ),
                child: Icon(AppIcons.close, size: 16, color: context.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.crown, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Friend limit exceeded',
            style: AppTypography.headingSmall.copyWith(
              color: context.textPrimary,
              fontFamily: AppFonts.display,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You have exceeded the limit of 10 maximum friends. Upgrade to Clara+ to add more friends.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Upgrade to Clara +',
            onTap: () => Navigator.of(context).pop(),
            height: 48,
          ),
        ],
      ),
    );
  }
}
