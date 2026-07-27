class SavingsEntryModel {
  final String id;
  final String userId;
  final double amount;
  final double? cumulativeAtTime;
  final String? note;
  final String? fileUrl;
  final String recordedAt;

  SavingsEntryModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.cumulativeAtTime,
    required this.note,
    required this.fileUrl,
    required this.recordedAt,
  });

  factory SavingsEntryModel.fromJson(Map<String, dynamic> json) =>
      SavingsEntryModel(
        id: json["id"] ?? '',
        userId: json["user_id"] ?? '',
        amount: double.tryParse(json["amount"]?.toString() ?? '') ?? 0,
        cumulativeAtTime: json["cumulative_at_time"] != null
            ? double.tryParse(json["cumulative_at_time"].toString())
            : null,
        note: json["note"],
        fileUrl: json["file_url"],
        recordedAt: json["recorded_at"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "amount": amount,
        "cumulative_at_time": cumulativeAtTime,
        "note": note,
        "file_url": fileUrl,
        "recorded_at": recordedAt,
      };
}
