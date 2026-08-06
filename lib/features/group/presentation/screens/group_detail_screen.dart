import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../features/auth/providers/user_profile_provider.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/group_member_model.dart';
import '../../data/models/group_model.dart';
import '../../providers/group_providers.dart';
import '../widgets/delete_friend_sheet.dart';
import '../widgets/delete_group_sheet.dart';
import '../widgets/edit_friend_sheet.dart';
import '../widgets/group_add_friends_action.dart';
import '../widgets/group_friend_tile.dart';
import '../widgets/leave_group_sheet.dart';
import '../widgets/record_savings_sheet.dart';

class GroupDetailScreen extends ConsumerWidget {
  final GroupModel group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final detailState = ref.watch(groupDetailProvider(group.id));
    final currentUserId = ref.watch(userProfileProvider).valueOrNull?.id;
    final detail = detailState.valueOrNull;
    // Owner comes from the detail payload when loaded, else the passed-in model.
    final isOwner = (detail?.ownerId ?? group.ownerId) == currentUserId;

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
              // Owner: chat + delete. Participant: chat + exit.
              actions: [
                AppTopBarAction(
                  icon: AppIcons.message,
                  onTap: () => context.push(RouteNames.groupChat, extra: group),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (isOwner)
                  AppTopBarAction(
                    icon: AppIcons.delete,
                    onTap: () => _onDelete(context, ref),
                  )
                else
                  AppTopBarAction(
                    icon: AppIcons.logout,
                    onTap: () => _onLeave(context, ref),
                  ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(groupDetailProvider(group.id).notifier).refresh(),
                child: detailState.when(
                  loading: () => const _DetailSkeleton(),
                  error: (_, _) => _DetailError(
                    onRetry: () => ref
                        .read(groupDetailProvider(group.id).notifier)
                        .refresh(),
                  ),
                  data: (detail) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.base,
                      AppSpacing.screenPadding,
                      AppSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _StatsSection(group: detail, symbol: symbol),
                        const SizedBox(height: AppSpacing.base),
                        _FriendsCard(
                          group: detail,
                          symbol: symbol,
                          isOwner: detail.ownerId == currentUserId,
                          currentUserId: currentUserId,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _BottomBar(group: group, isOwner: isOwner),
          ],
        ),
      ),
    );
  }

  Future<void> _onLeave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showLeaveGroupSheet(context, groupName: group.name);
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(groupsProvider.notifier).leave(group.id);
      if (context.mounted) {
        AppSnackbar.success(context, 'You left the group');
        context.pop();
      }
    } on AppException catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.message);
    }
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDeleteGroupSheet(context, groupName: group.name);
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(groupsProvider.notifier).delete(group.id);
      if (context.mounted) {
        AppSnackbar.success(context, 'Group deleted');
        context.pop();
      }
    } on AppException catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.message);
    }
  }
}

class _StatsSection extends StatelessWidget {
  final GroupModel group;
  final String symbol;
  const _StatsSection({required this.group, required this.symbol});

