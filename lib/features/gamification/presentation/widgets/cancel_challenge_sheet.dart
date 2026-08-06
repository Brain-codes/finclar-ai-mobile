import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

/// Confirms cancelling a challenge. Returns true when the user confirms.
Future<bool?> showCancelChallengeSheet(
  BuildContext context, {
  required String challengeName,
  required int currentStreak,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSheetTop),
    builder: (_) => _CancelChallengeSheet(
      challengeName: challengeName,
      currentStreak: currentStreak,
    ),
  );
}

class _CancelChallengeSheet extends StatelessWidget {
  final String challengeName;
  final int currentStreak;

  const _CancelChallengeSheet({
    required this.challengeName,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final streakWarning = currentStreak > 0
        ? ' Your $currentStreak-week streak ends here.'
        : '';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.lg + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.borderStrong),
                ),
                child: Icon(
                  AppIcons.close,
                  size: 16,
                  color: context.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF9EAEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.close, size: 28, color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Cancel challenge?',
            style: AppTypography.headingSmall.copyWith(
              color: context.textPrimary,
              fontFamily: AppFonts.display,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$challengeName will stop tracking new savings.$streakWarning '
            'Entries you already logged stay on your record.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _SheetAction(
                  label: 'Keep going',
                  background: context.surfaceVariant,
                  foreground: context.textSecondary,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SheetAction(
                  label: 'Cancel it',
                  background: AppColors.error,
                  foreground: AppColors.white,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _SheetAction({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.radiusFull,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: foreground,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
        ),
      ),
    );
  }
}
