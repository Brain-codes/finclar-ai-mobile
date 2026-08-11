import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/models/group_member_model.dart';
import '../../providers/group_providers.dart';
import 'add_friend_sheet.dart';
import 'friends_limit_sheet.dart';

/// Owner-only flow to add an existing finclar user to a group. Enforces the
/// [AppConstants.maxGroupMembers] cap, opens the user-search picker excluding
/// current members, then calls the add-member endpoint.
Future<void> addFriendsToGroup(
  BuildContext context,
  WidgetRef ref,
  String groupId,
) async {
  final detail = ref.read(groupDetailProvider(groupId)).valueOrNull;
  final active = (detail?.members ?? [])
      .where((m) =>
          m.status != GroupMemberStatus.left &&
          m.status != GroupMemberStatus.removed)
      .toList();

  if (active.length >= AppConstants.maxGroupMembers) {
    return showFriendsLimitSheet(context);
  }

  final selected = await showAddFriendSheet(
    context,
    excludeIds: active.map((m) => m.userId).toSet(),
  );
  if (selected == null || !context.mounted) return;

  try {
    await ref.read(groupDetailProvider(groupId).notifier).addMember(selected.id);
    if (context.mounted) {
      AppSnackbar.success(context, '${selected.username} invited');
    }
  } on AppException catch (e) {
    if (context.mounted) AppSnackbar.error(context, e.message);
  }
}
