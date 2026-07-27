import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/logger_service.dart';
import '../models/friendship_model.dart';

class FriendRepository {
  final ApiClient _api;

  FriendRepository(this._api);

  Future<List<UserSearchResultModel>> searchUsers(String query) async {
    Log.api('GET', ApiEndpoints.friendsSearch, body: {'q': query});
    return _api.getAllPaginated<UserSearchResultModel>(
      ApiEndpoints.friendsSearch,
      queryParams: {'q': query},
      fromItem: UserSearchResultModel.fromJson,
    );
  }

  Future<List<FriendshipModel>> getFriends() async {
    Log.api('GET', ApiEndpoints.friends);
    return _api.getAllPaginated<FriendshipModel>(
      ApiEndpoints.friends,
      fromItem: FriendshipModel.fromJson,
    );
  }

  Future<List<FriendshipModel>> getInvites() async {
    Log.api('GET', ApiEndpoints.friendInvites);
    return _api.getAllPaginated<FriendshipModel>(
      ApiEndpoints.friendInvites,
      fromItem: FriendshipModel.fromJson,
    );
  }

  Future<FriendshipModel> sendInvite(String recipientId) async {
    Log.api('POST', ApiEndpoints.friendInvite, body: {'recipient_id': recipientId});
    final response = await _api.post<FriendshipModel>(
      ApiEndpoints.friendInvite,
      body: {'recipient_id': recipientId},
      fromData: (data) =>
          FriendshipModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<FriendshipModel> acceptInvite(String inviteId) async {
    Log.api('PUT', ApiEndpoints.friendInviteAccept(inviteId));
    final response = await _api.put<FriendshipModel>(
      ApiEndpoints.friendInviteAccept(inviteId),
      fromData: (data) =>
          FriendshipModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<FriendshipModel> declineInvite(String inviteId) async {
    Log.api('PUT', ApiEndpoints.friendInviteDecline(inviteId));
    final response = await _api.put<FriendshipModel>(
      ApiEndpoints.friendInviteDecline(inviteId),
      fromData: (data) =>
          FriendshipModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> removeFriend(String friendshipId) async {
    Log.api('DELETE', ApiEndpoints.friend(friendshipId));
    await _api.delete<void>(ApiEndpoints.friend(friendshipId));
  }
}
