import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_profile_avatar.dart';

enum SettingsProfileLayout { vertical, horizontal }

class SettingsProfileHeader extends StatelessWidget {
  final String email;
  final String username;
  final String? profileIcon;
  final VoidCallback? onEditTap;
  final VoidCallback? onAvatarTap;
  final SettingsProfileLayout layout;

  const SettingsProfileHeader({
    super.key,
    required this.email,
    required this.username,
    this.profileIcon,
    this.onEditTap,
    this.onAvatarTap,
    this.layout = SettingsProfileLayout.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      SettingsProfileLayout.vertical => _VerticalLayout(
          email: email,
          username: username,
          profileIcon: profileIcon,
          onEditTap: onEditTap,
          onAvatarTap: onAvatarTap,
        ),
      SettingsProfileLayout.horizontal => _HorizontalLayout(
          email: email,
          username: username,
          profileIcon: profileIcon,
          onEditTap: onEditTap,
          onAvatarTap: onAvatarTap,
        ),
    };
  }
}

// ─── Vertical (centered column) — used on the main settings screen ────────────

class _VerticalLayout extends StatelessWidget {
  final String email;
  final String username;
  final String? profileIcon;
  final VoidCallback? onEditTap;
  final VoidCallback? onAvatarTap;
  const _VerticalLayout({
    required this.email,
    required this.username,
    this.profileIcon,
    this.onEditTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Avatar(
          profileIcon: profileIcon,
          name: username,
          onTap: onAvatarTap,
        ),
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
  final String? profileIcon;
  final VoidCallback? onEditTap;
  final VoidCallback? onAvatarTap;
  const _HorizontalLayout({
    required this.email,
    required this.username,
    this.profileIcon,
    this.onEditTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(
          profileIcon: profileIcon,
          name: username,
          onTap: onAvatarTap,
        ),
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
  final String? profileIcon;
  final String? name;
  final VoidCallback? onTap;

  const _Avatar({this.profileIcon, this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = profileIcon != null && profileIcon!.trim().isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (hasAvatar)
              AppProfileAvatar(
                profileIcon: profileIcon,
                name: name,
                size: 56,
                border: Border.all(color: AppColors.white, width: 2),
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFC5ECFD),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(
                  AppIcons.userFill,
                  size: 28,
                  color: AppColors.white,
                ),
              ),
            if (onTap != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    AppIcons.edit,
                    size: 10,
                    color: AppColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
