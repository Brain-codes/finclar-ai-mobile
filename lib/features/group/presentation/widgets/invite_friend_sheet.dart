import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/invite_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../auth/providers/user_profile_provider.dart';

/// Shares the current user's invite link. Opening the app from that link takes
/// the recipient straight to a pre-filled friend request.
Future<void> showInviteFriendSheet(BuildContext context, WidgetRef ref) async {
  final username = ref.read(userProfileProvider).valueOrNull?.username;
  if (username == null || username.isEmpty) {
    AppSnackbar.error(context, 'Could not build your invite link. Try again.');
    return;
  }
  return showAppSheet<void>(
    context,
    title: 'Invite a friend',
    children: [_InviteContent(username: username)],
  );
}

class _InviteContent extends StatelessWidget {
  final String username;
  const _InviteContent({required this.username});

  Future<void> _channel(
    BuildContext context,
    Future<bool> Function(String) action,
  ) async {
    final launched = await action(username);
    if (launched || !context.mounted) return;
    // The app isn't installed — hand off to the OS share sheet rather than
    // leaving the tap doing nothing.
    await InviteService.shareSheet(username);
  }

  @override
  Widget build(BuildContext context) {
    final link = InviteService.linkFor(username);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send this link. If they already have finclar it opens straight to '
          'your friend request — if not, it takes them to install it first.',
          style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.base),
        _LinkRow(link: link, username: username),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ShareChannel(
              icon: AppIcons.whatsapp,
              label: 'WhatsApp',
              color: AppColors.success,
              onTap: () => _channel(context, InviteService.shareToWhatsApp),
            ),
            _ShareChannel(
              icon: AppIcons.message,
              label: 'SMS',
              color: AppColors.categoryTransport,
              onTap: () => _channel(context, InviteService.shareToSms),
            ),
            _ShareChannel(
              icon: AppIcons.email,
              label: 'Email',
              color: AppColors.categoryPurple,
              onTap: () => _channel(context, InviteService.shareToEmail),
            ),
            _ShareChannel(
              icon: AppIcons.share,
              label: 'More',
              color: AppColors.primary,
              onTap: () => InviteService.shareSheet(username),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String link;
  final String username;

  const _LinkRow({required this.link, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.radiusCard,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Icon(AppIcons.link, size: 18, color: context.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              link,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  AppTypography.bodySmall.copyWith(color: context.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () async {
              await InviteService.copyLink(username);
              if (context.mounted) {
                AppSnackbar.success(context, 'Invite link copied');
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.copy, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Copy',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareChannel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareChannel({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style:
                AppTypography.labelSmall.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
