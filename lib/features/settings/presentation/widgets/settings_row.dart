import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

enum SettingsRowTrailing { chevron, toggle, badge, value }

class SettingsRow extends StatefulWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final SettingsRowTrailing trailing;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final String? badgeLabel;
  final String? valueLabel;
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
    this.valueLabel,
    this.onTap,
  });

  @override
  State<SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<SettingsRow> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isTappable = widget.trailing != SettingsRowTrailing.toggle &&
        widget.onTap != null;

    return GestureDetector(
      onTap: isTappable ? widget.onTap : null,
      onTapDown: isTappable ? (_) => _setPressed(true) : null,
      onTapUp: isTappable ? (_) => _setPressed(false) : null,
      onTapCancel: isTappable ? () => _setPressed(false) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.5 : 1,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          height: 42,
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 14, color: AppColors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ),
              _Trailing(
                trailing: widget.trailing,
                toggleValue: widget.toggleValue,
                onToggleChanged: widget.onToggleChanged,
                badgeLabel: widget.badgeLabel,
                valueLabel: widget.valueLabel,
              ),
            ],
          ),
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
  final String? valueLabel;

  const _Trailing({
    required this.trailing,
    required this.toggleValue,
    this.onToggleChanged,
    this.badgeLabel,
    this.valueLabel,
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
      case SettingsRowTrailing.value:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              valueLabel ?? '',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(AppIcons.chevronRight, size: 16, color: context.textSecondary),
          ],
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
