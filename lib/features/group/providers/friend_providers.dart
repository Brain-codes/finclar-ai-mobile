import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client_provider.dart';
import '../data/models/friendship_model.dart';
import '../data/repositories/friend_repository.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository(ref.watch(apiClientProvider));
});

/// Search users by username/email. Returns [] for a blank query.
final userSearchProvider =
    FutureProvider.family<List<UserSearchResultModel>, String>((ref, query) {
  final q = query.trim();
  if (q.isEmpty) return Future.value(const []);
  return ref.watch(friendRepositoryProvider).searchUsers(q);
});

/// Accepted friendships for the current user.
class FriendsNotifier extends AsyncNotifier<List<FriendshipModel>> {
  FriendRepository get _repo => ref.read(friendRepositoryProvider);

  @override
  Future<List<FriendshipModel>> build() => _repo.getFriends();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.getFriends);
  }

  Future<void> remove(String friendshipId) async {
    await _repo.removeFriend(friendshipId);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((f) => f.id != friendshipId).toList());
  }
}

final friendsProvider =
    AsyncNotifierProvider<FriendsNotifier, List<FriendshipModel>>(
  FriendsNotifier.new,
);

/// Pending friend invites (sent + received).
class FriendInvitesNotifier extends AsyncNotifier<List<FriendshipModel>> {
  FriendRepository get _repo => ref.read(friendRepositoryProvider);

  @override
  Future<List<FriendshipModel>> build() => _repo.getInvites();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.getInvites);
  }

  Future<void> accept(String inviteId) async {
    await _repo.acceptInvite(inviteId);
    _drop(inviteId);
    ref.invalidate(friendsProvider);
  }

  Future<void> decline(String inviteId) async {
    await _repo.declineInvite(inviteId);
    _drop(inviteId);
  }

  Future<FriendshipModel> invite(String recipientId) async {
    final created = await _repo.sendInvite(recipientId);
    await refresh();
    return created;
  }

  void _drop(String inviteId) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((f) => f.id != inviteId).toList());
  }
}

final friendInvitesProvider =
    AsyncNotifierProvider<FriendInvitesNotifier, List<FriendshipModel>>(
  FriendInvitesNotifier.new,
);
