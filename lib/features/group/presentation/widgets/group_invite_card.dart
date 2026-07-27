import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

class GroupInviteCard extends StatelessWidget {
  final String name;
  final String target;
  final int memberCount;
  final bool isResponding;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const GroupInviteCard({
    super.key,
    required this.name,
    required this.target,
    required this.memberCount,
    required this.onAccept,
    required this.onDecline,
    this.isResponding = false,
  });

  @override
  Widget build(BuildContext context) {
    final memberLabel = memberCount == 1 ? '1 member' : '$memberCount members';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.group, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
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
                    const SizedBox(height: 2),
                    Text(
                      'Invited you · $target target · $memberLabel',
                      style: AppTypography.labelSmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: _InviteButton(
                  label: 'Decline',
                  bg: context.surfaceVariant,
                  fg: context.textSecondary,
                  onTap: isResponding ? null : onDecline,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InviteButton(
                  label: 'Accept',
                  bg: AppColors.primary,
                  fg: AppColors.white,
                  onTap: isResponding ? null : onAccept,
                  showSpinner: isResponding,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;
  final bool showSpinner;

  const _InviteButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null && !showSpinner ? 0.5 : 1,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: showSpinner
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                : Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: fg,
                      fontVariations: const [FontVariation('wght', 500)],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
