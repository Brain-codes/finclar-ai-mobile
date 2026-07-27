import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));
String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

enum NotificationType { transaction, budget, group, insight, system }

NotificationType _typeFromString(String? value) {
  switch (value) {
    case 'transaction':
      return NotificationType.transaction;
    case 'budget':
      return NotificationType.budget;
    case 'group':
      return NotificationType.group;
    case 'insight':
      return NotificationType.insight;
    default:
      return NotificationType.system;
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"]?.toString() ?? '',
        title: json["title"] ?? '',
        body: json["body"] ?? '',
        type: _typeFromString(json["type"]),
        isRead: json["is_read"] ?? false,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"]).toLocal()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "type": type.name,
        "is_read": isRead,
        "created_at": createdAt.toUtc().toIso8601String(),
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
