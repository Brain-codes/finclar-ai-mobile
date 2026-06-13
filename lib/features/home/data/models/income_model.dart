import 'dart:convert';

IncomeModel incomeModelFromJson(String str) =>
    IncomeModel.fromJson(json.decode(str));
String incomeModelToJson(IncomeModel data) => json.encode(data.toJson());

class IncomeModel {
  final String id;
  final double amount;
  final String sourceId;
  final String sourceName;
  final String reoccurrence;
  final String? note;
  final String startDate;

  const IncomeModel({
    required this.id,
    required this.amount,
    required this.sourceId,
    required this.sourceName,
    required this.reoccurrence,
    this.note,
    required this.startDate,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) => IncomeModel(
        id: json['id'] as String,
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        sourceId: json['source_id'] as String,
        sourceName: json['source_name'] as String,
        reoccurrence: json['reoccurrence'] as String,
        note: json['note'] as String?,
        startDate: json['start_date'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'source_id': sourceId,
        'source_name': sourceName,
        'reoccurrence': reoccurrence,
        'note': note,
        'start_date': startDate,
      };
}
