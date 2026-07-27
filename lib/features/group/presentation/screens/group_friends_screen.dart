import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config_notifier.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../features/auth/providers/user_profile_provider.dart';
import '../../../../shared/icons/app_icons.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/group_member_model.dart';
import '../../data/models/group_model.dart';
import '../../providers/group_providers.dart';
import '../widgets/delete_friend_sheet.dart';
import '../widgets/group_add_friends_action.dart';
import '../widgets/group_friend_tile.dart';

class GroupFriendsScreen extends ConsumerWidget {
  final GroupModel group;
  const GroupFriendsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(groupDetailProvider(group.id));
    final currentUserId = ref.watch(userProfileProvider).valueOrNull?.id;
    final symbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              onBack: () => context.pop(),
              title: 'Friends',
              centerTitle: false,
              actions: [
                if (group.ownerId == currentUserId)
                  AppTopBarAction(
                    icon: AppIcons.addUser,
                    onTap: () => addFriendsToGroup(context, ref, group.id),
                  ),
              ],
            ),
            Expanded(
              child: detailState.when(
                loading: () => const _FriendsSkeleton(),
                error: (_, _) => Center(
                  child: Text(
                    "Couldn't load members",
                    style: AppTypography.bodyMedium
                        .copyWith(color: context.textSecondary),
                  ),
                ),
                data: (detail) {
                  final isOwner = detail.ownerId == currentUserId;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.base,
                      AppSpacing.screenPadding,
                      AppSpacing.screenPadding,
                    ),
                    child: Container(
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
                          const SizedBox(height: AppSpacing.base),
          if (_visibleMembers(detail, isOwner).isEmpty)
                            Text(
                              'No members yet',
                              style: AppTypography.bodySmall
                                  .copyWith(color: context.textSecondary),
                            )
                          else
                            ...() {
                              final members = _visibleMembers(detail, isOwner);
                              return List.generate(members.length, (i) {
                                final m = members[i];
                                final isSelf = m.userId == currentUserId;
                                // Owner can remove anyone but themselves.
                                final canRemove = isOwner && !isSelf;
                                // Editing the target only applies once accepted
                                // and while they still owe.
                                final canEdit = canRemove &&
                                    m.hasAccepted &&
                                    !m.hasPaidInFull;
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: i == 0 ? 0 : AppSpacing.base),
                                  child: GroupFriendTile(
                                    name: m.username,
                                    targetAmount:
                                        m.targetAmount ?? detail.targetAmount,
                                    contributedAmount: m.contributedAmount,
                                    symbol: symbol,
                                    inviteStatus: m.inviteStatus,
                                    status: m.isComplete
                                        ? FriendStatus.complete
                                        : FriendStatus.pending,
                                    showEdit: canEdit,
                                    onDeleteTapped: canRemove
                                        ? () => _removeMember(context, ref, m)
                                        : null,
                                  ),
                                );
                              });
                            }(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Accepted members are visible to everyone. Awaiting-confirmation (pending)
  // members are only shown to the owner, who can revoke them. Departed members
  // are never shown.
  List<GroupMemberModel> _visibleMembers(GroupModel detail, bool isOwner) =>
      detail.members
          .where((m) =>
              m.status != GroupMemberStatus.left &&
              m.status != GroupMemberStatus.removed &&
              (isOwner || m.hasAccepted))
          .toList();

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

class _FriendsSkeleton extends StatelessWidget {
  const _FriendsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusSheet,
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          children: List.generate(
            8,
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
    );
  }
}
