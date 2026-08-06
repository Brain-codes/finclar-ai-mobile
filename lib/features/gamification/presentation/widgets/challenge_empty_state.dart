import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';

/// Header shown above the available-challenge cards when nothing has been
/// started yet. [onStart] is optional — with cards underneath doing the asking,
/// a button here would be a second way to say the same thing.
class ChallengeEmptyState extends StatelessWidget {
  final VoidCallback? onStart;

  const ChallengeEmptyState({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
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
              child: const Icon(
                AppIcons.flame,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Put your money where your mouth is',
              style: AppTypography.headingMedium.copyWith(
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pick a challenge below, keep the streak alive, and earn badges '
              'along the way.',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (onStart != null)
              AppButton(label: 'Start challenge', onTap: onStart, height: 52),
          ],
        ),
      ),
    );
  }
}
