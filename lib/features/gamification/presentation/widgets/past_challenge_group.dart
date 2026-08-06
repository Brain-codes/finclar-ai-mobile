import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/challenge_model.dart';
import 'challenge_type_style.dart';
import 'challenge_utils.dart';

/// Collapses every finished challenge of one type into a single `×N` row.
///
/// Twenty completed weekend challenges are twenty identical cards otherwise —
/// the count is the interesting part, and the individual runs are still one tap
/// away. A lone challenge skips the grouping and renders as its own card.
class PastChallengeGroup extends StatefulWidget {
  final ChallengeType type;
  final List<ChallengeModel> challenges;
  final Widget Function(ChallengeModel) cardBuilder;

  const PastChallengeGroup({
    super.key,
    required this.type,
    required this.challenges,
    required this.cardBuilder,
  });

  @override
  State<PastChallengeGroup> createState() => _PastChallengeGroupState();
}

class _PastChallengeGroupState extends State<PastChallengeGroup> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.challenges.length == 1) {
      return widget.cardBuilder(widget.challenges.first);
    }

    final style = challengeTypeStyle(widget.type);
    final completed = widget.challenges
        .where((c) => c.status == ChallengeStatus.completed)
        .length;

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.radiusSheet,
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: style.mutedColor,
                    borderRadius: AppRadius.radiusCard,
                  ),
                  child: Icon(style.icon, size: 18, color: style.color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challengeTypeLabel(widget.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textPrimary,
                          fontSize: 14,
                          fontVariations: const [FontVariation('wght', 500)],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completed completed of ${widget.challenges.length}',
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _CountPill(
                  count: widget.challenges.length,
                  color: style.color,
                  mutedColor: style.mutedColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  _expanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                  size: 18,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          for (final c in widget.challenges) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.base),
              child: widget.cardBuilder(c),
            ),
          ],
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  final Color color;
  final Color mutedColor;

  const _CountPill({
    required this.count,
    required this.color,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: mutedColor,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        '×$count',
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontVariations: const [FontVariation('wght', 600)],
        ),
      ),
    );
  }
}
