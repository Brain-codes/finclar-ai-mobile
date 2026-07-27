import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class GroupCard extends StatelessWidget {
  final String name;
  final String amountSaved;
  final String daysLeft;
  final String target;
  final double progress; // 0.0 to 1.0
  final Color themeColor;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.name,
    required this.amountSaved,
    required this.daysLeft,
    required this.target,
    required this.progress,
    required this.themeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = '${(progress * 100).round()}%';

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
            Text(
              name,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textPrimary,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "You've saved $amountSaved",
                  style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                ),
                Text(
                  daysLeft,
                  style: AppTypography.labelSmall.copyWith(color: context.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _SegmentedProgressBar(
              progress: progress,
              themeColor: themeColor,
            ),
            const SizedBox(height: AppSpacing.sm),
            _TargetPill(
              target: target,
              percentage: pct,
              themeColor: themeColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedProgressBar extends StatelessWidget {
  final double progress;
  final Color themeColor;

  const _SegmentedProgressBar({required this.progress, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    final emptyColor = context.borderColor;
    const segments = 4;
    return Row(
      children: List.generate(segments, (i) {
        final fill = (progress * segments - i).clamp(0.0, 1.0);
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < segments - 1 ? 4 : 0),
            height: 14,
            decoration: BoxDecoration(
              color: emptyColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fill,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TargetPill extends StatelessWidget {
  final String target;
  final String percentage;
  final Color themeColor;

  const _TargetPill({
    required this.target,
    required this.percentage,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Target:',
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondary,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                target,
                style: AppTypography.labelSmall.copyWith(
                  color: themeColor,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ],
          ),
          Text(
            percentage,
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
