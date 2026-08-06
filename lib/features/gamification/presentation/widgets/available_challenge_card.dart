import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../domain/challenge_availability.dart';
import 'challenge_type_style.dart';
import 'challenge_utils.dart';

/// A challenge the user could start right now, offered as a card rather than
/// buried behind the `+`. Cards outside their window stay visible but inert so
/// the cadence is legible — you can see the weekend one exists before Friday.
class AvailableChallengeCard extends StatelessWidget {
  final ChallengeAvailability availability;
  final VoidCallback onTap;

  const AvailableChallengeCard({
    super.key,
    required this.availability,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = availability.type;
    final style = challengeTypeStyle(type);
    final isOpen = availability.isOpen;

    return Opacity(
      opacity: isOpen ? 1 : 0.6,
      child: GestureDetector(
        onTap: isOpen ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: style.mutedColor,
            borderRadius: AppRadius.radiusSheet,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: AppRadius.radiusCard,
                    ),
                    child: Icon(style.icon, size: 22, color: style.color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      challengeTypeLabel(type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLarge.copyWith(
                        color: context.textPrimary,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _WindowPill(
                    label: availability.windowLabel,
                    color: style.color,
                    locked: !isOpen,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                challengeTypeBlurb(type),
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (isOpen) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Text(
                      'Start challenge',
                      style: AppTypography.labelSmall.copyWith(
                        color: style.color,
                        fontVariations: const [FontVariation('wght', 600)],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(AppIcons.chevronRight, size: 14, color: style.color),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool locked;

  const _WindowPill({
    required this.label,
    required this.color,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            locked ? AppIcons.lock : AppIcons.calendar,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontSize: 11,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
        ],
      ),
    );
  }
}
