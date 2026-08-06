import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_profile_avatar.dart';
import '../../data/models/friendship_model.dart';

/// An incoming friend request with accept/decline. Both actions disable while
/// one is running so a double-tap can't fire two calls.
class FriendRequestTile extends StatefulWidget {
  final FriendshipModel invite;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;

  const FriendRequestTile({
    super.key,
    required this.invite,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<FriendRequestTile> createState() => _FriendRequestTileState();
}

class _FriendRequestTileState extends State<FriendRequestTile> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusCard,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          AppProfileAvatar(
            profileIcon: widget.invite.friendProfileIcon,
            name: widget.invite.friendUsername,
            size: 40,
            seedWhenEmpty: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.invite.friendUsername,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textPrimary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                Text(
                  'wants to be friends',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall
                      .copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _Pill(
            label: 'Decline',
            enabled: !_busy,
            onTap: () => _run(widget.onDecline),
          ),
          const SizedBox(width: AppSpacing.xs),
          _Pill(
            label: 'Accept',
            enabled: !_busy,
            filled: true,
            onTap: () => _run(widget.onAccept),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool filled;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColors.primary : context.surfaceVariant;
    final fg = filled ? AppColors.white : context.textSecondary;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: filled ? AppColors.primary : context.borderColor,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}
