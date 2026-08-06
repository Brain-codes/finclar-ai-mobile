import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../data/models/challenge_model.dart';
import 'badge_widget.dart';

final _dateFormat = DateFormat('d MMM yyyy');

/// [earnings] is every time this badge was earned in the month being viewed.
/// Empty means the badge is still locked.
Future<void> showBadgeDetailSheet(
  BuildContext context, {
  required BadgeModel badge,
  List<UserBadgeModel> earnings = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSheetTop),
    builder: (_) => _BadgeDetailSheet(badge: badge, earnings: earnings),
  );
}

class _BadgeDetailSheet extends StatelessWidget {
  final BadgeModel badge;
  final List<UserBadgeModel> earnings;

  const _BadgeDetailSheet({required this.badge, required this.earnings});

  @override
  Widget build(BuildContext context) {
    final earned = earnings.isNotEmpty;
    final dates = earnings.map((e) => e.earnedAt).whereType<DateTime>().toList()
      ..sort((a, b) => b.compareTo(a));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xl,
        AppSpacing.screenPadding,
        AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BadgeWidget(
            badgeKey: badge.key,
            iconName: badge.iconName,
            category: badge.category,
            count: earnings.length,
            earned: earned,
            size: 180,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: AppTypography.headingSmall.copyWith(
              color: context.textPrimary,
              fontFamily: AppFonts.display,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          if (!earned) ...[
            const SizedBox(height: AppSpacing.base),
            Text(
              'Not earned yet',
              style: AppTypography.labelSmall.copyWith(
                color: context.textTertiary,
              ),
            ),
          ],
          if (dates.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                borderRadius: AppRadius.radiusCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dates.length == 1
                        ? 'Earned once this month'
                        : 'Earned ${dates.length} times this month',
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final d in dates)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        _dateFormat.format(d),
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
