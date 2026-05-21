import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ClaraCard extends StatelessWidget {
  final bool isEmpty;
  final String? insightText;
  final VoidCallback? onTap;

  const ClaraCard({
    super.key,
    this.isEmpty = false,
    this.insightText,
    this.onTap,
  });

  static const _defaultInsight =
      "You've spent ₦150,000 so far this month which is 25% of your income and the biggest jump came from food. Apparently your wallet has developed a taste for \"just one small treat\" that somehow keeps happening. We should have a discussion about that.";

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return _EmptyClaraCard(onTap: onTap);
    }
    return _FilledClaraCard(
      insightText: insightText ?? _defaultInsight,
      onTap: onTap,
    );
  }
}

class _FilledClaraCard extends StatelessWidget {
  final String insightText;
  final VoidCallback? onTap;

  const _FilledClaraCard({required this.insightText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.radiusSheet,
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(AppIcons.aiFill, color: AppColors.white, size: 16),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Chat with ${AppStrings.aiName}',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.white,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
                const Spacer(),
                const Icon(AppIcons.chevronRight, color: AppColors.white, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              insightText,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyClaraCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _EmptyClaraCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.ai, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Insights Yet',
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add your expenses, income, and Clara AI will start giving you smart money insights.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
