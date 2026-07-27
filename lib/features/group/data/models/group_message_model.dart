enum MessageRole {
  user,
  assistant;

  static MessageRole fromString(String? value) =>
      value == 'assistant' ? MessageRole.assistant : MessageRole.user;
}

enum MessageType {
  text,
  image,
  system;

  static MessageType fromString(String? value) {
    switch (value) {
      case 'image':
        return MessageType.image;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}

class GroupMessageModel {
  final String id;
  final String groupId;
  final String? senderId;
  final String? senderUsername;
  final MessageRole role;
  final MessageType messageType;
  final String? content;
  final String? fileUrl;
  final Map<String, dynamic>? extraData;
  final String sentAt;

  GroupMessageModel({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderUsername,
    required this.role,
    required this.messageType,
    required this.content,
    required this.fileUrl,
    required this.extraData,
    required this.sentAt,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) =>
      GroupMessageModel(
        id: json["id"] ?? '',
        groupId: json["group_id"] ?? '',
        senderId: json["sender_id"],
        senderUsername: json["sender_username"],
        role: MessageRole.fromString(json["role"]),
        messageType: MessageType.fromString(json["message_type"]),
        content: json["content"],
        fileUrl: json["file_url"],
        extraData: json["extra_data"] != null
            ? Map<String, dynamic>.from(json["extra_data"])
            : null,
        sentAt: json["sent_at"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "group_id": groupId,
        "sender_id": senderId,
        "sender_username": senderUsername,
        "role": role.name,
        "message_type": messageType.name,
        "content": content,
        "file_url": fileUrl,
        "extra_data": extraData,
        "sent_at": sentAt,
      };

  bool get isImage => messageType == MessageType.image || (fileUrl != null && fileUrl!.isNotEmpty);
  bool get isSystem => messageType == MessageType.system;

  DateTime get sentAtDate =>
      DateTime.tryParse(sentAt)?.toLocal() ?? DateTime.now();
}
