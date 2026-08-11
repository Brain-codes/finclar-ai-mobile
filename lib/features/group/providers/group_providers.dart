import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../data/models/group_member_model.dart';
import '../data/models/group_model.dart';
import '../data/models/savings_entry_model.dart';
import '../data/repositories/group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(ref.watch(apiClientProvider));
});

/// The current user's group-savings list.
class GroupsNotifier extends AsyncNotifier<List<GroupModel>> {
  GroupRepository get _repo => ref.read(groupRepositoryProvider);

  @override
  Future<List<GroupModel>> build() => _repo.getGroups();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.getGroups);
  }

  Future<GroupModel> create({
    required String name,
    required double targetAmount,
    required DateTime endDate,
    List<String> memberIds = const [],
  }) async {
    final created = await _repo.createGroup(
      name: name,
      targetAmount: targetAmount,
      endDate: endDate,
      memberIds: memberIds,
    );
    Analytics.groupCreated();
    await refresh();
    return created;
  }

  Future<void> delete(String id) async {
    await _repo.deleteGroup(id);
    _drop(id);
  }

  Future<void> leave(String id) async {
    await _repo.leaveGroup(id);
    _drop(id);
  }

  Future<void> respondToInvite(String id, {required bool accept}) async {
    await _repo.respondToInvite(id, accept: accept);
    if (accept) {
      await refresh();
    } else {
      _drop(id);
    }
  }

  void _drop(String id) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((g) => g.id != id).toList());
  }
}

final groupsProvider =
    AsyncNotifierProvider<GroupsNotifier, List<GroupModel>>(GroupsNotifier.new);

/// A single group's detail (with members), keyed by group id.
class GroupDetailNotifier
    extends FamilyAsyncNotifier<GroupModel, String> {
  GroupRepository get _repo => ref.read(groupRepositoryProvider);

  @override
  Future<GroupModel> build(String groupId) => _repo.getGroup(groupId);

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _repo.getGroup(arg));
    ref.invalidate(groupsProvider);
  }

  Future<GroupMemberModel> addMember(String userId) async {
    final added = await _repo.addMember(arg, userId);
    await refresh();
    return added;
  }

  Future<GroupMemberModel> updateMemberTarget(
    String memberId,
    double targetAmount,
  ) async {
    final updated =
        await _repo.updateMember(arg, memberId, targetAmount: targetAmount);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        members: [
          for (final m in current.members)
            if (m.id == memberId) updated else m,
        ],
      ));
    }
    return updated;
  }

  Future<void> removeMember(
    String memberId, {
    required RedistributionChoice redistribution,
  }) async {
    await _repo.removeMember(arg, memberId, redistribution: redistribution);
    // Redistribution rewrites the remaining members' targets server-side, so
    // dropping the row locally would leave every other target stale.
    await refresh();
  }

  Future<SavingsEntryModel> recordSavings({
    required double amount,
    String? note,
    File? receipt,
  }) async {
    final entry = await _repo.recordSavings(
      arg,
      amount: amount,
      note: note,
      receipt: receipt,
    );
    await refresh();
    return entry;
  }
}

final groupDetailProvider = AsyncNotifierProvider.family<GroupDetailNotifier,
    GroupModel, String>(GroupDetailNotifier.new);

/// Savings entries for a group, keyed by group id.
final groupSavingsProvider =
    FutureProvider.family<List<SavingsEntryModel>, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).getSavings(groupId);
});
