import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../data/models/challenge_model.dart';
import '../../domain/challenge_availability.dart';
import 'challenge_type_style.dart';
import 'challenge_utils.dart';

/// Picks which of the three challenges to start. Types in [running] are listed
/// but not tappable — the backend keeps one active challenge per type — and so
/// are types outside their window, which show when they come back instead.
Future<ChallengeType?> showChallengeTypeSheet(
  BuildContext context, {
  Set<ChallengeType> running = const {},
}) {
  return showAppSheet<ChallengeType>(
    context,
    title: 'Start a challenge',
    children: [_ChallengeTypeList(running: running)],
  );
}

class _ChallengeTypeList extends StatelessWidget {
  final Set<ChallengeType> running;

  const _ChallengeTypeList({required this.running});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final type in ChallengeType.values) ...[
          _TypeRow(
            availability: challengeAvailability(type, now),
            isRunning: running.contains(type),
            onTap: () => Navigator.of(context).pop(type),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  final ChallengeAvailability availability;
  final bool isRunning;
  final VoidCallback onTap;

  const _TypeRow({
    required this.availability,
    required this.isRunning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = availability.type;
    final style = challengeTypeStyle(type);
    final disabled = isRunning || !availability.isOpen;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.radiusCard,
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: style.mutedColor,
                  borderRadius: AppRadius.radiusCard,
                ),
                child: Icon(style.icon, size: 20, color: style.color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challengeTypeLabel(type),
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontSize: 14,
                        fontVariations: const [FontVariation('wght', 500)],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isRunning
                          ? 'Already running'
                          : !availability.isOpen
                          ? availability.windowLabel
                          : challengeTypeBlurb(type),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Icon(
                  isRunning
                      ? AppIcons.check
                      : !availability.isOpen
                      ? AppIcons.lock
                      : AppIcons.chevronRight,
                  size: 16,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
