import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';

class GroupEmptyState extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const GroupEmptyState({super.key, required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.primaryMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.group, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Save with your friends',
              style: AppTypography.headingMedium.copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Track savings, see your progress grow, and stay on track together until you reach your goal.',
              style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Create group',
              onTap: onCreateGroup,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}
