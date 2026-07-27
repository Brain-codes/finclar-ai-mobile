import 'dart:convert';

FriendshipModel friendshipModelFromJson(String str) =>
    FriendshipModel.fromJson(json.decode(str));
String friendshipModelToJson(FriendshipModel data) =>
    json.encode(data.toJson());

enum FriendshipStatus {
  pending,
  accepted,
  declined;

  static FriendshipStatus fromString(String? value) {
    switch (value) {
      case 'accepted':
        return FriendshipStatus.accepted;
      case 'declined':
        return FriendshipStatus.declined;
      default:
        return FriendshipStatus.pending;
    }
  }
}

class FriendshipModel {
  final String id;
  final String requesterId;
  final String recipientId;
  final FriendshipStatus status;
  final String createdAt;
  final String friendId;
  final String friendUsername;
  final String friendEmail;

  FriendshipModel({
    required this.id,
    required this.requesterId,
    required this.recipientId,
    required this.status,
    required this.createdAt,
    required this.friendId,
    required this.friendUsername,
    required this.friendEmail,
  });

  factory FriendshipModel.fromJson(Map<String, dynamic> json) =>
      FriendshipModel(
        id: json["id"] ?? '',
        requesterId: json["requester_id"] ?? '',
        recipientId: json["recipient_id"] ?? '',
        status: FriendshipStatus.fromString(json["status"]),
        createdAt: json["created_at"] ?? '',
        friendId: json["friend_id"] ?? '',
        friendUsername: json["friend_username"] ?? '',
        friendEmail: json["friend_email"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "requester_id": requesterId,
        "recipient_id": recipientId,
        "status": status.name,
        "created_at": createdAt,
        "friend_id": friendId,
        "friend_username": friendUsername,
        "friend_email": friendEmail,
      };

  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
}

class UserSearchResultModel {
  final String id;
  final String username;
  final String email;

  UserSearchResultModel({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserSearchResultModel.fromJson(Map<String, dynamic> json) =>
      UserSearchResultModel(
        id: json["id"] ?? '',
        username: json["username"] ?? '',
        email: json["email"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
      };
}
