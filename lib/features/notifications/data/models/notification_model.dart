import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));
String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

enum NotificationType {
  budgetNearLimit('budget_near_limit'),
  friendInvite('friend_invite'),
  groupInvite('group_invite'),
  groupActivity('group_activity'),
  bankSyncCompleted('bank_sync_completed'),
  subscriptionActivated('subscription_activated'),
  unknown('unknown');

  final String wire;
  const NotificationType(this.wire);

  // The backend adds types independently of app releases — an unrecognised one
  // must render as a generic row, never crash the feed.
  static NotificationType fromWire(String? value) => NotificationType.values
      .firstWhere((t) => t.wire == value, orElse: () => NotificationType.unknown);
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;

  /// Opaque deep-link payload echoed from the push. Kept as a raw map because
  /// its shape varies per [type] and it is only ever forwarded to the router.
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"]?.toString() ?? '',
        type: NotificationType.fromWire(json["type"] as String?),
        title: json["title"] ?? '',
        body: json["body"] ?? '',
        data: json["data"] != null
            ? Map<String, dynamic>.from(json["data"])
            : null,
        isRead: json["is_read"] ?? false,
        readAt: json["read_at"] != null
            ? DateTime.parse(json["read_at"]).toLocal()
            : null,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"]).toLocal()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type.wire,
        "title": title,
        "body": body,
        "data": data,
        "is_read": isRead,
        "read_at": readAt?.toUtc().toIso8601String(),
        "created_at": createdAt.toUtc().toIso8601String(),
      };

  NotificationModel copyWith({bool? isRead, DateTime? readAt}) =>
      NotificationModel(
        id: id,
        type: type,
        title: title,
        body: body,
        data: data,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
      );
}
