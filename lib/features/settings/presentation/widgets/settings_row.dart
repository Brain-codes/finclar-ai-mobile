import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

enum SettingsRowTrailing { chevron, toggle, badge }

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final SettingsRowTrailing trailing;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final String? badgeLabel;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.label,
    this.trailing = SettingsRowTrailing.chevron,
    this.toggleValue = false,
    this.onToggleChanged,
    this.badgeLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: trailing == SettingsRowTrailing.toggle ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: AppColors.white),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
            _Trailing(
              trailing: trailing,
              toggleValue: toggleValue,
              onToggleChanged: onToggleChanged,
              badgeLabel: badgeLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _Trailing extends StatelessWidget {
  final SettingsRowTrailing trailing;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final String? badgeLabel;

  const _Trailing({
    required this.trailing,
    required this.toggleValue,
    this.onToggleChanged,
    this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    switch (trailing) {
      case SettingsRowTrailing.chevron:
        return Icon(AppIcons.chevronRight, size: 16, color: context.textSecondary);
      case SettingsRowTrailing.toggle:
        return Transform.scale(
          scale: 0.75,
          child: Switch(
            value: toggleValue,
            onChanged: onToggleChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.toggleActive,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: context.surfaceMuted,
          ),
        );
      case SettingsRowTrailing.badge:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.settingsRed,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                badgeLabel ?? '',
                style: AppTypography.labelXSmall.copyWith(
                  color: AppColors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(AppIcons.chevronRight, size: 16, color: context.textSecondary),
          ],
        );
    }
  }
}
