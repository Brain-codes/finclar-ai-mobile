import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/group_item.dart';
import '../widgets/delete_friend_sheet.dart';
import '../widgets/edit_friend_sheet.dart';
import '../widgets/group_friend_tile.dart';
import '../widgets/leave_group_sheet.dart';
import '../widgets/share_group_sheet.dart';

class _Friend {
  final String name;
  final double contributedAmount;
  final double targetAmount;

  const _Friend({
    required this.name,
    required this.contributedAmount,
    required this.targetAmount,
  });
}

final _mockFriends = [
  const _Friend(
    name: 'James Fanny',
    contributedAmount: 500000,
    targetAmount: 500000,
  ),
  const _Friend(
    name: 'Martin Harvey',
    contributedAmount: 500000,
    targetAmount: 500000,
  ),
  const _Friend(
    name: 'Sarah Collins',
    contributedAmount: 500000,
    targetAmount: 500000,
  ),
  const _Friend(
    name: 'Janet Martin',
    contributedAmount: 200000,
    targetAmount: 500000,
  ),
  const _Friend(
    name: 'James Boshce',
    contributedAmount: 200000,
    targetAmount: 500000,
  ),
  const _Friend(
    name: 'Charles Lennox',
    contributedAmount: 0,
    targetAmount: 500000,
  ),
];

class GroupDetailScreen extends StatelessWidget {
  final GroupItem group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              onBack: () => context.pop(),
              title: group.name,
              centerTitle: false,
              actions: [
                AppTopBarAction(
                  icon: AppIcons.logout,
                  onTap: () async {
                    final confirmed = await showLeaveGroupSheet(
                      context,
                      groupName: group.name,
                    );
                    if (confirmed == true && context.mounted) {
                      AppSnackbar.success(context, 'You left the group');
                      context.pop();
                    }
                  },
                ),

                const SizedBox(width: AppSpacing.sm),
                AppTopBarAction(
                  icon: AppIcons.delete,
                  onTap: () => showShareGroupSheet(
                    context,
                    groupName: group.name,
                    shareLink: 'finclar.app/g/123478',
                    memberNames: _mockFriends
                        .map((f) => f.name)
                        .take(3)
                        .toList(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppTopBarAction(
                  icon: AppIcons.message,
                  onTap: () => context.push(
                    RouteNames.groupChat,
                    extra: group,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.base,
                  AppSpacing.screenPadding,
                  AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _StatsSection(group: group),
                    const SizedBox(height: AppSpacing.base),
                    _FriendsCard(group: group),
                  ],
                ),
              ),
            ),
            _BottomBar(group: group),
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final GroupItem group;
  const _StatsSection({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Raised block — centered
        Column(
          children: [
            Stack(
              children: [
                Text(
                  'Raised',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 8
                      ..color = context.surfaceColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.60),
                        blurRadius: 22,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Raised',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Stack(
              children: [
                Text(
                  group.amountSaved,
                  textAlign: TextAlign.center,
                  style: AppTypography.headingMedium.copyWith(
                    fontVariations: const [FontVariation('wght', 600)],
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 8
                      ..color = context.surfaceColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.60),
                        blurRadius: 22,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Text(
                  group.amountSaved,
                  textAlign: TextAlign.center,
                  style: AppTypography.amountMedium.copyWith(
                    color: context.textPrimary,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        // Stats row — 300px wide, centered, 3 × 76px chips with 36px gaps
        SizedBox(
          width: 300,
          child: Row(
            children: [
              _StatChip(
                label: 'Target',
                value: group.target,
                labelColor: AppColors.warning,
                icon: AppIcons.target,
              ),
              const SizedBox(width: 36),
              _StatChip(
                label: 'Balance',
                value: '₦350,000',
                labelColor: AppColors.primary,
                icon: AppIcons.walletLine,
              ),
              const SizedBox(width: 36),
              _StatChip(
                label: 'Days left',
                value: group.daysLeft,
                labelColor: AppColors.categoryShopping,
                icon: AppIcons.flag,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Icon(icon, size: 14, color: labelColor),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: labelColor,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: context.textTertiary,
              fontVariations: const [FontVariation('wght', 500)],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsCard extends StatelessWidget {
  final GroupItem group;
  const _FriendsCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final displayFriends = _mockFriends.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.radiusSheet,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Friends',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textQuaternary,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
              GestureDetector(
                onTap: () =>
                    context.push(RouteNames.groupFriends, extra: group),
                child: Text(
                  '${_mockFriends.length} friends',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          ...List.generate(displayFriends.length, (i) {
            final f = displayFriends[i];
            final isPending = f.contributedAmount < f.targetAmount;
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.lg),
              child: GroupFriendTile(
                name: f.name,
                targetAmount: f.targetAmount,
                contributedAmount: f.contributedAmount,
                showEdit: isPending,
                onTap: isPending
                    ? () => showEditFriendSheet(
                        context,
                        name: f.name,
                        contributed:
                            '₦${f.contributedAmount.toStringAsFixed(0)}',
                        target: '₦${f.targetAmount.toStringAsFixed(0)}',
                        onRemove: () => showDeleteFriendSheet(context),
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final GroupItem group;
  const _BottomBar({required this.group});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.base,
        AppSpacing.screenPadding,
        AppSpacing.base + bottomPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 145,
            child: AppButton(label: 'Add expense', onTap: () {}, height: 48),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 90,
            child: AppButton(
              label: 'Invite',
              variant: AppButtonVariant.outline,
              onTap: () => showShareGroupSheet(
                context,
                groupName: group.name,
                shareLink: 'finclar.app/g/123478',
                memberNames: _mockFriends.map((f) => f.name).take(3).toList(),
              ),
              height: 48,
            ),
          ),
        ],
      ),
    );
  }
}
