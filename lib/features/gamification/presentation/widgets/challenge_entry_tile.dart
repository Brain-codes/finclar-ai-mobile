import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../data/models/challenge_model.dart';

class ChallengeEntryTile extends StatelessWidget {
  final ChallengeEntryModel entry;
  final String amountLabel;

  const ChallengeEntryTile({
    super.key,
    required this.entry,
    required this.amountLabel,
  });

  bool get _isBacked =>
      entry.verificationLevel == EntryVerificationLevel.evidenceBacked;

  @override
  Widget build(BuildContext context) {
    final date = entry.recordedAt;
    final subtitle = entry.note?.trim().isNotEmpty == true
        ? entry.note!.trim()
        : _isBacked
        ? 'Evidence backed'
        : 'Self reported';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusCard,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isBacked ? context.successBg : context.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isBacked ? AppIcons.check : AppIcons.wallet,
              size: 18,
              color: _isBacked ? context.successOn : context.textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amountLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (date != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              DateFormat('d MMM').format(date),
              style: AppTypography.labelSmall.copyWith(
                color: context.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
