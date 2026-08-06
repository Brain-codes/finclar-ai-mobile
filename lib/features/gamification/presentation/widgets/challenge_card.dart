import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

class ChallengeCard extends StatelessWidget {
  final String name;
  final String amount;

  /// Reads as `prefix amount` — spend-based challenges track what went out
  /// rather than what was put away.
  final String amountPrefix;
  final int currentStreak;

  /// Null when the challenge has no overall target — the bar is hidden and the
  /// pill shows the weekly target instead.
  final double? progress;
  final String? targetLabel;
  final String statusLabel;
  final bool isActive;
  final VoidCallback? onTap;

  const ChallengeCard({
    super.key,
    required this.name,
    required this.amount,
    this.amountPrefix = "You've saved",
    required this.currentStreak,
    required this.progress,
    required this.targetLabel,
    required this.statusLabel,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isActive ? AppColors.primary : context.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLarge.copyWith(
                      color: context.textPrimary,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StreakPill(count: currentStreak, accent: accent),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$amountPrefix $amount',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                Text(
                  statusLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textTertiary,
                  ),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _ProgressBar(progress: progress!, accent: accent),
            ],
            if (targetLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _TargetPill(
                target: targetLabel!,
                percentage: progress == null
                    ? null
                    : '${(progress! * 100).round()}%',
                accent: accent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int count;
  final Color accent;

  const _StreakPill({required this.count, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.flame, size: 13, color: accent),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AppTypography.labelSmall.copyWith(
              color: accent,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color accent;

  const _ProgressBar({required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusXs,
      child: Container(
        height: 14,
        color: context.borderColor,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: DecoratedBox(decoration: BoxDecoration(color: accent)),
        ),
      ),
    );
  }
}

class _TargetPill extends StatelessWidget {
  final String target;
  final String? percentage;
  final Color accent;

  const _TargetPill({
    required this.target,
    required this.percentage,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              target,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: accent,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
          ),
          if (percentage != null)
            Text(
              percentage!,
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondary,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
        ],
      ),
    );
  }
}
