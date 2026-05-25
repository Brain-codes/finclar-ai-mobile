import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';

enum SettingsProfileLayout { vertical, horizontal }

class SettingsProfileHeader extends StatelessWidget {
  final String email;
  final String username;
  final VoidCallback? onEditTap;
  final SettingsProfileLayout layout;

  const SettingsProfileHeader({
    super.key,
    required this.email,
    required this.username,
    this.onEditTap,
    this.layout = SettingsProfileLayout.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      SettingsProfileLayout.vertical => _VerticalLayout(
          email: email,
          username: username,
          onEditTap: onEditTap,
        ),
      SettingsProfileLayout.horizontal => _HorizontalLayout(
          email: email,
          username: username,
          onEditTap: onEditTap,
        ),
    };
  }
}

// ─── Vertical (centered column) — used on the main settings screen ────────────

class _VerticalLayout extends StatelessWidget {
  final String email;
  final String username;
  final VoidCallback? onEditTap;
  const _VerticalLayout({required this.email, required this.username, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Avatar(),
        const SizedBox(height: AppSpacing.sm),
        Text(
          email,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textQuaternary,
            fontSize: 14,
            fontVariations: const [FontVariation('wght', 500)],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: onEditTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                username,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(AppIcons.edit, size: 12, color: context.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Horizontal (row) — used on the account deletion screen ──────────────────

class _HorizontalLayout extends StatelessWidget {
  final String email;
  final String username;
  final VoidCallback? onEditTap;
  const _HorizontalLayout({required this.email, required this.username, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                email,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textQuaternary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              if (onEditTap != null)
                GestureDetector(
                  onTap: onEditTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        username,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(AppIcons.edit, size: 12, color: context.textSecondary),
                    ],
                  ),
                )
              else
                Text(
                  username,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared avatar ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFC5ECFD),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2),
      ),
      child: const Icon(AppIcons.userFill, size: 28, color: AppColors.white),
    );
  }
}