  String _fmt(double v) =>
      formatCurrency(v, symbol, abbreviate: false, withCommas: true);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Text(
              'Raised',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _fmt(group.totalRaised),
              textAlign: TextAlign.center,
              style: AppTypography.amountMedium.copyWith(
                color: context.textPrimary,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: 300,
          child: Row(
            children: [
              _StatChip(
                label: 'Target',
                value: _fmt(group.targetAmount),
                labelColor: AppColors.warning,
                icon: AppIcons.target,
              ),
              const SizedBox(width: 36),
              _StatChip(
                label: 'Balance',
                value: _fmt(group.balance),
                labelColor: AppColors.primary,
                icon: AppIcons.walletLine,
              ),
              const SizedBox(width: 36),
              _StatChip(
                label: 'Days left',
                value: group.daysLeftLabel,
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

class _FriendsCard extends ConsumerWidget {
  final GroupModel group;
  final String symbol;
  final bool isOwner;
  final String? currentUserId;

  const _FriendsCard({
    required this.group,
    required this.symbol,
    required this.isOwner,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Everyone sees accepted members. The owner additionally sees pending
    // (awaiting-confirmation) members so they can track and revoke them.
    // Departed members are never shown.
    final members = group.members
        .where((m) =>
            m.status != GroupMemberStatus.left &&
            m.status != GroupMemberStatus.removed &&
            (isOwner || m.hasAccepted))
        .toList();
    final displayMembers = members.take(5).toList();

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
                  '${members.length} ${members.length == 1 ? 'friend' : 'friends'}',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
              child: Text(
                'No members yet',
                style: AppTypography.bodySmall
                    .copyWith(color: context.textSecondary),
              ),
            )
          else
            ...List.generate(displayMembers.length, (i) {
              final m = displayMembers[i];
              final target = m.targetAmount ?? group.targetAmount;
              // Owner-only, and nothing left to edit once their share is paid.
              final canManage =
                  isOwner && m.userId != currentUserId && !m.hasPaidInFull;
              return Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.lg),
                child: GroupFriendTile(
                  name: m.username,
                  profileIcon: m.profileIcon,
                  targetAmount: target,
                  contributedAmount: m.contributedAmount,
                  symbol: symbol,
                  inviteStatus: m.inviteStatus,
                  status: m.isComplete
                      ? FriendStatus.complete
                      : FriendStatus.pending,
                  showEdit: canManage,
                  onTap: canManage
                      ? () => _editMember(context, ref, m, target)
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _editMember(
    BuildContext context,
    WidgetRef ref,
    GroupMemberModel member,
    double target,
  ) async {
    final newAmount = await showEditFriendSheet(
      context,
      name: member.username,
      contributed: formatCurrency(member.contributedAmount, symbol,
          abbreviate: false, withCommas: true),
      target:
          formatCurrency(target, symbol, abbreviate: false, withCommas: true),
      symbol: symbol,
      onRemove: () => _removeMember(context, ref, member),
    );
    if (newAmount == null) return;
    try {
      await ref
          .read(groupDetailProvider(group.id).notifier)
          .updateMemberTarget(member.id, newAmount);
      if (context.mounted) AppSnackbar.success(context, 'Target updated');
    } on AppException catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.message);
    }
  }

  Future<void> _removeMember(
    BuildContext context,
    WidgetRef ref,
    GroupMemberModel member,
  ) async {
    final confirmed = await showDeleteFriendSheet(context);
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(groupDetailProvider(group.id).notifier)
          .removeMember(member.id);
      if (context.mounted) AppSnackbar.success(context, 'Member removed');
    } on AppException catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.message);
    }
  }
}

class _BottomBar extends ConsumerWidget {
  final GroupModel group;
  final bool isOwner;
  const _BottomBar({required this.group, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            width: isOwner ? 160 : 250,
            child: AppButton(
              label: 'Add savings',
              onTap: () => showRecordSavingsSheet(context, group.id),
              height: 48,
            ),
          ),
          // Participants can't invite — they can't share the group link.
          if (isOwner) ...[
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 90,
              child: AppButton(
                label: 'Invite',
                variant: AppButtonVariant.outline,
                onTap: () => _onInvite(context, ref),
                height: 48,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onInvite(BuildContext context, WidgetRef ref) =>
      addFriendsToGroup(context, ref, group.id);
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        const SizedBox(height: AppSpacing.base),
        const Center(child: AppSkeleton.text(width: 60)),
        const SizedBox(height: 8),
        const Center(child: AppSkeleton(width: 160, height: 28)),
        const SizedBox(height: AppSpacing.xl),
        const Center(child: AppSkeleton(width: 280, height: 40)),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: AppRadius.radiusSheet,
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    AppSkeleton.circle(size: 40),
                    SizedBox(width: 12),
                    Expanded(child: AppSkeleton.text(width: 120)),
                    AppSkeleton.text(width: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailError extends StatelessWidget {
  final VoidCallback onRetry;
  const _DetailError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        const SizedBox(height: 120),
        Icon(AppIcons.group, size: 40, color: context.textSecondary),
        const SizedBox(height: AppSpacing.base),
        Text(
          "Couldn't load this group",
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textQuaternary,
            fontSize: 14,
            fontVariations: const [FontVariation('wght', 500)],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Center(
          child: GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: Text(
                'Retry',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 14,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
