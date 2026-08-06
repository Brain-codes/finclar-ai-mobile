import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_profile_avatar.dart';
import '../../data/models/group_member_model.dart';

enum FriendStatus { complete, accepted, pending }

class GroupFriendTile extends StatelessWidget {
  final String name;

  /// Null until the backend returns `profile_icon` on group members — the tile
  /// falls back to a face generated from [name].
  final String? profileIcon;

  /// Total amount this friend is expected to contribute.
  final double targetAmount;

  /// Amount this friend has contributed so far.
  final double contributedAmount;

  /// Only [FriendStatus.accepted] carries external meaning — complete/pending
  /// are derived from [contributedAmount] vs [targetAmount].
  final FriendStatus status;

  /// Currency symbol from the app config — never hardcode one here.
  final String symbol;

  /// Whether this member has accepted their group invite yet. Non-accepted
  /// members show an invite badge instead of contribution figures.
  final GroupInviteStatus inviteStatus;

  final bool showEdit;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteTapped;

  const GroupFriendTile({
    super.key,
    required this.name,
    this.profileIcon,
    required this.targetAmount,
    required this.contributedAmount,
    required this.symbol,
    this.inviteStatus = GroupInviteStatus.accepted,
    this.status = FriendStatus.pending,
    this.showEdit = false,
    this.onTap,
    this.onDeleteTapped,
  });

  static final _fmt = NumberFormat('#,##0.##');

  double get _amountLeft =>
      (targetAmount - contributedAmount).clamp(0, double.infinity);

  // Complete when they've hit or exceeded their target.
  bool get _isComplete => contributedAmount >= targetAmount;

  bool get _isAccepted => status == FriendStatus.accepted;

  // Green treatment for complete or externally-accepted friends.
  bool get _isGreen => _isComplete || _isAccepted;

  String get _badgeLabel {
    if (_isComplete) return 'Complete';
    if (_isAccepted) return 'Accepted';
    return 'Pending';
  }

  String get _formattedTarget => '$symbol${_fmt.format(targetAmount)}';
  String get _formattedContributed => '$symbol${_fmt.format(contributedAmount)}';
  String get _formattedLeft => '$symbol${_fmt.format(_amountLeft)}';

  @override
  Widget build(BuildContext context) {
    final amountColor = _isGreen ? AppColors.success : context.textTertiary;
    final badgeBg = _isGreen ? AppColors.successLight : context.surfaceMuted;
    final badgeText = _isGreen ? AppColors.success : context.textSecondary;

    return GestureDetector(
      onTap: onDeleteTapped ?? onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          AppProfileAvatar(
            profileIcon: profileIcon,
            name: name,
            size: 40,
            seedWhenEmpty: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textQuaternary,
                    fontSize: 14,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
                const SizedBox(height: 2),
                _buildSecondaryInfo(context, badgeBg, badgeText),
              ],
            ),
          ),
          _buildTrailing(context, amountColor),
        ],
      ),
    );
  }

  bool get _inviteAccepted => inviteStatus == GroupInviteStatus.accepted;

  Widget _buildSecondaryInfo(BuildContext context, Color badgeBg, Color badgeText) {
    // Invite not yet accepted: the contribution figures don't apply yet.
    if (!_inviteAccepted) {
      final declined = inviteStatus == GroupInviteStatus.declined;
      return _StatusBadge(
        label: declined ? 'Declined' : 'Awaiting confirmation',
        bg: declined ? AppColors.errorLight : context.surfaceMuted,
        fg: declined ? AppColors.error : AppColors.warning,
      );
    }

    // Delete mode: always show a status badge
    if (onDeleteTapped != null) {
      return _StatusBadge(label: _badgeLabel, bg: badgeBg, fg: badgeText);
    }

    // Normal mode: complete overrides contributed text
    if (_isComplete || _isAccepted) {
      return _StatusBadge(label: _badgeLabel, bg: badgeBg, fg: badgeText);
    }

    // Pending: show how much they've contributed so far
    return Text(
      '$_formattedContributed contributed',
      style: AppTypography.labelSmall.copyWith(
        color: context.textPrimary,
        fontSize: 12,
        fontVariations: const [FontVariation('wght', 400)],
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, Color amountColor) {
    // No contribution figure for a member who hasn't accepted yet — but the
    // owner can still remove them (delete icon retained below).
    if (!_inviteAccepted && onDeleteTapped == null) {
      return const SizedBox.shrink();
    }

    if (onDeleteTapped != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onDeleteTapped,
            child: Icon(AppIcons.delete, size: 16, color: context.textSecondary),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isComplete ? _formattedTarget : _formattedLeft,
          style: AppTypography.labelSmall.copyWith(
            color: amountColor,
            fontVariations: const [FontVariation('wght', 600)],
          ),
        ),
        if (showEdit) ...[
          const SizedBox(width: 4),
          Icon(AppIcons.edit, size: 14, color: context.textTertiary),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _StatusBadge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontVariations: const [FontVariation('wght', 500)],
        ),
      ),
    );
  }
}
