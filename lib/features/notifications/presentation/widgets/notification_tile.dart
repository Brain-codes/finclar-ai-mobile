import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/notification_model.dart';
import 'notification_action_utils.dart';
import 'notification_type_utils.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  /// Fired by the type-specific CTA (e.g. "View group"). Null hides the CTA.
  final VoidCallback? onAction;

  /// Fired by the explicit "Mark as read" link, shown only while unread.
  final VoidCallback? onMarkRead;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onAction,
    this.onMarkRead,
  });

  String _relativeTime() {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = notificationColor(notification.type);
    final action =
        onAction == null ? null : notificationActionFor(notification.type);

    return GestureDetector(
      onTap: onTap,
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
                color: notificationBgColor(context, notification.type),
                borderRadius: AppRadius.radiusCard,
              ),
              child: Icon(
                notificationIcon(notification.type),
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.labelLarge.copyWith(
                            color: context.textPrimary,
                            fontVariations: const [FontVariation('wght', 600)],
                          ),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.body,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        _relativeTime(),
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      if (onMarkRead != null && !notification.isRead) ...[
                        _TileLink(
                          label: AppStrings.notificationMarkRead,
                          color: context.textSecondary,
                          onTap: onMarkRead!,
                        ),
                        if (action != null)
                          const SizedBox(width: AppSpacing.base),
                      ],
                      if (action != null)
                        _TileLink(
                          label: action.label,
                          color: AppColors.primary,
                          onTap: onAction!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileLink extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TileLink({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      // The row itself is tappable, so the link needs padding of its own to be
      // reliably hittable rather than a bare text baseline.
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontVariations: const [FontVariation('wght', 600)],
          ),
        ),
      ),
    );
  }
}
